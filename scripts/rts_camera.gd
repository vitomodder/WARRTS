class_name RtsCamera
extends Node3D
## Cámara isométrica: WASD/flechas o bordes de pantalla para moverse, rueda para zoom.

const PITCH_DEG := 52.0
const PAN_SPEED := 60.0
const EDGE_MARGIN := 12
const MIN_ZOOM := 18.0
const MAX_ZOOM := 220.0

var camera: Camera3D
var zoom: float = 60.0
var map_half: float = 110.0


func _ready() -> void:
	rotation.y = deg_to_rad(Entity.CAMERA_YAW_DEG)
	camera = Camera3D.new()
	camera.fov = 40.0
	camera.far = 1500.0
	add_child(camera)
	camera.make_current()
	_apply_zoom()


func _apply_zoom() -> void:
	var a := deg_to_rad(PITCH_DEG)
	camera.position = Vector3(0, sin(a) * zoom, cos(a) * zoom)
	camera.rotation = Vector3(-a, 0, 0)


func _process(delta: float) -> void:
	var move := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move.x += 1
	if DisplayServer.window_is_focused():
		var vp := get_viewport()
		var mouse := vp.get_mouse_position()
		var vsize := vp.get_visible_rect().size
		if mouse.x >= 0 and mouse.y >= 0 and mouse.x <= vsize.x and mouse.y <= vsize.y:
			if mouse.x < EDGE_MARGIN:
				move.x -= 1
			elif mouse.x > vsize.x - EDGE_MARGIN:
				move.x += 1
			if mouse.y < EDGE_MARGIN:
				move.y -= 1
			elif mouse.y > vsize.y - EDGE_MARGIN:
				move.y += 1
	if move != Vector2.ZERO:
		var speed := PAN_SPEED * (zoom / 48.0)
		var dir := global_transform.basis * Vector3(move.x, 0, move.y)
		dir.y = 0.0
		global_position += dir.normalized() * speed * delta
		global_position.x = clampf(global_position.x, -map_half, map_half)
		global_position.z = clampf(global_position.z, -map_half, map_half)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = maxf(MIN_ZOOM, zoom * 0.9)
			_apply_zoom()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = minf(MAX_ZOOM, zoom * 1.1)
			_apply_zoom()


func focus(pos: Vector3) -> void:
	global_position = Vector3(pos.x, 0, pos.z)


## Punto del suelo (y = 0) bajo una posición de la pantalla.
func ground_point(screen_pos: Vector2) -> Variant:
	var origin := camera.project_ray_origin(screen_pos)
	var normal := camera.project_ray_normal(screen_pos)
	return Plane(Vector3.UP, 0.0).intersects_ray(origin, normal)
