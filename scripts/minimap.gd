class_name Minimap
extends Control
## Minimapa girado como la cámara (arriba = hacia donde mira). Clic para mover la cámara.

var game: Node


func _process(_delta: float) -> void:
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var pressed: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	var dragging: bool = event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0
	if pressed or dragging:
		game.cam_rig.focus(_to_world(event.position))
		accept_event()


func _scale() -> float:
	# El mapa girado 45° ocupa la diagonal: cabe entero en el control.
	return size.x / (MapBuilder.MAP_HALF * 2.0 * sqrt(2.0))


func _to_map(p: Vector3) -> Vector2:
	var local := p.rotated(Vector3.UP, -deg_to_rad(Entity.CAMERA_YAW_DEG))
	return size * 0.5 + Vector2(local.x, local.z) * _scale()


func _to_world(m: Vector2) -> Vector3:
	var local := (m - size * 0.5) / _scale()
	return Vector3(local.x, 0, local.y).rotated(Vector3.UP, deg_to_rad(Entity.CAMERA_YAW_DEG))


func _draw() -> void:
	if game == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.06, 0.05, 0.85))
	var h := MapBuilder.MAP_HALF
	var corners := PackedVector2Array([
		_to_map(Vector3(-h, 0, -h)), _to_map(Vector3(h, 0, -h)),
		_to_map(Vector3(h, 0, h)), _to_map(Vector3(-h, 0, h)),
	])
	draw_colored_polygon(corners, Color(0.25, 0.27, 0.18))
	var s := _scale()
	draw_arc(_to_map(Vector3.ZERO), GameData.WAR_ZONE_RADIUS * s, 0, TAU, 48, Color(1, 0.6, 0.15), 1.5)
	draw_circle(_to_map(game.war_zone.hot_center), GameData.HOT_ZONE_RADIUS * s, Color(1, 0.15, 0.1, 0.45))
	if game.war_zone.is_moving_soon():
		draw_arc(_to_map(game.war_zone.next_hot_center), GameData.HOT_ZONE_RADIUS * s, 0, TAU, 24, Color(1, 0.9, 0.2), 1.0)
	for b in game.buildings:
		var c: Color = GameData.FACTIONS[b.faction].color
		var half := 5.0 if b.type_id == "base" else 3.0
		var p := _to_map(b.global_position)
		draw_rect(Rect2(p - Vector2(half, half), Vector2(half, half) * 2.0), c)
		draw_rect(Rect2(p - Vector2(half, half), Vector2(half, half) * 2.0), Color.WHITE, false, 1.0)
	for u in game.units:
		if u.inside != null:
			continue
		var c: Color = GameData.FACTIONS[u.faction].color.lightened(0.2)
		if not u.is_operational():
			c = Color(0.6, 0.6, 0.6)
		draw_circle(_to_map(u.global_position), 2.5 if u.is_vehicle else 1.5, c)
	# Zona que muestra la cámara.
	var cam_pos: Vector3 = game.cam_rig.global_position
	var view: float = game.cam_rig.zoom * 0.9 * s
	draw_rect(Rect2(_to_map(cam_pos) - Vector2(view, view * 0.6), Vector2(view * 2.0, view * 1.2)), Color(1, 1, 1, 0.8), false, 1.0)
