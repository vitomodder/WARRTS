## Cámara isométrica (GDD 12.2): WASD, flechas o ratón en el borde para moverla,
## rueda para el zoom y botón central para girarla.
class_name CamaraRts
extends Node3D

const INCLINACION := 50.0
## Distancias mínima y máxima de la cámara, en metros. A la máxima se ven unos 800 m.
const ZOOM_MIN := 18.0
const ZOOM_MAX := 900.0
## A partir de esta distancia las unidades se ven como iconos de clase.
const ZOOM_ICONOS := 260.0
const BORDE := 10
const GIRO_RATON := 0.006

var camara: Camera3D
var distancia: float = 90.0
var limite: float = 1000.0
var _girando: bool = false


func _ready() -> void:
	rotation.y = deg_to_rad(45.0)
	camara = Camera3D.new()
	camara.fov = 38.0
	camara.near = 0.5
	camara.far = 4000.0
	add_child(camara)
	camara.make_current()
	_aplicar_zoom()


func _aplicar_zoom() -> void:
	var a := deg_to_rad(INCLINACION)
	camara.position = Vector3(0, sin(a) * distancia, cos(a) * distancia)
	camara.rotation = Vector3(-a, 0, 0)


func iconos_visibles() -> bool:
	return distancia >= ZOOM_ICONOS


func _process(delta: float) -> void:
	var mover := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		mover.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		mover.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		mover.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		mover.x += 1
	if DisplayServer.window_is_focused() and not _girando:
		var vp := get_viewport()
		var r := vp.get_visible_rect().size
		var m := vp.get_mouse_position()
		if m.x >= 0 and m.y >= 0 and m.x <= r.x and m.y <= r.y:
			if m.x < BORDE:
				mover.x -= 1
			elif m.x > r.x - BORDE:
				mover.x += 1
			if m.y < BORDE:
				mover.y -= 1
			elif m.y > r.y - BORDE:
				mover.y += 1
	if mover != Vector2.ZERO:
		var vel := 40.0 + distancia * 1.2
		var dir := global_transform.basis * Vector3(mover.x, 0, mover.y)
		dir.y = 0.0
		global_position += dir.normalized() * vel * delta
		global_position.x = clampf(global_position.x, -limite, limite)
		global_position.z = clampf(global_position.z, -limite, limite)


func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton:
		if evento.button_index == MOUSE_BUTTON_MIDDLE:
			_girando = evento.pressed
		elif evento.pressed and evento.button_index == MOUSE_BUTTON_WHEEL_UP:
			distancia = maxf(ZOOM_MIN, distancia * 0.88)
			_aplicar_zoom()
		elif evento.pressed and evento.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distancia = minf(ZOOM_MAX, distancia * 1.14)
			_aplicar_zoom()
	elif evento is InputEventMouseMotion and _girando:
		rotation.y -= evento.relative.x * GIRO_RATON


func centrar(pos: Vector3) -> void:
	global_position = Vector3(pos.x, 0, pos.z)


## Punto del suelo bajo una posición de la pantalla, o null.
func punto_suelo(pantalla: Vector2) -> Variant:
	var origen := camara.project_ray_origin(pantalla)
	var normal := camara.project_ray_normal(pantalla)
	return Plane(Vector3.UP, 0.0).intersects_ray(origen, normal)


## Posición en pantalla de un punto del mundo, o null si queda detrás de la cámara.
func en_pantalla(p: Vector3) -> Variant:
	if camara.is_position_behind(p):
		return null
	return camara.unproject_position(p)
