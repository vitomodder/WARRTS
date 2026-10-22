## Una unidad en el campo. La lógica avanza en pasos fijos (`paso_sim`) y el dibujo
## se suaviza entre pasos (`_process`). En la Fase 1 solo tiene movimiento, órdenes y
## selección; las piezas de combate, postura y clase llegan en la Fase 2.
class_name Unidad
extends Node3D

## Distancia a la que se da por alcanzado un punto de la ruta.
const LLEGADA := 0.6
## Cada cuánto se recalcula la ruta al perseguir un objetivo, en segundos.
const REPERSEGUIR := 1.0
## Velocidad de giro, en radianes por segundo.
const GIRO := 8.0

var id: int = 0
var equipo: int = 0
var def: UnidadDef
var sim: Simulacion
var vida: float = 100.0

## Estado de la simulación.
var posicion: Vector3 = Vector3.ZERO
var posicion_anterior: Vector3 = Vector3.ZERO
var rumbo: float = 0.0
var rumbo_anterior: float = 0.0
## Destinos pendientes: {pos, mirar, atacar}. El primero es el actual.
var destinos: Array[Dictionary] = []
var ruta: PackedVector3Array = PackedVector3Array()
var indice_ruta: int = 0
var objetivo: Unidad = null
var atacando_por_el_camino: bool = false
var _reperseguir: float = 0.0
var _mirar_final: Vector3 = Vector3.ZERO

## Dibujo.
var seleccionada: bool = false
var _cuerpo: MeshInstance3D
var _anillo: MeshInstance3D
var _icono: Label3D


func preparar(p_sim: Simulacion, p_id: int, p_def: UnidadDef, p_equipo: int, pos: Vector3, materiales: Dictionary) -> void:
	sim = p_sim
	id = p_id
	def = p_def
	equipo = p_equipo
	vida = def.vida
	posicion = pos
	posicion_anterior = pos
	name = "%s_%d" % [def.id, id]
	_crear_dibujo(materiales)
	position = pos


func esta_viva() -> bool:
	return vida > 0.0


func se_mueve() -> bool:
	return not destinos.is_empty() or objetivo != null


func limpiar_ordenes() -> void:
	destinos.clear()
	ruta = PackedVector3Array()
	indice_ruta = 0
	objetivo = null
	atacando_por_el_camino = false
	_mirar_final = Vector3.ZERO


func encolar_destino(pos: Vector3, mirar: Vector3, atacar: bool) -> void:
	destinos.append({"pos": pos, "mirar": mirar, "atacar": atacar})


## Punto al que debe ir ahora, o null si no tiene que moverse.
func destino_actual() -> Variant:
	if objetivo != null:
		return objetivo.posicion
	if not destinos.is_empty():
		return destinos[0].pos
	return null


func calcular_ruta(mundo: Mundo) -> void:
	var meta: Variant = destino_actual()
	if meta == null:
		return
	ruta = mundo.ruta(posicion, meta)
	indice_ruta = 1 if ruta.size() > 1 else 0
	if ruta.is_empty() and objetivo == null:
		# Sitio inalcanzable: se descarta ese destino y se pasa al siguiente.
		destinos.pop_front()
		if not destinos.is_empty():
			sim.pedir_ruta(self)
		return
	if not destinos.is_empty() and objetivo == null:
		atacando_por_el_camino = destinos[0].atacar


## Un paso de simulación de `dt` segundos.
func paso_sim(dt: float) -> void:
	posicion_anterior = posicion
	rumbo_anterior = rumbo
	if objetivo != null:
		_perseguir(dt)
	elif not destinos.is_empty():
		_seguir_ruta(dt)
	elif _mirar_final != Vector3.ZERO:
		_girar_hacia(_mirar_final, dt)


func _perseguir(dt: float) -> void:
	if not is_instance_valid(objetivo) or not objetivo.esta_viva():
		limpiar_ordenes()
		return
	var hacia := objetivo.posicion - posicion
	hacia.y = 0.0
	if hacia.length() <= def.alcance:
		ruta = PackedVector3Array()
		_girar_hacia(hacia, dt)
		return
	_reperseguir -= dt
	if _reperseguir <= 0.0:
		_reperseguir = REPERSEGUIR
		# Solo se pide ruta nueva si el objetivo se ha alejado del final de la actual.
		var tolerancia := maxf(3.0, hacia.length() * 0.1)
		if ruta.is_empty() or ruta[ruta.size() - 1].distance_to(objetivo.posicion) > tolerancia:
			sim.pedir_ruta(self)
	_avanzar_por_ruta(dt)


func _seguir_ruta(dt: float) -> void:
	if ruta.is_empty():
		return  # esperando a que se calcule la ruta
	if _avanzar_por_ruta(dt):
		var hecho: Dictionary = destinos.pop_front()
		_mirar_final = hecho.mirar
		ruta = PackedVector3Array()
		if not destinos.is_empty():
			sim.pedir_ruta(self)


## Avanza por la ruta. Devuelve true al llegar al final.
func _avanzar_por_ruta(dt: float) -> bool:
	if ruta.is_empty():
		return false
	var resto := def.velocidad * dt
	while resto > 0.0 and indice_ruta < ruta.size():
		var punto := ruta[indice_ruta]
		var hacia := Vector3(punto.x - posicion.x, 0, punto.z - posicion.z)
		var d := hacia.length()
		if d <= maxf(resto, LLEGADA * 0.25):
			posicion = Vector3(punto.x, posicion.y, punto.z)
			resto -= d
			indice_ruta += 1
			continue
		var paso := hacia / d * resto
		posicion += paso
		_girar_hacia(paso, dt)
		resto = 0.0
	return indice_ruta >= ruta.size()


func _girar_hacia(dir: Vector3, dt: float) -> void:
	if Vector2(dir.x, dir.z).length() < 0.001:
		return
	var deseado := atan2(dir.x, dir.z)
	rumbo = rotate_toward(rumbo, deseado, GIRO * dt)


## Empuje para no solaparse con otras unidades (lo aplica la simulación).
func empujar(desplazamiento: Vector3) -> void:
	posicion += Vector3(desplazamiento.x, 0, desplazamiento.z)


# ------------------------------------------------------------------ Dibujo

func _crear_dibujo(materiales: Dictionary) -> void:
	_cuerpo = MeshInstance3D.new()
	_cuerpo.mesh = materiales.cuerpo
	_cuerpo.material_override = materiales.equipo
	_cuerpo.position.y = def.altura * 0.5
	add_child(_cuerpo)

	var mochila := MeshInstance3D.new()
	mochila.mesh = materiales.mochila
	mochila.material_override = materiales.oscuro
	mochila.position = Vector3(0, def.altura * 0.62, -0.22)
	add_child(mochila)

	_anillo = MeshInstance3D.new()
	_anillo.mesh = materiales.anillo
	_anillo.material_override = materiales.seleccion
	_anillo.position.y = 0.05
	_anillo.visible = false
	add_child(_anillo)

	_icono = Label3D.new()
	_icono.text = def.letra
	_icono.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_icono.fixed_size = true
	_icono.pixel_size = 0.0012
	_icono.font_size = 16
	_icono.outline_size = 7
	_icono.modulate = Color.WHITE
	_icono.outline_modulate = materiales.color
	_icono.no_depth_test = true
	_icono.position.y = def.altura + 1.0
	_icono.visible = false
	add_child(_icono)


func marcar_seleccion(valor: bool) -> void:
	seleccionada = valor
	_anillo.visible = valor


## Iconos de clase al alejar la cámara (GDD 12.2).
func mostrar_icono(valor: bool) -> void:
	_icono.visible = valor


func _process(_delta: float) -> void:
	if sim == null:
		return
	var a := sim.alfa()
	position = posicion_anterior.lerp(posicion, a)
	rotation.y = lerp_angle(rumbo_anterior, rumbo, a)
