## Reloj y estado de la partida (ARQUITECTURA §3). La lógica avanza en pasos fijos,
## separados del dibujo; las órdenes se aplican al principio de cada paso.
class_name Simulacion
extends Node

signal paso_terminado(paso: int)

## Metros de la rejilla fina que se usa para que las unidades no se solapen.
const CELDA_SEPARACION := 4.0
## Milisegundos como mucho por paso para calcular rutas.
const PRESUPUESTO_RUTAS_MS := 5.0

var parametros: ParametrosPartida
var mundo: Mundo
var comandos := Comandos.new()
var unidades: Array[Unidad] = []
var paso: int = 0
## Multiplicador de velocidad del juego (×1 normal; las pruebas usan más).
var velocidad: float = 1.0
var pausada: bool = false
## Milisegundos del último paso y del más lento, para medir rendimiento.
var ms_ultimo_paso: float = 0.0
var ms_paso_maximo: float = 0.0

var indice: IndiceEspacial
var _indice_fino: IndiceEspacial
var _por_id: Dictionary = {}
var _siguiente_id: int = 1
var _cola_rutas: Array[Unidad] = []
var _en_cola: Dictionary = {}
var _acumulado: float = 0.0
var _contenedor: Node3D
var _materiales: Array[Dictionary] = []


func preparar(p_parametros: ParametrosPartida, p_mundo: Mundo, contenedor: Node3D, colores: Array) -> void:
	parametros = p_parametros
	mundo = p_mundo
	_contenedor = contenedor
	indice = IndiceEspacial.new(parametros.celda_indice)
	_indice_fino = IndiceEspacial.new(CELDA_SEPARACION)
	for c in colores:
		_materiales.append(_crear_materiales(c))


func crear_unidad(def: UnidadDef, equipo: int, pos: Vector3) -> Unidad:
	var u := Unidad.new()
	u.preparar(self, _siguiente_id, def, equipo, pos, _materiales[equipo])
	_siguiente_id += 1
	unidades.append(u)
	_por_id[u.id] = u
	_contenedor.add_child(u)
	return u


func unidad(id: int) -> Unidad:
	return _por_id.get(id)


func unidades_de(equipo: int) -> Array[Unidad]:
	var res: Array[Unidad] = []
	for u in unidades:
		if u.equipo == equipo:
			res.append(u)
	return res


## Unidades vivas del equipo de la orden a las que va dirigida.
func unidades_de_orden(orden: Orden) -> Array[Unidad]:
	var res: Array[Unidad] = []
	for i in orden.unidades:
		var u: Unidad = _por_id.get(i)
		if u != null and u.equipo == orden.equipo and u.esta_viva():
			res.append(u)
	return res


func enviar(orden: Orden) -> void:
	comandos.enviar(orden, paso)


func pedir_ruta(u: Unidad) -> void:
	if not _en_cola.has(u.id):
		_en_cola[u.id] = true
		_cola_rutas.append(u)


## Fracción del paso actual ya transcurrida, para suavizar el dibujo.
func alfa() -> float:
	return clampf(_acumulado / parametros.paso, 0.0, 1.0)


func _process(delta: float) -> void:
	if pausada or parametros == null:
		return
	_acumulado += delta * velocidad
	var maximo := 8  # no encadenar demasiados pasos si el equipo va lento
	while _acumulado >= parametros.paso and maximo > 0:
		_acumulado -= parametros.paso
		avanzar_paso()
		maximo -= 1
	if maximo == 0:
		_acumulado = 0.0


## Avanza `segundos` de juego de golpe (pruebas y partida automática).
func avanzar(segundos: float) -> void:
	for i in int(round(segundos / parametros.paso)):
		avanzar_paso()


func avanzar_paso() -> void:
	var inicio := Time.get_ticks_usec()
	comandos.aplicar(self, paso)
	_calcular_rutas()
	var dt := parametros.paso
	for u in unidades:
		u.paso_sim(dt)
	_separar()
	indice.reconstruir(unidades)
	paso += 1
	ms_ultimo_paso = (Time.get_ticks_usec() - inicio) / 1000.0
	ms_paso_maximo = maxf(ms_paso_maximo, ms_ultimo_paso)
	paso_terminado.emit(paso)


## Calcula rutas pendientes hasta `rutas_por_paso` o hasta gastar el presupuesto de
## tiempo; el resto espera al paso siguiente.
func _calcular_rutas() -> void:
	var inicio := Time.get_ticks_usec()
	var n := 0
	while n < _cola_rutas.size() and n < parametros.rutas_por_paso:
		var u: Unidad = _cola_rutas[n]
		n += 1
		_en_cola.erase(u.id)
		if u.esta_viva():
			u.calcular_ruta(mundo)
		if Time.get_ticks_usec() - inicio > PRESUPUESTO_RUTAS_MS * 1000.0:
			break
	_cola_rutas = _cola_rutas.slice(n)


## Las unidades que se solapan se apartan un poco, salvo que eso las meta en un obstáculo.
func _separar() -> void:
	_indice_fino.reconstruir(unidades)
	for u in unidades:
		var empuje := Vector3.ZERO
		for o in _indice_fino.cerca(u.posicion, u.def.radio * 2.0 + 0.4):
			if o == u:
				continue
			var d := Vector3(u.posicion.x - o.posicion.x, 0, u.posicion.z - o.posicion.z)
			var dist := d.length()
			var minimo: float = u.def.radio + o.def.radio + 0.3
			if dist >= minimo:
				continue
			if dist < 0.01:
				d = Vector3(cos(u.id), 0, sin(u.id))
				dist = 0.01
			empuje += d / dist * (minimo - dist) * 0.5
		if empuje != Vector3.ZERO and not mundo.bloqueado(u.posicion + empuje):
			u.empujar(empuje)


func _crear_materiales(color: Color) -> Dictionary:
	var cuerpo := CapsuleMesh.new()
	cuerpo.radius = 0.32
	cuerpo.height = 1.8
	var mochila := BoxMesh.new()
	mochila.size = Vector3(0.45, 0.5, 0.25)
	var anillo := TorusMesh.new()
	anillo.inner_radius = 0.75
	anillo.outer_radius = 0.95
	var equipo := StandardMaterial3D.new()
	equipo.albedo_color = color.darkened(0.15)
	equipo.roughness = 0.9
	var oscuro := StandardMaterial3D.new()
	oscuro.albedo_color = Color(0.25, 0.24, 0.2)
	oscuro.roughness = 1.0
	var seleccion := StandardMaterial3D.new()
	seleccion.albedo_color = Color(0.4, 1.0, 0.45)
	seleccion.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return {
		"color": color, "cuerpo": cuerpo, "mochila": mochila, "anillo": anillo,
		"equipo": equipo, "oscuro": oscuro, "seleccion": seleccion,
	}
