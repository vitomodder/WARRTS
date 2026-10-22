## El terreno, los obstáculos y la navegación. En la Fase 1 es un mapa de pruebas
## llano de 2 × 2 km con rocas, bosques y casas que bloquean el paso; los 4 mapas
## del GDD llegan en la Fase 7.
class_name Mundo
extends Node3D

## Metros por celda de la malla de navegación.
const CELDA_NAV := 1.0
## Distancia de cada base al centro del mapa de pruebas.
const DISTANCIA_BASES := 750.0
## Margen alrededor de cada obstáculo en la rejilla de bloqueo (radio de un soldado).
const MARGEN_BLOQUEO := 0.6
## Hasta esta distancia se intenta ir en línea recta sin pedir ruta al navegador.
const RECTA_MAXIMA := 150.0

var tamano: float = 2000.0
## Posición de la base de cada equipo (Patriot, Jade, Sandstorm).
var bases: Array[Vector3] = []
var _rng := RandomNumberGenerator.new()
var _obstaculos: Node3D
var _region: NavigationRegion3D
var _iteracion_horneado: int = 0
## Rejilla de 1 m: 1 si la celda está ocupada por un obstáculo. Es mucho más rápida
## que preguntar al servidor de navegación, que recorre todos los polígonos del mapa.
var _bloqueo := PackedByteArray()
var _lado: int = 0
var _mat_roca: StandardMaterial3D
var _mat_tronco: StandardMaterial3D
var _mat_hojas: StandardMaterial3D
var _mat_casa: StandardMaterial3D
var _mat_tejado: StandardMaterial3D


## Crea el suelo y, si `decorado`, reparte obstáculos. Después hay que llamar a `hornear()`.
func construir(p_tamano: float, semilla: int, decorado: bool) -> void:
	tamano = p_tamano
	_rng.seed = semilla
	bases.clear()
	for i in 3:
		var a := PI / 2.0 + i * TAU / 3.0  # una abajo en el centro, dos arriba en las esquinas
		bases.append(Vector3(cos(a), 0, sin(a)) * minf(DISTANCIA_BASES, tamano * 0.38))
	_mat_roca = _material(Color(0.46, 0.45, 0.42))
	_mat_tronco = _material(Color(0.32, 0.24, 0.16))
	_mat_hojas = _material(Color(0.24, 0.33, 0.18))
	_mat_casa = _material(Color(0.86, 0.83, 0.76))
	_mat_tejado = _material(Color(0.62, 0.22, 0.18))
	_lado = ceili(tamano)
	_bloqueo = PackedByteArray()
	_bloqueo.resize(_lado * _lado)
	_obstaculos = Node3D.new()
	_obstaculos.name = "Obstaculos"
	add_child(_obstaculos)
	_crear_suelo()
	if decorado:
		_repartir_rocas(160)
		_repartir_bosques(40)
		_repartir_pueblos(6)


## Una caja que bloquea el paso (casa, muro). `tam` en metros.
func agregar_caja(pos: Vector3, tam: Vector3, mat: Material = null, giro: float = 0.0) -> StaticBody3D:
	var cuerpo := StaticBody3D.new()
	cuerpo.position = Vector3(pos.x, tam.y * 0.5, pos.z)
	cuerpo.rotation.y = giro
	var forma := CollisionShape3D.new()
	var caja := BoxShape3D.new()
	caja.size = tam
	forma.shape = caja
	cuerpo.add_child(forma)
	var malla := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = tam
	malla.mesh = bm
	malla.material_override = mat if mat != null else _mat_casa
	cuerpo.add_child(malla)
	_obstaculos.add_child(cuerpo)
	_bloquear_caja(pos, tam, giro)
	return cuerpo


## Un cilindro que bloquea el paso (roca, árbol).
func agregar_cilindro(pos: Vector3, radio: float, alto: float, mat: Material = null) -> StaticBody3D:
	var cuerpo := StaticBody3D.new()
	cuerpo.position = Vector3(pos.x, alto * 0.5, pos.z)
	var forma := CollisionShape3D.new()
	var cil := CylinderShape3D.new()
	cil.radius = radio
	cil.height = alto
	forma.shape = cil
	cuerpo.add_child(forma)
	var malla := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = radio * 0.75
	cm.bottom_radius = radio
	cm.height = alto
	cm.radial_segments = 9
	malla.mesh = cm
	malla.material_override = mat if mat != null else _mat_roca
	cuerpo.add_child(malla)
	_obstaculos.add_child(cuerpo)
	_bloquear_circulo(pos, radio)
	return cuerpo


## Genera la malla de navegación con los obstáculos actuales.
func hornear() -> void:
	var nav := NavigationMesh.new()
	nav.cell_size = CELDA_NAV
	nav.cell_height = 0.25
	nav.agent_radius = 1.0
	nav.agent_height = 2.0
	nav.agent_max_climb = 0.5
	nav.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	var m := tamano * 0.5
	nav.filter_baking_aabb = AABB(Vector3(-m, -2, -m), Vector3(tamano, 20, tamano))
	var fuente := NavigationMeshSourceGeometryData3D.new()
	NavigationServer3D.parse_source_geometry_data(nav, fuente, self)
	NavigationServer3D.bake_from_source_geometry_data(nav, fuente)
	NavigationServer3D.map_set_cell_size(get_world_3d().navigation_map, CELDA_NAV)
	if _region != null:
		_region.queue_free()
	_iteracion_horneado = NavigationServer3D.map_get_iteration_id(get_world_3d().navigation_map)
	_region = NavigationRegion3D.new()
	_region.navigation_mesh = nav
	add_child(_region)


## True cuando el servidor de navegación ya tiene la malla lista (se actualiza en el
## siguiente fotograma de física después de `hornear()`).
func listo() -> bool:
	return NavigationServer3D.map_get_iteration_id(get_world_3d().navigation_map) > _iteracion_horneado


## Ruta de `desde` a `hasta`. Si el camino recto está libre y es corto no se pregunta
## al navegador.
func ruta(desde: Vector3, hasta: Vector3) -> PackedVector3Array:
	if desde.distance_to(hasta) <= RECTA_MAXIMA and not bloqueado(hasta) and linea_libre(desde, hasta):
		return PackedVector3Array([desde, hasta])
	return NavigationServer3D.map_get_path(get_world_3d().navigation_map, desde, hasta, true)


## True si hay un obstáculo en ese punto o está fuera del mapa.
func bloqueado(p: Vector3) -> bool:
	var m := tamano * 0.5
	var x := floori(p.x + m)
	var z := floori(p.z + m)
	if x < 0 or z < 0 or x >= _lado or z >= _lado:
		return true
	return _bloqueo[z * _lado + x] != 0


## True si se puede ir en línea recta de `a` a `b` sin tocar obstáculos.
func linea_libre(a: Vector3, b: Vector3) -> bool:
	var d := Vector3(b.x - a.x, 0, b.z - a.z)
	var n := ceili(d.length() / 0.5)
	for i in range(1, n + 1):
		if bloqueado(a + d * (float(i) / n)):
			return false
	return true


## El punto transitable más cercano (para no quedar dentro de un obstáculo).
func punto_transitable(p: Vector3) -> Vector3:
	var q := NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, p)
	return Vector3(q.x, p.y, q.z)


func dentro(p: Vector3) -> bool:
	var m := tamano * 0.5
	return absf(p.x) <= m and absf(p.z) <= m


# ------------------------------------------------------------------ Generación

func _marcar(x: int, z: int) -> void:
	if x >= 0 and z >= 0 and x < _lado and z < _lado:
		_bloqueo[z * _lado + x] = 1


func _bloquear_circulo(c: Vector3, radio: float) -> void:
	var m := tamano * 0.5
	var r := radio + MARGEN_BLOQUEO
	for x in range(floori(c.x - r + m), ceili(c.x + r + m)):
		for z in range(floori(c.z - r + m), ceili(c.z + r + m)):
			var dx := x + 0.5 - m - c.x
			var dz := z + 0.5 - m - c.z
			if dx * dx + dz * dz <= r * r:
				_marcar(x, z)


func _bloquear_caja(c: Vector3, tam: Vector3, giro: float) -> void:
	var m := tamano * 0.5
	var hx := tam.x * 0.5 + MARGEN_BLOQUEO
	var hz := tam.z * 0.5 + MARGEN_BLOQUEO
	var r := sqrt(hx * hx + hz * hz)
	var cs := cos(giro)
	var sn := sin(giro)
	for x in range(floori(c.x - r + m), ceili(c.x + r + m)):
		for z in range(floori(c.z - r + m), ceili(c.z + r + m)):
			var dx := x + 0.5 - m - c.x
			var dz := z + 0.5 - m - c.z
			# Al sistema de la caja (giro alrededor del eje Y).
			var lx := dx * cs - dz * sn
			var lz := dx * sn + dz * cs
			if absf(lx) <= hx and absf(lz) <= hz:
				_marcar(x, z)


func _material(c: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = c
	mat.roughness = 1.0
	return mat


func _crear_suelo() -> void:
	var cuerpo := StaticBody3D.new()
	cuerpo.name = "Suelo"
	cuerpo.position.y = -0.5
	var forma := CollisionShape3D.new()
	var caja := BoxShape3D.new()
	caja.size = Vector3(tamano, 1.0, tamano)
	forma.shape = caja
	cuerpo.add_child(forma)
	var ruido := FastNoiseLite.new()
	ruido.frequency = 0.012
	ruido.fractal_octaves = 4
	var tex := NoiseTexture2D.new()
	tex.noise = ruido
	tex.seamless = true
	tex.width = 1024
	tex.height = 1024
	var grad := Gradient.new()
	grad.set_color(0, Color(0.33, 0.37, 0.24))
	grad.set_color(1, Color(0.52, 0.5, 0.36))
	tex.color_ramp = grad
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = tex
	mat.uv1_scale = Vector3(tamano / 120.0, tamano / 120.0, 1)
	mat.roughness = 1.0
	var plano := PlaneMesh.new()
	plano.size = Vector2(tamano, tamano)
	var malla := MeshInstance3D.new()
	malla.mesh = plano
	malla.material_override = mat
	malla.position.y = 0.5
	cuerpo.add_child(malla)
	add_child(cuerpo)


## Lejos de las bases para que las unidades puedan salir.
func _libre(p: Vector3, margen: float) -> bool:
	for b in bases:
		if p.distance_to(b) < 120.0 + margen:
			return false
	return dentro(p * 1.05)


func _punto_al_azar() -> Vector3:
	var m := tamano * 0.48
	return Vector3(_rng.randf_range(-m, m), 0, _rng.randf_range(-m, m))


func _repartir_rocas(n: int) -> void:
	for i in n:
		var p := _punto_al_azar()
		var r := _rng.randf_range(2.0, 8.0)
		if _libre(p, r):
			agregar_cilindro(p, r, r * 0.8, _mat_roca)


func _repartir_bosques(n: int) -> void:
	for i in n:
		var c := _punto_al_azar()
		if not _libre(c, 40.0):
			continue
		for j in _rng.randi_range(12, 30):
			var p := c + Vector3(_rng.randf_range(-35, 35), 0, _rng.randf_range(-35, 35))
			agregar_cilindro(p, 0.7, 3.0, _mat_tronco)
			var copa := MeshInstance3D.new()
			var esfera := SphereMesh.new()
			esfera.radius = _rng.randf_range(3.0, 4.5)
			esfera.height = esfera.radius * 1.6
			copa.mesh = esfera
			copa.material_override = _mat_hojas
			copa.position = p + Vector3(0, 5.0, 0)
			_obstaculos.add_child(copa)


func _repartir_pueblos(n: int) -> void:
	for i in n:
		var c := _punto_al_azar()
		if not _libre(c, 60.0):
			continue
		for j in _rng.randi_range(5, 10):
			var p := c + Vector3(_rng.randf_range(-55, 55), 0, _rng.randf_range(-55, 55))
			var tam := Vector3(_rng.randf_range(8, 14), _rng.randf_range(4, 6), _rng.randf_range(7, 11))
			var giro := _rng.randi_range(0, 3) * PI / 2.0
			agregar_caja(p, tam, _mat_casa, giro)
			var tejado := MeshInstance3D.new()
			var prisma := PrismMesh.new()
			prisma.size = Vector3(tam.x + 0.6, 2.5, tam.z + 0.6)
			tejado.mesh = prisma
			tejado.material_override = _mat_tejado
			tejado.position = Vector3(p.x, tam.y + 1.25, p.z)
			tejado.rotation.y = giro
			_obstaculos.add_child(tejado)
