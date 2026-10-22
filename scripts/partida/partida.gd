## Escena principal de la Fase 1: mapa de pruebas de 2 × 2 km con 100 soldados por
## equipo. El jugador lleva a Patriot; Jade y Sandstorm se quedan quietos (la IA
## llega en la Fase 5).
##
## Opciones de línea de órdenes (después de `--`):
##   --autotest        partida automática sin jugador: órdenes al azar para los 3 equipos
##                     durante 180 s de juego; mide el tiempo de cada paso y sale.
##   --captura=RUTA    guarda una imagen de la pantalla a los pocos segundos y sale.
##   --zoom=METROS     distancia inicial de la cámara (para las capturas).
##   --fps             mide los fotogramas por segundo durante 10 s y sale.
class_name Partida
extends Node3D

const COLORES := [Color("2f6fd6"), Color("d23b3b"), Color("2fa84f")]
const NOMBRES := ["Patriot", "Jade", "Sandstorm"]
## Soldados de cada clase por equipo en el mapa de pruebas.
const REPARTO := [
	["asalto", 40], ["apoyo", 15], ["medico", 15],
	["ingeniero", 10], ["francotirador", 10], ["conductor", 10],
]
const EQUIPO_JUGADOR := 0
const SEGUNDOS_AUTOTEST := 180.0

@export var tamano_mapa: float = 2000.0
@export var semilla: int = 7

var parametros: ParametrosPartida
var defs: Dictionary = {}
var mundo: Mundo
var sim: Simulacion
var camara: CamaraRts
var hud: Hud
var control: ControlJugador
var _iconos: bool = false


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	_crear_ambiente()
	parametros = load("res://data/partida.tres")
	defs = cargar_defs()

	mundo = Mundo.new()
	mundo.name = "Mundo"
	add_child(mundo)
	mundo.construir(tamano_mapa, semilla, true)
	mundo.hornear()
	while not mundo.listo():
		await get_tree().physics_frame

	var contenedor := Node3D.new()
	contenedor.name = "Unidades"
	add_child(contenedor)
	sim = Simulacion.new()
	sim.name = "Simulacion"
	add_child(sim)
	sim.preparar(parametros, mundo, contenedor, COLORES)
	desplegar()

	if "--autotest" in args:
		get_tree().quit(autotest())
		return

	camara = CamaraRts.new()
	camara.name = "Camara"
	camara.limite = tamano_mapa * 0.5
	add_child(camara)
	camara.centrar(_centro(sim.unidades_de(EQUIPO_JUGADOR)))
	var hacia_centro := -mundo.bases[EQUIPO_JUGADOR]
	camara.rotation.y = atan2(-hacia_centro.x, -hacia_centro.z)

	var marcas := Node3D.new()
	marcas.name = "Marcas"
	add_child(marcas)
	control = ControlJugador.new()
	control.name = "Control"
	hud = Hud.new()
	hud.name = "Hud"
	add_child(hud)
	hud.preparar(sim, control.seleccion, marcas, NOMBRES)
	add_child(control)
	control.preparar(sim, camara, hud, EQUIPO_JUGADOR)

	for a in args:
		if a.begins_with("--zoom="):
			camara.distancia = float(a.trim_prefix("--zoom="))
			camara._aplicar_zoom()
		elif a.begins_with("--captura="):
			_captura(a.trim_prefix("--captura="))
		elif a == "--fps":
			_medir_fps()


static func _centro(lista: Array) -> Vector3:
	var c := Vector3.ZERO
	for u in lista:
		c += u.posicion
	return c / maxi(1, lista.size())


static func cargar_defs() -> Dictionary:
	var res := {}
	for par in REPARTO:
		res[par[0]] = load("res://data/unidades/%s.tres" % par[0])
	return res


## Coloca a cada equipo en filas delante de su base, mirando al centro.
func desplegar() -> void:
	for equipo in 3:
		var base: Vector3 = mundo.bases[equipo]
		var frente := (Vector3.ZERO - base).normalized()
		var lado := frente.cross(Vector3.UP)
		var n := 0
		for par in REPARTO:
			for i in par[1]:
				var fila := n / 20
				var col := n % 20
				var p := base + frente * (fila * 3.5) + lado * ((col - 9.5) * 3.0)
				var u := sim.crear_unidad(defs[par[0]], equipo, mundo.punto_transitable(p))
				u.rumbo = atan2(frente.x, frente.z)
				u.rumbo_anterior = u.rumbo
				n += 1


func _process(_delta: float) -> void:
	if camara == null:
		return
	var ver := camara.iconos_visibles()
	if ver != _iconos:
		_iconos = ver
		for u in sim.unidades:
			u.mostrar_icono(ver)


func _crear_ambiente() -> void:
	var cielo := ProceduralSkyMaterial.new()
	cielo.sky_top_color = Color(0.42, 0.55, 0.7)
	cielo.sky_horizon_color = Color(0.72, 0.74, 0.72)
	cielo.ground_horizon_color = Color(0.6, 0.6, 0.55)
	var sky := Sky.new()
	sky.sky_material = cielo
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.66, 0.72)
	env.ambient_light_energy = 0.45
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 0.9
	env.fog_enabled = true
	env.fog_light_color = Color(0.7, 0.72, 0.72)
	env.fog_density = 0.0002
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)

	var sol := DirectionalLight3D.new()
	sol.name = "Sol"
	sol.rotation_degrees = Vector3(-38, 35, 0)
	sol.light_energy = 1.0
	sol.shadow_enabled = true
	sol.directional_shadow_max_distance = 400.0
	add_child(sol)


# ------------------------------------------------------------------ Pruebas

## Partida automática: órdenes al azar (pero siempre las mismas) para los 3 equipos.
## Devuelve el código de salida: 0 si todo va bien.
func autotest() -> int:
	sim.pausada = true
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla
	var pasos_total := int(SEGUNDOS_AUTOTEST / parametros.paso)
	var cada := int(10.0 / parametros.paso)
	var suma_ms := 0.0
	var antes: Dictionary = {}
	var atascadas := 0
	print("Partida automática: %d unidades, %d s de juego" % [sim.unidades.size(), SEGUNDOS_AUTOTEST])
	for i in pasos_total:
		if i % cada == 0:
			atascadas = _contar_atascadas(antes)
			antes = {}
			for u in sim.unidades:
				antes[u.id] = u.posicion
			for equipo in 3:
				_ordenes_al_azar(equipo, rng)
		sim.avanzar_paso()
		suma_ms += sim.ms_ultimo_paso
	var media := suma_ms / pasos_total
	var fuera := 0
	for u in sim.unidades:
		if not mundo.dentro(u.posicion):
			fuera += 1
	print("Pasos: %d · media %.2f ms · máximo %.2f ms" % [pasos_total, media, sim.ms_paso_maximo])
	print("Órdenes registradas: %d" % sim.comandos.registro.size())
	print("Unidades atascadas (con destino y sin moverse 10 s): %d · fuera del mapa: %d" % [atascadas, fuera])
	var ok := fuera == 0 and atascadas <= sim.unidades.size() / 50 and media < parametros.paso * 1000.0 * 0.5
	print("RESULTADO: " + ("OK" if ok else "FALLO"))
	return 0 if ok else 1


func _contar_atascadas(antes: Dictionary) -> int:
	var n := 0
	for u in sim.unidades:
		if antes.has(u.id) and not u.destinos.is_empty() and u.objetivo == null:
			if u.posicion.distance_to(antes[u.id]) < 1.0:
				n += 1
	return n


func _ordenes_al_azar(equipo: int, rng: RandomNumberGenerator) -> void:
	var propias := sim.unidades_de(equipo)
	var enemigas: Array[Unidad] = []
	for u in sim.unidades:
		if u.equipo != equipo:
			enemigas.append(u)
	# Grupos de 10 a 30 soldados con una orden cada uno.
	var i := 0
	while i < propias.size():
		var tam := rng.randi_range(10, 30)
		var ids := PackedInt32Array()
		for u in propias.slice(i, i + tam):
			ids.append(u.id)
		i += tam
		var tirada := rng.randf()
		var orden: Orden
		if tirada < 0.6:
			var mover := OrdenMover.new()
			var m := tamano_mapa * 0.45
			mover.destino = Vector3(rng.randf_range(-m, m), 0, rng.randf_range(-m, m))
			mover.atacar_por_el_camino = rng.randf() < 0.3
			mover.ancho_linea = rng.randf_range(20, 60) if rng.randf() < 0.3 else 0.0
			orden = mover
		elif tirada < 0.85:
			var atacar := OrdenAtacar.new()
			atacar.objetivo = enemigas[rng.randi() % enemigas.size()].id
			orden = atacar
		else:
			orden = OrdenDetener.new()
		orden.equipo = equipo
		orden.unidades = ids
		sim.enviar(orden)


func _captura(ruta: String) -> void:
	await get_tree().create_timer(3.0).timeout
	var img := get_viewport().get_texture().get_image()
	img.save_png(ruta)
	print("Captura guardada en " + ruta)
	get_tree().quit()


func _medir_fps() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	# Todas las unidades se mueven a la vez durante la medida.
	for equipo in 3:
		var orden := OrdenMover.new()
		orden.equipo = equipo
		orden.unidades = PackedInt32Array(sim.unidades_de(equipo).map(func(u): return u.id))
		orden.destino = Vector3.ZERO
		sim.enviar(orden)
	await get_tree().create_timer(2.0).timeout
	var cuadros := 0
	var inicio := Time.get_ticks_msec()
	while Time.get_ticks_msec() - inicio < 10000:
		await get_tree().process_frame
		cuadros += 1
	print("FPS medios: %.1f" % (cuadros / 10.0))
	get_tree().quit()
