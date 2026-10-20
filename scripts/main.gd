extends Node3D
## Partida: crea el mapa y las 3 facciones, gestiona el dinero, la selección y las órdenes.

const MAP_HALF := 110.0
const BASE_DISTANCE := 75.0
const START_INFANTRY := 4
const DRAG_THRESHOLD := 8.0

var factions: Array = []
var units: Array = []
var buildings: Array = []
var selection: Array = []
var player_faction: int = 0
var game_over: bool = false
var placing_type: String = ""

var cam_rig: RtsCamera
var hud: Hud
var _ghost: MeshInstance3D
var _mouse_down: bool = false
var _dragging: bool = false
var _drag_start: Vector2 = Vector2.ZERO
## Modo prueba (`-- --autotest`): las 3 facciones las juega la IA y se imprime el estado.
var _autotest: bool = false
var _autotest_time: float = 0.0
var _autotest_report: float = 0.0
var _shot_taken: bool = false


func _ready() -> void:
	randomize()
	_autotest = "--autotest" in OS.get_cmdline_user_args()
	_setup_environment()
	_setup_ground()

	cam_rig = RtsCamera.new()
	cam_rig.map_half = MAP_HALF
	add_child(cam_rig)

	for i in GameData.FACTIONS.size():
		var f: Dictionary = GameData.FACTIONS[i]
		factions.append({"name": f.name, "color": f.color, "money": GameData.START_MONEY, "alive": true})
		var angle := -PI / 2.0 + i * TAU / GameData.FACTIONS.size()
		var base_pos := Vector3(cos(angle), 0, sin(angle)) * BASE_DISTANCE
		var hq := spawn_building(i, "hq", base_pos)
		for k in START_INFANTRY:
			var u := spawn_unit(i, "infantry", hq.global_position + Vector3(k * 1.6 - 2.4, 0, 0))
			u.order_move(hq.rally_point + Vector3(k * 1.6 - 2.4, 0, 0))
		if i != player_faction or _autotest:
			var ai := AiController.new()
			ai.setup(self, i)
			add_child(ai)

	hud = Hud.new()
	add_child(hud)
	hud.setup(self)
	var my_hq := get_hq(player_faction)
	cam_rig.focus(my_hq.global_position.lerp(Vector3.ZERO, 0.25))
	if _autotest:
		Engine.time_scale = 4.0


# ---------------------------------------------------------------- Escenario

func _setup_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.38, 0.5, 0.65)
	sky_mat.sky_horizon_color = Color(0.72, 0.7, 0.62)
	sky_mat.ground_horizon_color = Color(0.5, 0.47, 0.4)
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.45
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.ssao_enabled = true
	env.glow_enabled = true
	env.fog_enabled = true
	env.fog_light_color = Color(0.7, 0.68, 0.6)
	env.fog_density = 0.002
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation = Vector3(deg_to_rad(-55), deg_to_rad(-35), 0)
	sun.light_energy = 1.1
	sun.light_color = Color(1.0, 0.95, 0.85)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 220.0
	add_child(sun)


func _setup_ground() -> void:
	var noise := FastNoiseLite.new()
	noise.frequency = 0.02
	var tex := NoiseTexture2D.new()
	tex.noise = noise
	tex.seamless = true
	tex.width = 512
	tex.height = 512
	var grad := Gradient.new()
	grad.set_color(0, Color(0.24, 0.25, 0.18))
	grad.set_color(1, Color(0.4, 0.37, 0.27))
	tex.color_ramp = grad
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = tex
	mat.uv1_scale = Vector3(6, 6, 1)
	mat.roughness = 1.0
	var plane := PlaneMesh.new()
	plane.size = Vector2(MAP_HALF * 2.4, MAP_HALF * 2.4)
	GameData.add_mesh(self, plane, mat, Vector3.ZERO)

	# Decoración: rocas y árboles (solo visual, no bloquean el paso todavía).
	var rock_mat := GameData.make_material(Color(0.45, 0.44, 0.42))
	var trunk_mat := GameData.make_material(Color(0.3, 0.22, 0.15))
	var leaf_mat := GameData.make_material(Color(0.22, 0.3, 0.16))
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
	for i in 140:
		var pos := Vector3(rng.randf_range(-MAP_HALF, MAP_HALF), 0, rng.randf_range(-MAP_HALF, MAP_HALF))
		if _near_base(pos, 28.0):
			continue
		if rng.randf() < 0.5:
			var rock := SphereMesh.new()
			var s := rng.randf_range(0.6, 2.2)
			rock.radius = s
			rock.height = s * 1.1
			GameData.add_mesh(self, rock, rock_mat, pos + Vector3(0, s * 0.2, 0))
		else:
			var h := rng.randf_range(3.0, 6.0)
			GameData.add_mesh(self, GameData.cylinder(0.2, h * 0.4), trunk_mat, pos + Vector3(0, h * 0.2, 0))
			var cone := CylinderMesh.new()
			cone.top_radius = 0.0
			cone.bottom_radius = h * 0.3
			cone.height = h * 0.8
			GameData.add_mesh(self, cone, leaf_mat, pos + Vector3(0, h * 0.75, 0))


func _near_base(pos: Vector3, dist: float) -> bool:
	for i in GameData.FACTIONS.size():
		var angle := -PI / 2.0 + i * TAU / GameData.FACTIONS.size()
		if pos.distance_to(Vector3(cos(angle), 0, sin(angle)) * BASE_DISTANCE) < dist:
			return true
	return false


func clamp_to_map(pos: Vector3) -> Vector3:
	return Vector3(clampf(pos.x, -MAP_HALF, MAP_HALF), 0.0, clampf(pos.z, -MAP_HALF, MAP_HALF))


# ---------------------------------------------------------------- Entidades

func spawn_unit(faction: int, unit_type: String, pos: Vector3) -> Unit:
	var u := Unit.new()
	u.setup(self, faction, unit_type)
	add_child(u)
	u.global_position = clamp_to_map(pos)
	units.append(u)
	return u


func spawn_building(faction: int, building_type: String, pos: Vector3) -> Building:
	var b := Building.new()
	b.setup(self, faction, building_type)
	add_child(b)
	b.global_position = pos
	var to_center := -pos.normalized() if pos.length() > 1.0 else Vector3.FORWARD
	b.rally_point = pos + to_center * (b.radius + 6.0)
	buildings.append(b)
	return b


func units_of(faction: int) -> Array:
	return units.filter(func(u): return u.faction == faction)


func buildings_of(faction: int) -> Array:
	return buildings.filter(func(b): return b.faction == faction)


func get_hq(faction: int) -> Building:
	for b in buildings:
		if b.faction == faction and b.type_id == "hq":
			return b
	return null


func has_building(faction: int, building_type: String) -> bool:
	for b in buildings:
		if b.faction == faction and b.type_id == building_type:
			return true
	return false


## Edificio de la facción que fabrica ese tipo de unidad y tiene la cola más corta.
func find_producer(faction: int, unit_type: String) -> Building:
	var best: Building = null
	for b in buildings:
		if b.faction == faction and b.can_produce(unit_type):
			if best == null or b.queue.size() < best.queue.size():
				best = b
	return best


func find_nearest_enemy(unit: Unit, max_range: float) -> Entity:
	var best: Entity = null
	var best_d := INF
	for list in [units, buildings]:
		for e in list:
			if e.faction == unit.faction or e.is_dead:
				continue
			var d: float = unit.global_position.distance_to(e.global_position) - e.radius
			if e is Building:
				d += 4.0  # prefiere disparar a unidades antes que a edificios
			if d <= max_range and d < best_d:
				best_d = d
				best = e
	return best


func find_enemy_near(faction: int, pos: Vector3, max_range: float) -> Entity:
	for u in units:
		if u.faction != faction and u.global_position.distance_to(pos) <= max_range:
			return u
	return null


## Empuje para que las unidades no se monten unas encima de otras.
func separation_push(unit: Unit) -> Vector3:
	var push := Vector3.ZERO
	for other in units:
		if other == unit:
			continue
		var diff: Vector3 = unit.global_position - other.global_position
		diff.y = 0.0
		var min_d: float = unit.radius + other.radius
		var d := diff.length()
		if d < min_d:
			if d < 0.01:
				diff = Vector3(randf() - 0.5, 0, randf() - 0.5)
				d = 0.01
			push += diff.normalized() * (min_d - d) / min_d
	for b in buildings:
		var diff: Vector3 = unit.global_position - b.global_position
		diff.y = 0.0
		var min_d: float = unit.radius + b.radius
		var d := diff.length()
		if d < min_d and d > 0.01:
			push += diff.normalized() * 2.0 * (min_d - d) / min_d
	return push


# ---------------------------------------------------------------- Economía

func try_buy_unit(faction: int, unit_type: String) -> bool:
	var cost: int = GameData.UNITS[unit_type].cost
	var producer := find_producer(faction, unit_type)
	if producer == null or factions[faction].money < cost or not factions[faction].alive:
		return false
	factions[faction].money -= cost
	producer.enqueue(unit_type)
	return true


func can_place_building(faction: int, building_type: String, pos: Vector3) -> bool:
	var d: Dictionary = GameData.BUILDINGS[building_type]
	if factions[faction].money < d.cost or not factions[faction].alive:
		return false
	if absf(pos.x) > MAP_HALF - 5.0 or absf(pos.z) > MAP_HALF - 5.0:
		return false
	var hq := get_hq(faction)
	if hq == null or hq.global_position.distance_to(pos) > GameData.BUILD_RADIUS:
		return false
	var r: float = maxf(d.size.x, d.size.z) * 0.55
	for b in buildings:
		if b.global_position.distance_to(pos) < b.radius + r + 2.0:
			return false
	return true


func try_place_building(faction: int, building_type: String, pos: Vector3) -> bool:
	if not can_place_building(faction, building_type, pos):
		return false
	factions[faction].money -= GameData.BUILDINGS[building_type].cost
	spawn_building(faction, building_type, pos)
	return true


func on_entity_died(e: Entity, killer_faction: int) -> void:
	units.erase(e)
	buildings.erase(e)
	selection.erase(e)
	spawn_explosion(e.global_position, e.radius)
	if killer_faction >= 0 and killer_faction != e.faction and factions[killer_faction].alive:
		var reward := e.get_reward()
		factions[killer_faction].money += reward
		if killer_faction == player_faction:
			spawn_floating_text(e.global_position + Vector3(0, 2.5, 0), "+$%d" % reward)
	if e is Building and e.type_id == "hq":
		_eliminate_faction(e.faction)


func _eliminate_faction(faction: int) -> void:
	if not factions[faction].alive:
		return
	factions[faction].alive = false
	for list in [units.duplicate(), buildings.duplicate()]:
		for x in list:
			if x.faction == faction:
				x.die(false)
	var alive: Array = []
	for i in factions.size():
		if factions[i].alive:
			alive.append(i)
	if _autotest:
		print("[autotest] %s eliminada" % factions[faction].name)
		if alive.size() == 1:
			print("[autotest] GANA %s" % factions[alive[0]].name)
			_print_status()
			game_over = true
			get_tree().quit()
		return
	if faction == player_faction:
		game_over = true
		hud.show_end("DERROTA")
	elif alive.size() == 1 and alive[0] == player_faction:
		game_over = true
		hud.show_end("¡VICTORIA!")


# ---------------------------------------------------------------- Efectos

func spawn_shot(from: Vector3, to: Vector3, dmg_type: String) -> void:
	var length := from.distance_to(to)
	if length < 0.1:
		return
	var thick := 0.05 if dmg_type == "bullet" else 0.15
	var color := Color(1.0, 0.85, 0.4) if dmg_type == "bullet" else Color(1.0, 0.55, 0.2)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	var tracer := MeshInstance3D.new()
	tracer.mesh = GameData.box(Vector3(thick, thick, length))
	tracer.material_override = mat
	add_child(tracer)
	tracer.look_at_from_position((from + to) * 0.5, to, Vector3.UP)
	get_tree().create_timer(0.06 if dmg_type == "bullet" else 0.12).timeout.connect(tracer.queue_free)
	if dmg_type != "bullet":
		spawn_explosion(to, 0.5)


func spawn_explosion(pos: Vector3, size: float) -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1.0, 0.6, 0.2, 0.9)
	var ball := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	ball.mesh = sphere
	ball.material_override = mat
	add_child(ball)
	ball.global_position = pos + Vector3(0, 0.5, 0)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.6, 0.3)
	light.omni_range = 4.0 + size * 3.0
	light.light_energy = 3.0
	ball.add_child(light)
	var final_scale := Vector3.ONE * (1.0 + size * 2.5)
	var tw := ball.create_tween()
	tw.set_parallel(true)
	tw.tween_property(ball, "scale", final_scale, 0.35)
	tw.tween_property(mat, "albedo_color:a", 0.0, 0.35)
	tw.tween_property(light, "light_energy", 0.0, 0.35)
	tw.chain().tween_callback(ball.queue_free)


func spawn_floating_text(pos: Vector3, text: String) -> void:
	var label := Label3D.new()
	label.text = text
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 64
	label.outline_size = 12
	label.modulate = Color(0.5, 1.0, 0.45)
	label.no_depth_test = true
	add_child(label)
	label.global_position = pos
	var tw := label.create_tween()
	tw.set_parallel(true)
	tw.tween_property(label, "position:y", pos.y + 3.0, 1.2)
	tw.tween_property(label, "modulate:a", 0.0, 1.2).set_delay(0.4)
	tw.chain().tween_callback(label.queue_free)


func spawn_order_marker(pos: Vector3, color: Color) -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = color
	var torus := TorusMesh.new()
	torus.inner_radius = 0.8
	torus.outer_radius = 1.0
	var m := GameData.add_mesh(self, torus, mat, pos + Vector3(0, 0.1, 0))
	m.scale.y = 0.2
	var tw := m.create_tween()
	tw.set_parallel(true)
	tw.tween_property(m, "scale", Vector3(0.2, 0.05, 0.2), 0.4)
	tw.tween_property(mat, "albedo_color:a", 0.0, 0.4)
	tw.chain().tween_callback(m.queue_free)


# ---------------------------------------------------------------- Controles del jugador

func player_buy_unit(unit_type: String) -> void:
	try_buy_unit(player_faction, unit_type)


func start_placement(building_type: String) -> void:
	_cancel_placement()
	placing_type = building_type
	var d: Dictionary = GameData.BUILDINGS[building_type]
	_ghost = MeshInstance3D.new()
	_ghost.mesh = GameData.box(d.size)
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ghost.material_override = mat
	add_child(_ghost)
	_update_ghost(get_viewport().get_mouse_position())


func _cancel_placement() -> void:
	placing_type = ""
	if _ghost:
		_ghost.queue_free()
		_ghost = null


func _update_ghost(screen_pos: Vector2) -> void:
	if _ghost == null:
		return
	var p = cam_rig.ground_point(screen_pos)
	if p == null:
		return
	var d: Dictionary = GameData.BUILDINGS[placing_type]
	_ghost.global_position = p + Vector3(0, d.size.y * 0.5, 0)
	var ok := can_place_building(player_faction, placing_type, p)
	(_ghost.material_override as StandardMaterial3D).albedo_color = Color(0.3, 1, 0.3, 0.4) if ok else Color(1, 0.2, 0.2, 0.4)


func _process(delta: float) -> void:
	if _autotest:
		_autotest_time += delta
		_autotest_report += delta
		for arg in OS.get_cmdline_user_args():
			if arg.begins_with("--shot=") and _autotest_time >= 25.0 and not _shot_taken:
				_shot_taken = true
				get_viewport().get_texture().get_image().save_png(arg.trim_prefix("--shot="))
		if _autotest_report >= 30.0:
			_autotest_report = 0.0
			_print_status()
		if _autotest_time > 900.0 and not game_over:
			print("[autotest] tiempo agotado")
			_print_status()
			get_tree().quit()


func _print_status() -> void:
	var parts: Array = []
	for i in factions.size():
		var f: Dictionary = factions[i]
		var counts := {}
		for u in units_of(i):
			counts[u.type_id] = counts.get(u.type_id, 0) + 1
		parts.append("%s %s $%d %s edif=%d" % [f.name, "vivo" if f.alive else "fuera", f.money, counts, buildings_of(i).size()])
	print("[autotest t=%ds] %s" % [int(_autotest_time), " | ".join(parts)])


func _unhandled_input(event: InputEvent) -> void:
	if game_over:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_cancel_placement()
			_set_selection([])
		elif event.keycode == KEY_H:
			var hq := get_hq(player_faction)
			if hq:
				cam_rig.focus(hq.global_position)
		return

	if event is InputEventMouseMotion:
		if placing_type != "":
			_update_ghost(event.position)
		elif _mouse_down:
			if not _dragging and event.position.distance_to(_drag_start) > DRAG_THRESHOLD:
				_dragging = true
			if _dragging:
				var rect := Rect2(_drag_start, event.position - _drag_start).abs()
				hud.drag_box.position = rect.position
				hud.drag_box.size = rect.size
				hud.drag_box.visible = true
		return

	if not event is InputEventMouseButton:
		return
	var mb := event as InputEventMouseButton

	if placing_type != "":
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			var p = cam_rig.ground_point(mb.position)
			if p != null and try_place_building(player_faction, placing_type, p):
				_cancel_placement()
		elif mb.pressed and mb.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_placement()
		return

	if mb.button_index == MOUSE_BUTTON_LEFT:
		if mb.pressed:
			_mouse_down = true
			_dragging = false
			_drag_start = mb.position
		else:
			_mouse_down = false
			hud.drag_box.visible = false
			if _dragging:
				_box_select(Rect2(_drag_start, mb.position - _drag_start).abs(), mb.shift_pressed)
			else:
				_click_select(mb.position, mb.shift_pressed)
			_dragging = false
	elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
		_issue_order(mb.position, mb.ctrl_pressed)


func _set_selection(list: Array) -> void:
	for e in selection:
		if is_instance_valid(e):
			e.set_selected(false)
	selection = list
	for e in selection:
		e.set_selected(true)


func _click_select(screen_pos: Vector2, add: bool) -> void:
	var e := _entity_at(screen_pos)
	var list: Array = selection.duplicate() if add else []
	if e is Unit and e.faction == player_faction and not e in list:
		list.append(e)
	_set_selection(list)


func _box_select(rect: Rect2, add: bool) -> void:
	var list: Array = selection.duplicate() if add else []
	var cam := cam_rig.camera
	for u in units:
		if u.faction != player_faction or u in list:
			continue
		if rect.has_point(cam.unproject_position(u.global_position + Vector3(0, 0.8, 0))):
			list.append(u)
	_set_selection(list)


func _entity_at(screen_pos: Vector2) -> Entity:
	var cam := cam_rig.camera
	var right := cam.global_transform.basis.x
	var best: Entity = null
	var best_d := INF
	for list in [units, buildings]:
		for e in list:
			var center: Vector3 = e.global_position + Vector3(0, minf(e.radius, 2.0), 0)
			var sp := cam.unproject_position(center)
			var r_px := (cam.unproject_position(center + right * e.radius) - sp).length() + 6.0
			var d := sp.distance_to(screen_pos)
			if d <= r_px and d < best_d:
				best_d = d
				best = e
	return best


func _issue_order(screen_pos: Vector2, attack_move: bool) -> void:
	var my_units: Array = selection.filter(func(e): return is_instance_valid(e) and e is Unit)
	if my_units.is_empty():
		return
	var target := _entity_at(screen_pos)
	if target != null and target.faction != player_faction:
		for u in my_units:
			u.order_attack(target)
		spawn_order_marker(target.global_position, Color(1, 0.3, 0.2, 0.9))
		return
	var p = cam_rig.ground_point(screen_pos)
	if p == null:
		return
	# Formación en cuadrícula alrededor del punto pulsado.
	var cols := ceili(sqrt(my_units.size()))
	var spacing := 2.2
	var i := 0
	for u in my_units:
		var offset := Vector3((i % cols) - (cols - 1) * 0.5, 0, (i / cols) - (cols - 1) * 0.5) * spacing
		u.order_move(clamp_to_map(p + offset), attack_move)
		i += 1
	spawn_order_marker(p, Color(1, 0.3, 0.2, 0.9) if attack_move else Color(0.3, 1, 0.4, 0.9))
