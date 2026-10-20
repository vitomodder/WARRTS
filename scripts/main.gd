extends Node3D
## Partida: mapa, 3 equipos, economía por bajas, despliegue, puntuación y controles.
##
## Todas las acciones de un jugador pasan por las funciones cmd_* (comprar, mover,
## atacar...). Así, cuando llegue el multijugador, bastará con enviar esas órdenes
## por la red al anfitrión de la partida.

const MAP_HALF := MapBuilder.MAP_HALF
const DRAG_THRESHOLD := 8.0
const GRID_CELL := 16.0
const HEAL_RANGE := 7.0
const REPAIR_RANGE := 7.0

var factions: Array = []
var units: Array = []
var buildings: Array = []
var selection: Array = []
var player_faction: int = 0
var game_over: bool = false
var winner: int = -1
var placing_type: String = ""

## Opciones de compra del jugador local.
var deploy_index: int = 0
var buy_with_crew: bool = true

var map: MapBuilder
var war_zone: WarZone
var cam_rig: RtsCamera
var hud: Hud

## Unidades compradas esperando a aparecer: {faction, type, building, time, crew}
var _deploy_queue: Array = []
var _grid: Dictionary = {}
var _ghost: MeshInstance3D
var _mouse_down: bool = false
var _dragging: bool = false
var _drag_start: Vector2 = Vector2.ZERO
var _match_time: float = 0.0
## Modo prueba (`-- --autotest`): las 3 facciones las juega la IA y se imprime el estado.
var _autotest: bool = false
var _autotest_report: float = 0.0
var _shot_taken: bool = false


func _ready() -> void:
	randomize()
	_autotest = "--autotest" in OS.get_cmdline_user_args()
	_setup_environment()

	map = MapBuilder.new()
	add_child(map)
	map.build(1234)

	war_zone = WarZone.new()
	add_child(war_zone)
	war_zone.setup(self, randi())

	cam_rig = RtsCamera.new()
	cam_rig.map_half = MAP_HALF
	add_child(cam_rig)

	for i in GameData.FACTIONS.size():
		var f: Dictionary = GameData.FACTIONS[i]
		factions.append({
			"name": f.name, "color": f.color, "money": GameData.START_MONEY,
			"free_cooldown": 0.0, "kills": 0,
		})
		spawn_building(i, "base", map.base_positions[i])
		if i != player_faction or _autotest:
			var ai := AiController.new()
			ai.setup(self, i)
			add_child(ai)

	hud = Hud.new()
	add_child(hud)
	hud.setup(self)
	var base_pos: Vector3 = map.base_positions[player_faction]
	cam_rig.focus(base_pos.lerp(Vector3.ZERO, 0.08))
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
	env.fog_density = 0.0015
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation = Vector3(deg_to_rad(-55), deg_to_rad(-35), 0)
	sun.light_energy = 1.1
	sun.light_color = Color(1.0, 0.95, 0.85)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 250.0
	add_child(sun)


func clamp_to_map(pos: Vector3) -> Vector3:
	return Vector3(clampf(pos.x, -MAP_HALF, MAP_HALF), pos.y, clampf(pos.z, -MAP_HALF, MAP_HALF))


func find_path(from: Vector3, to: Vector3) -> PackedVector3Array:
	return map.find_path(from, to)


# ---------------------------------------------------------------- Entidades

func spawn_unit(faction: int, unit_type: String, pos: Vector3) -> Unit:
	var u := Unit.new()
	u.setup(self, faction, unit_type)
	add_child(u)
	u.global_position = clamp_to_map(Vector3(pos.x, 0, pos.z))
	units.append(u)
	return u


func spawn_building(faction: int, building_type: String, pos: Vector3) -> Building:
	var b := Building.new()
	b.setup(self, faction, building_type)
	add_child(b)
	b.global_position = pos
	buildings.append(b)
	return b


func units_of(faction: int) -> Array:
	return units.filter(func(u): return u.faction == faction)


func active_units_of(faction: int) -> Array:
	return units.filter(func(u): return u.faction == faction and u.inside == null)


func get_base(faction: int) -> Building:
	for b in buildings:
		if b.faction == faction and b.type_id == "base":
			return b
	return null


## Base + zonas de despliegue terminadas, en ese orden.
func deploy_points(faction: int) -> Array:
	var list: Array = [get_base(faction)]
	for b in buildings:
		if b.faction == faction and b.type_id == "fob" and b.complete:
			list.append(b)
	return list


func fob_count(faction: int) -> int:
	return buildings.filter(func(b): return b.faction == faction and b.type_id == "fob").size()


func pop_count(faction: int) -> int:
	var n := units_of(faction).size()
	for d in _deploy_queue:
		if d.faction == faction:
			n += 2 if d.crew else 1
	return n


func queued_for(faction: int) -> Array:
	return _deploy_queue.filter(func(d): return d.faction == faction)


func _rebuild_grid() -> void:
	_grid.clear()
	for u in units:
		if u.is_dead or u.inside != null:
			continue
		var key := Vector2i(floori(u.global_position.x / GRID_CELL), floori(u.global_position.z / GRID_CELL))
		if _grid.has(key):
			_grid[key].append(u)
		else:
			_grid[key] = [u]


func _units_near(pos: Vector3, dist: float) -> Array:
	var out: Array = []
	var r := ceili(dist / GRID_CELL)
	var cx := floori(pos.x / GRID_CELL)
	var cz := floori(pos.z / GRID_CELL)
	for x in range(cx - r, cx + r + 1):
		for z in range(cz - r, cz + r + 1):
			var key := Vector2i(x, z)
			if _grid.has(key):
				out.append_array(_grid[key])
	return out


func find_nearest_enemy(unit: Unit, max_range: float) -> Entity:
	var best: Entity = null
	var best_d := INF
	for e in _units_near(unit.global_position, max_range + 4.0):
		if e.faction == unit.faction or e.is_dead:
			continue
		if e.is_air and not unit.air_ok:
			continue
		var d: float = unit._flat_dist(e.global_position) - e.radius
		if d < unit.min_range:
			continue
		if not e.is_operational():
			d += 6.0  # prefiere amenazas reales a vehículos vacíos
		if d <= max_range and d < best_d:
			best_d = d
			best = e
	for b in buildings:
		if b.faction == unit.faction or b.invulnerable or b.is_dead:
			continue
		var d: float = unit._flat_dist(b.global_position) - b.radius + 4.0
		if d <= max_range and d < best_d and d >= unit.min_range:
			best_d = d
			best = b
	return best


func find_enemy_near(faction: int, pos: Vector3, max_range: float) -> Entity:
	for u in _units_near(pos, max_range):
		if u.faction != faction and u.is_operational() and u.global_position.distance_to(pos) <= max_range:
			return u
	return null


## Empuje para que las unidades no se monten unas encima de otras ni sobre los edificios.
func separation_push(unit: Unit) -> Vector3:
	var push := Vector3.ZERO
	for other in _units_near(unit.global_position, 6.0):
		if other == unit or other.is_air != unit.is_air:
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
	if not unit.is_air:
		for b in buildings:
			var diff: Vector3 = unit.global_position - b.global_position
			diff.y = 0.0
			var min_d: float = unit.radius + b.radius
			var d := diff.length()
			if d < min_d and d > 0.01:
				push += diff.normalized() * 2.0 * (min_d - d) / min_d
	return push


func heal_around(medic: Unit, amount: float) -> void:
	for u in _units_near(medic.global_position, HEAL_RANGE):
		if u.faction == medic.faction and not u.is_vehicle and u.hp < u.max_hp and medic._flat_dist(u.global_position) <= HEAL_RANGE:
			u.heal(amount)


func repair_around(engineer: Unit, amount: float) -> void:
	for u in _units_near(engineer.global_position, REPAIR_RANGE + 4.0):
		if u.faction == engineer.faction and u.is_vehicle and u.hp < u.max_hp and engineer._flat_dist(u.global_position) <= REPAIR_RANGE + u.radius:
			u.heal(amount)
	for b in buildings:
		if b.faction == engineer.faction and b.complete and b.hp < b.max_hp and engineer._flat_dist(b.global_position) <= REPAIR_RANGE + b.radius:
			b.heal(amount)


func build_around(engineer: Unit, seconds: float) -> void:
	for b in buildings:
		if b.faction == engineer.faction and not b.complete and engineer._flat_dist(b.global_position) <= b.radius + GameData.BUILD_RANGE:
			b.add_build_progress(seconds)


func splash_damage(pos: Vector3, splash_radius: float, amount: float, dmg_type: String, attacker_faction: int, exclude: Entity) -> void:
	for u in _units_near(pos, splash_radius + 3.0):
		if u == exclude or u.is_dead or u.is_air or u.faction == attacker_faction:
			continue
		if Vector2(u.global_position.x - pos.x, u.global_position.z - pos.z).length() <= splash_radius + u.radius:
			u.take_damage(amount, dmg_type, attacker_faction)


func try_enter(u: Unit, vehicle: Unit) -> bool:
	var role := vehicle.seat_for(u)
	if role == "":
		return false
	vehicle.board(u, role)
	return true


func on_vehicle_stolen(vehicle: Unit, old_faction: int) -> void:
	if vehicle.faction == player_faction:
		notify("¡Has robado un %s!" % GameData.UNITS[vehicle.type_id].name.to_lower())
	elif old_faction == player_faction:
		notify("¡Te han robado un %s!" % GameData.UNITS[vehicle.type_id].name.to_lower())


func on_entity_died(e: Entity, killer_faction: int) -> void:
	units.erase(e)
	buildings.erase(e)
	selection.erase(e)
	if not (e is Unit and e.inside != null):
		spawn_explosion(e.global_position, e.radius)
	if killer_faction >= 0 and killer_faction != e.faction:
		var reward := e.get_reward()
		if e is Unit and war_zone.in_hot_zone(e.global_position):
			reward = int(e.cost * GameData.KILL_REWARD_HOT)
		factions[killer_faction].money += reward
		factions[killer_faction].kills += 1
		if killer_faction == player_faction and reward > 0:
			spawn_floating_text(e.global_position + Vector3(0, 2.5, 0), "+" + GameData.format_money(reward))


func on_team_won(faction: int) -> void:
	if game_over:
		return
	game_over = true
	winner = faction
	if _autotest:
		print("[autotest] GANA %s a los %d s" % [factions[faction].name, int(_match_time)])
		_print_status()
		get_tree().quit()
		return
	hud.show_end("¡VICTORIA!" if faction == player_faction else "DERROTA\nGana %s" % factions[faction].name)


func notify(text: String) -> void:
	if hud:
		hud.show_message(text)


# ---------------------------------------------------------------- Órdenes (cmd_*)

## Compra una unidad. Si with_crew y es un vehículo, compra también su conductor o piloto.
func cmd_buy(faction: int, unit_type: String, point_index: int, with_crew: bool) -> bool:
	if game_over:
		return false
	var cost: int = GameData.UNITS[unit_type].cost
	var vehicle := GameData.is_vehicle(unit_type)
	with_crew = with_crew and vehicle
	if with_crew:
		cost += GameData.UNITS[GameData.crew_type_for(unit_type)].cost
	if factions[faction].money < cost or pop_count(faction) >= GameData.POP_CAP:
		return false
	var points := deploy_points(faction)
	var point: Building = points[clampi(point_index, 0, points.size() - 1)]
	# Las aeronaves solo despegan desde la base.
	if GameData.is_air(unit_type):
		point = points[0]
	factions[faction].money -= cost
	_deploy_queue.append({
		"faction": faction, "type": unit_type, "building": point, "crew": with_crew,
		"time": GameData.UNITS[unit_type].deploy,
	})
	return true


func can_free_squad(faction: int) -> bool:
	var f: Dictionary = factions[faction]
	return f.money < GameData.FREE_SQUAD_THRESHOLD and f.free_cooldown <= 0.0 and not game_over


func cmd_free_squad(faction: int) -> bool:
	if not can_free_squad(faction):
		return false
	factions[faction].free_cooldown = GameData.FREE_SQUAD_COOLDOWN
	for t in GameData.FREE_SQUAD:
		_deploy_queue.append({"faction": faction, "type": t, "building": get_base(faction), "crew": false, "time": GameData.UNITS[t].deploy})
	return true


func _own(faction: int, list: Array) -> Array:
	return list.filter(func(u): return is_instance_valid(u) and u is Unit and u.faction == faction and u.is_active())


func cmd_move(faction: int, list: Array, pos: Vector3, attack: bool) -> void:
	var mine := _own(faction, list)
	var cols := ceili(sqrt(mine.size()))
	var i := 0
	for u in mine:
		var spacing := 2.2 if not u.is_vehicle else 6.0
		var offset := Vector3((i % cols) - (cols - 1) * 0.5, 0, (i / cols) - (cols - 1) * 0.5) * spacing
		u.order_move(clamp_to_map(pos + offset), attack)
		i += 1


func cmd_attack(faction: int, list: Array, target: Entity) -> void:
	for u in _own(faction, list):
		u.order_attack(target)


## Manda infantería a subir a un vehículo: primero quien pueda conducirlo, luego pasajeros.
func cmd_enter(faction: int, list: Array, vehicle: Unit) -> int:
	var mine := _own(faction, list).filter(func(u): return not u.is_vehicle)
	var sent := 0
	var crew_taken := vehicle.crew != null
	var seats := vehicle.free_seats() if vehicle.faction == faction else 0
	for u in mine:
		if not crew_taken and u.crew_kind == vehicle.crew_kind and (vehicle.faction == faction or vehicle.passengers.is_empty()):
			crew_taken = true
			u.order_enter(vehicle)
			sent += 1
	for u in mine:
		if u.enter_target == vehicle:
			continue
		if seats > 0:
			seats -= 1
			u.order_enter(vehicle)
			sent += 1
		else:
			u.order_move(vehicle.global_position, false)
	return sent


func cmd_unload(faction: int, list: Array) -> void:
	for u in _own(faction, list):
		if u.is_vehicle:
			u.unload_all()


func can_place_fob(faction: int, pos: Vector3) -> bool:
	if factions[faction].money < GameData.FOB_COST or fob_count(faction) >= GameData.FOB_MAX:
		return false
	if absf(pos.x) > MAP_HALF - 10.0 or absf(pos.z) > MAP_HALF - 10.0:
		return false
	for b in buildings:
		if b.global_position.distance_to(pos) < b.radius + 30.0:
			return false
	if not map.find_path(map.base_positions[faction], pos).size() > 0:
		return false
	return true


func cmd_build_fob(faction: int, list: Array, pos: Vector3) -> bool:
	var engineers := _own(faction, list).filter(func(u): return u.builder)
	if engineers.is_empty() or not can_place_fob(faction, pos):
		return false
	factions[faction].money -= GameData.FOB_COST
	var fob := spawn_building(faction, "fob", Vector3(pos.x, 0, pos.z))
	for e in engineers:
		e.order_build(fob)
	return true


# ---------------------------------------------------------------- Bucle

func _physics_process(delta: float) -> void:
	_rebuild_grid()
	if game_over:
		return
	_match_time += delta
	for f in factions:
		f.free_cooldown = maxf(0.0, f.free_cooldown - delta)
	for d in _deploy_queue.duplicate():
		d.time -= delta
		if d.time > 0.0:
			continue
		_deploy_queue.erase(d)
		var point: Building = d.building
		if not is_instance_valid(point) or point.is_dead:
			point = get_base(d.faction)
		var u := spawn_unit(d.faction, d.type, point.next_spawn_point())
		if d.crew:
			var c := spawn_unit(d.faction, GameData.crew_type_for(d.type), u.global_position)
			u.board(c, "crew")


func _process(delta: float) -> void:
	if not _autotest:
		return
	_autotest_report += delta
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--shot=") and _match_time >= 140.0 and not _shot_taken:
			_shot_taken = true
			cam_rig.focus(Vector3(30, 0, 60))
			cam_rig.zoom = 70.0
			cam_rig._apply_zoom()
			await get_tree().process_frame
			await get_tree().process_frame
			get_viewport().get_texture().get_image().save_png(arg.trim_prefix("--shot="))
	if _autotest_report >= 30.0:
		_autotest_report = 0.0
		_print_status()
	if _match_time > 2400.0 and not game_over:
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
		parts.append("%s pts=%d mg=%.0f %s bajas=%d %s fob=%d" % [
			f.name, war_zone.scores[i], war_zone.current_mg[i], GameData.format_money(f.money),
			f.kills, counts, fob_count(i)])
	print("[autotest t=%ds] %s" % [int(_match_time), "\n    ".join(parts)])


# ---------------------------------------------------------------- Efectos

func spawn_shot(from: Vector3, to: Vector3, dmg_type: String) -> void:
	var length := from.distance_to(to)
	if length < 0.1:
		return
	var thick := 0.05 if dmg_type == "bullet" else 0.15
	var color := Color(1.0, 0.85, 0.4) if dmg_type == "bullet" else Color(1.0, 0.55, 0.2)
	var tracer := MeshInstance3D.new()
	tracer.mesh = GameData.box(Vector3(thick, thick, length))
	tracer.material_override = GameData.unshaded(color)
	add_child(tracer)
	tracer.look_at_from_position((from + to) * 0.5, to, Vector3.UP if absf((to - from).normalized().y) < 0.99 else Vector3.FORWARD)
	get_tree().create_timer(0.06 if dmg_type == "bullet" else 0.12).timeout.connect(tracer.queue_free)
	if dmg_type != "bullet":
		spawn_explosion(to, 0.5)


func spawn_explosion(pos: Vector3, size: float) -> void:
	var mat := GameData.unshaded(Color(1.0, 0.6, 0.2, 0.9))
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
	var tw := ball.create_tween()
	tw.set_parallel(true)
	tw.tween_property(ball, "scale", Vector3.ONE * (1.0 + size * 2.5), 0.35)
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
	var mat := GameData.unshaded(color)
	var m := GameData.add_mesh(self, GameData.ring(1.0, 0.25), mat, Vector3(pos.x, 0.1, pos.z))
	m.scale.y = 0.2
	var tw := m.create_tween()
	tw.set_parallel(true)
	tw.tween_property(m, "scale", Vector3(0.2, 0.05, 0.2), 0.4)
	tw.tween_property(mat, "albedo_color:a", 0.0, 0.4)
	tw.chain().tween_callback(m.queue_free)


# ---------------------------------------------------------------- Controles del jugador

func selected_units() -> Array:
	return _own(player_faction, selection)


func player_buy(unit_type: String) -> void:
	if not cmd_buy(player_faction, unit_type, deploy_index, buy_with_crew):
		if pop_count(player_faction) >= GameData.POP_CAP:
			notify("Límite de unidades alcanzado (%d)" % GameData.POP_CAP)


func cycle_deploy_point() -> void:
	deploy_index = (deploy_index + 1) % deploy_points(player_faction).size()


func start_fob_placement() -> void:
	if selected_units().filter(func(u): return u.builder).is_empty():
		notify("Selecciona un ingeniero para construir")
		return
	_cancel_placement()
	placing_type = "fob"
	_ghost = MeshInstance3D.new()
	_ghost.mesh = GameData.cylinder(5.0, 2.0)
	_ghost.material_override = GameData.unshaded(Color(0.3, 1, 0.3, 0.35))
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
	_ghost.global_position = p + Vector3(0, 1.0, 0)
	var ok := can_place_fob(player_faction, p)
	(_ghost.material_override as StandardMaterial3D).albedo_color = Color(0.3, 1, 0.3, 0.35) if ok else Color(1, 0.2, 0.2, 0.35)


func _unhandled_input(event: InputEvent) -> void:
	if game_over:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				_cancel_placement()
				_set_selection([])
			KEY_H:
				cam_rig.focus(get_base(player_faction).global_position)
			KEY_Z:
				cam_rig.focus(war_zone.hot_center)
			KEY_E:
				cmd_unload(player_faction, selection)
			KEY_F:
				cmd_free_squad(player_faction)
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
			if p != null and cmd_build_fob(player_faction, selection, p):
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
				_click_select(mb.position, mb.shift_pressed, mb.double_click)
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


func _click_select(screen_pos: Vector2, add: bool, same_type: bool) -> void:
	var e := _entity_at(screen_pos)
	var list: Array = selection.duplicate() if add else []
	if e is Unit and e.faction == player_faction and not e in list:
		list.append(e)
		# Doble clic: selecciona todas las de ese tipo que se ven en pantalla.
		if same_type:
			var view := get_viewport().get_visible_rect()
			for u in units:
				if u.faction == player_faction and u.type_id == e.type_id and u.is_active() and not u in list:
					if view.has_point(cam_rig.camera.unproject_position(u.global_position)):
						list.append(u)
	_set_selection(list)


func _box_select(rect: Rect2, add: bool) -> void:
	var list: Array = selection.duplicate() if add else []
	var cam := cam_rig.camera
	for u in units:
		if u.faction != player_faction or not u.is_active() or u in list:
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
			if e is Unit and not e.is_active():
				continue
			var center: Vector3 = e.global_position + Vector3(0, minf(e.radius, 2.0), 0)
			if cam.is_position_behind(center):
				continue
			var sp := cam.unproject_position(center)
			var r_px := (cam.unproject_position(center + right * e.radius) - sp).length() + 6.0
			var d := sp.distance_to(screen_pos)
			if d <= r_px and d < best_d:
				best_d = d
				best = e
	return best


func _issue_order(screen_pos: Vector2, attack_move: bool) -> void:
	var mine := selected_units()
	if mine.is_empty():
		return
	var target := _entity_at(screen_pos)
	if target is Unit and target.is_vehicle and (target.faction == player_faction or target.crew == null):
		# Subir a un vehículo propio, o robar uno enemigo vacío.
		if cmd_enter(player_faction, mine, target) > 0:
			spawn_order_marker(target.global_position, Color(0.3, 0.7, 1.0, 0.9))
			return
	if target != null and target.faction != player_faction and not (target is Building and target.invulnerable):
		cmd_attack(player_faction, mine, target)
		spawn_order_marker(target.global_position, Color(1, 0.3, 0.2, 0.9))
		return
	var p = cam_rig.ground_point(screen_pos)
	if p == null:
		return
	cmd_move(player_faction, mine, p, attack_move)
	spawn_order_marker(p, Color(1, 0.3, 0.2, 0.9) if attack_move else Color(0.3, 1, 0.4, 0.9))
