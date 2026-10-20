class_name Unit
extends Entity
## Unidad: infantería o vehículo. Los vehículos necesitan tripulación (conductor o
## piloto) para moverse y disparar, y pueden llevar pasajeros.

## Distancia extra (sobre el alcance) a la que una unidad detecta enemigos.
const VISION_BONUS := 8.0
const TURN_SPEED := 7.0
const REPATH_TIME := 1.0

var speed: float = 4.0
var attack_range: float = 10.0
var min_range: float = 0.0
var damage: float = 10.0
var fire_rate: float = 1.0
var dmg_type: String = "bullet"
var splash: float = 0.0
var air_ok: bool = true
var cost: int = 0
var mg: int = 1
var is_vehicle: bool = false
var is_air: bool = false
var fly_height: float = 0.0
## Infantería: tipo de vehículo que sabe manejar. Vehículo: tripulación que necesita.
var crew_kind: String = ""
var seats: int = 0
var heal_rate: float = 0.0
var repair_rate: float = 0.0
var builder: bool = false

# Ocupación de vehículos
var crew: Unit = null
var passengers: Array = []
## Vehículo en el que va montada esta unidad (null si va a pie).
var inside: Unit = null

# Órdenes
var move_target: Vector3 = Vector3.ZERO
var has_move_target: bool = false
## Ataque-movimiento: avanza hacia el destino pero se detiene a pelear.
var attack_move: bool = false
var target: Entity = null
## true si el jugador ordenó atacar este objetivo concreto.
var forced_target: bool = false
var enter_target: Unit = null
var build_target: Building = null

var _path: PackedVector3Array = PackedVector3Array()
var _path_index: int = 0
var _path_dest: Vector3 = Vector3.INF
var _repath_timer: float = 0.0
var _cooldown: float = 0.0
var _scan_timer: float = 0.0
var _support_timer: float = 0.0
var _body: Node3D
var _muzzle: Node3D
var _rotors: Array = []


func setup(p_game: Node, p_faction: int, p_type: String) -> void:
	game = p_game
	faction = p_faction
	type_id = p_type
	var d: Dictionary = GameData.UNITS[p_type]
	max_hp = d.hp
	hp = max_hp
	speed = d.speed
	attack_range = d.range
	min_range = d.get("min_range", 0.0)
	damage = d.damage
	fire_rate = d.rate
	dmg_type = d.dmg_type
	splash = d.get("splash", 0.0)
	air_ok = d.air_ok
	armor = d.armor
	cost = d.cost
	mg = d.mg
	radius = d.radius
	is_vehicle = d.get("vehicle", false)
	is_air = d.has("fly")
	fly_height = d.get("fly", 0.0)
	crew_kind = d.get("crew", "")
	seats = d.get("seats", 0)
	heal_rate = d.get("heal", 0.0)
	repair_rate = d.get("repair", 0.0)
	builder = d.get("builder", false)
	_cooldown = randf() * fire_rate
	_init_team_materials()
	_build_visuals()


func get_reward() -> int:
	return int(cost * GameData.KILL_REWARD)


## En el campo y a la vista (no montado en un vehículo).
func is_active() -> bool:
	return not is_dead and inside == null


## Un vehículo sin tripulación no se mueve, no dispara y no suma medida de guerra.
func is_operational() -> bool:
	return not is_vehicle or crew != null


func is_idle() -> bool:
	return not has_move_target and target == null and enter_target == null and build_target == null


## Medida de guerra que aporta en la zona (incluye a quien vaya dentro).
func war_measure() -> float:
	if not is_vehicle:
		return float(mg)
	var total := 0.0
	if crew != null:
		total += mg + crew.mg
	for p in passengers:
		total += p.mg
	return total


func free_seats() -> int:
	return seats - passengers.size()


# ---------------------------------------------------------------- Órdenes

func _clear_orders() -> void:
	has_move_target = false
	attack_move = false
	target = null
	forced_target = false
	enter_target = null
	build_target = null
	_path = PackedVector3Array()
	_path_dest = Vector3.INF


func order_move(pos: Vector3, attack: bool = false) -> void:
	_clear_orders()
	move_target = pos
	has_move_target = true
	attack_move = attack


func order_attack(enemy: Entity) -> void:
	_clear_orders()
	target = enemy
	forced_target = true


func order_enter(vehicle: Unit) -> void:
	_clear_orders()
	enter_target = vehicle


func order_build(building: Building) -> void:
	_clear_orders()
	build_target = building


## "crew", "passenger" o "" si no puede subir.
func seat_for(u: Unit) -> String:
	if not is_vehicle or is_dead or u.is_vehicle:
		return ""
	if crew == null and u.crew_kind == crew_kind:
		# Robar: solo un vehículo enemigo completamente vacío.
		if u.faction == faction or passengers.is_empty():
			return "crew"
	if u.faction == faction and passengers.size() < seats:
		return "passenger"
	return ""


func board(u: Unit, role: String) -> void:
	if role == "crew":
		crew = u
		if u.faction != faction:
			var old := faction
			faction = u.faction
			apply_faction_colors()
			game.on_vehicle_stolen(self, old)
	else:
		passengers.append(u)
	u._clear_orders()
	u.inside = self
	u.visible = false
	u.set_selected(false)
	game.selection.erase(u)


func unload_all() -> void:
	var all: Array = passengers.duplicate()
	if crew != null:
		all.append(crew)
	passengers.clear()
	crew = null
	var i := 0
	for u in all:
		var angle := i * TAU / maxf(all.size(), 1)
		u.inside = null
		u.visible = true
		u.global_position = game.clamp_to_map(Vector3(global_position.x, 0, global_position.z) + Vector3(cos(angle), 0, sin(angle)) * (radius + 1.5))
		i += 1
	_clear_orders()


func die(give_reward: bool) -> void:
	if is_dead:
		return
	var all: Array = passengers.duplicate()
	if crew != null:
		all.append(crew)
	passengers.clear()
	crew = null
	super.die(give_reward)
	# Quien va dentro muere con el vehículo (y también da recompensa).
	for u in all:
		u.inside = null
		u.last_attacker_faction = last_attacker_faction
		u.die(give_reward)


# ---------------------------------------------------------------- Simulación

func _physics_process(delta: float) -> void:
	if is_dead or inside != null or game == null or game.game_over:
		return
	for u in passengers:
		u.global_position = global_position
	if crew != null:
		crew.global_position = global_position
	if not is_operational():
		if is_air and global_position.y > 0.0:
			global_position.y = maxf(0.0, global_position.y - 6.0 * delta)
		return

	_cooldown = maxf(0.0, _cooldown - delta)
	_repath_timer -= delta
	if target != null and (not is_instance_valid(target) or target.is_dead or (target is Unit and not target.is_active())):
		target = null
		forced_target = false
	if enter_target != null and (not is_instance_valid(enter_target) or enter_target.is_dead or enter_target.seat_for(self) == ""):
		enter_target = null
	if build_target != null and (not is_instance_valid(build_target) or build_target.is_dead or build_target.complete):
		build_target = null

	_support_timer -= delta
	if _support_timer <= 0.0:
		_support_timer = 0.5
		if heal_rate > 0.0:
			game.heal_around(self, heal_rate * 0.5)
		if repair_rate > 0.0:
			game.repair_around(self, repair_rate * 0.5)
		if builder:
			game.build_around(self, 0.5)

	var desired := Vector3.ZERO
	var engaging := false

	if enter_target != null:
		if _flat_dist(enter_target.global_position) <= enter_target.radius + radius + 1.2:
			game.try_enter(self, enter_target)
			return
		desired = _steer(enter_target.global_position)
	elif build_target != null:
		if _flat_dist(build_target.global_position) > build_target.radius + GameData.BUILD_RANGE * 0.5:
			desired = _steer(build_target.global_position)
	else:
		_scan_timer -= delta
		if target == null and _scan_timer <= 0.0 and (not has_move_target or attack_move) and damage > 0.0:
			_scan_timer = 0.3 + randf() * 0.2
			target = game.find_nearest_enemy(self, attack_range + VISION_BONUS)

		if target != null:
			var dist := _flat_dist(target.global_position) - target.radius
			if dist <= attack_range and dist >= min_range:
				engaging = true
				_face(target.global_position - global_position, delta)
				if _cooldown <= 0.0:
					_fire()
			elif forced_target or attack_move or not has_move_target:
				if dist > attack_range:
					desired = _steer(target.global_position)
				if not forced_target and dist > attack_range + VISION_BONUS * 2.0:
					target = null

		if not engaging and desired == Vector3.ZERO and has_move_target:
			if _flat_dist(move_target) < 0.8 + radius * 0.5:
				has_move_target = false
				attack_move = false
			else:
				desired = _steer(move_target)

	desired += game.separation_push(self) * speed * 0.8
	if desired.length() > speed:
		desired = desired.normalized() * speed
	if desired.length() > 0.05:
		global_position += desired * delta
		if not engaging:
			_face(desired, delta)
	var pos: Vector3 = game.clamp_to_map(global_position)
	pos.y = move_toward(global_position.y, fly_height, 8.0 * delta) if is_air else 0.0
	global_position = pos


func _process(delta: float) -> void:
	if is_operational():
		for r in _rotors:
			r.rotation.y += delta * 25.0


func _flat_dist(p: Vector3) -> float:
	return Vector2(global_position.x - p.x, global_position.z - p.z).length()


## Velocidad hacia un destino, siguiendo el camino calculado si es una unidad de tierra.
func _steer(dest: Vector3) -> Vector3:
	var pos := Vector3(global_position.x, 0, global_position.z)
	var flat := Vector3(dest.x, 0, dest.z)
	if is_air or pos.distance_to(flat) < 8.0:
		return (flat - pos).normalized() * speed if pos.distance_to(flat) > 0.1 else Vector3.ZERO
	var moved := _path_dest.distance_to(flat) if _path_dest != Vector3.INF else INF
	if _path.is_empty() or moved > 20.0 or (moved > 2.0 and _repath_timer <= 0.0):
		_path = game.find_path(pos, flat)
		if _path.is_empty():
			_path = PackedVector3Array([flat])
		_path_index = 0
		_path_dest = flat
		_repath_timer = REPATH_TIME
	while _path_index < _path.size() - 1 and pos.distance_to(Vector3(_path[_path_index].x, 0, _path[_path_index].z)) < 1.5 + radius * 0.5:
		_path_index += 1
	var next := _path[mini(_path_index, _path.size() - 1)]
	var dir := Vector3(next.x, 0, next.z) - pos
	return dir.normalized() * speed if dir.length() > 0.1 else Vector3.ZERO


func _face(dir: Vector3, delta: float) -> void:
	dir.y = 0.0
	if dir.length() < 0.01:
		return
	var yaw := atan2(-dir.x, -dir.z)
	_body.rotation.y = lerp_angle(_body.rotation.y, yaw, clampf(TURN_SPEED * delta, 0.0, 1.0))


func _fire() -> void:
	_cooldown = fire_rate * randf_range(0.9, 1.1)
	var from := _muzzle.global_position
	var to := target.global_position + Vector3(0, minf(target.radius, 1.2), 0)
	game.spawn_shot(from, to, dmg_type)
	var hit := target
	hit.take_damage(damage, dmg_type, faction)
	if splash > 0.0:
		game.splash_damage(to, splash, damage * 0.5, dmg_type, faction, hit)


# ---------------------------------------------------------------- Aspecto (provisional)

func _build_visuals() -> void:
	_body = Node3D.new()
	add_child(_body)
	var team := _team_mat
	var camo := _camo_mat
	var dark := GameData.make_material(Color(0.12, 0.12, 0.12))
	var bar_height := 2.3
	if not is_vehicle:
		var capsule := CapsuleMesh.new()
		capsule.radius = 0.28
		capsule.height = 1.5
		GameData.add_mesh(_body, capsule, camo, Vector3(0, 0.75, 0))
		var head := SphereMesh.new()
		head.radius = 0.21
		head.height = 0.42
		GameData.add_mesh(_body, head, team, Vector3(0, 1.62, 0))
		_muzzle = _marker(Vector3(0.2, 1.1, -0.9))
		match type_id:
			"driver":
				GameData.add_mesh(_body, GameData.box(Vector3(0.08, 0.1, 0.4)), dark, Vector3(0.2, 1.05, -0.2))
			"pilot":
				var helmet := SphereMesh.new()
				helmet.radius = 0.25
				helmet.height = 0.5
				GameData.add_mesh(_body, helmet, GameData.make_material(Color(0.85, 0.85, 0.8)), Vector3(0, 1.66, 0))
				GameData.add_mesh(_body, GameData.box(Vector3(0.08, 0.1, 0.4)), dark, Vector3(0.2, 1.05, -0.2))
			"assault":
				GameData.add_mesh(_body, GameData.box(Vector3(0.08, 0.1, 0.8)), dark, Vector3(0.2, 1.1, -0.35))
			"medic":
				GameData.add_mesh(_body, GameData.box(Vector3(0.08, 0.1, 0.7)), dark, Vector3(0.2, 1.1, -0.3))
				GameData.add_mesh(_body, GameData.box(Vector3(0.45, 0.45, 0.25)), GameData.make_material(Color(0.95, 0.95, 0.95)), Vector3(0, 1.1, 0.3))
				var red := GameData.make_material(Color(0.85, 0.1, 0.1))
				GameData.add_mesh(_body, GameData.box(Vector3(0.3, 0.08, 0.27)), red, Vector3(0, 1.1, 0.31))
				GameData.add_mesh(_body, GameData.box(Vector3(0.08, 0.3, 0.27)), red, Vector3(0, 1.1, 0.31))
			"engineer":
				GameData.add_mesh(_body, GameData.cylinder(0.11, 1.3), dark, Vector3(0.28, 1.4, -0.1), Vector3(PI / 2, 0, 0))
				GameData.add_mesh(_body, GameData.box(Vector3(0.4, 0.5, 0.3)), camo, Vector3(0, 1.0, 0.3))
				_muzzle.position = Vector3(0.28, 1.4, -0.8)
			"support":
				GameData.add_mesh(_body, GameData.box(Vector3(0.16, 0.18, 1.0)), dark, Vector3(0.22, 1.05, -0.4))
				GameData.add_mesh(_body, GameData.box(Vector3(0.3, 0.25, 0.3)), GameData.make_material(Color(0.3, 0.32, 0.2)), Vector3(0, 0.95, 0.3))
			"sniper":
				GameData.add_mesh(_body, GameData.box(Vector3(0.06, 0.08, 1.3)), dark, Vector3(0.2, 1.15, -0.55))
				_muzzle.position = Vector3(0.2, 1.15, -1.2)
	else:
		match type_id:
			"light":
				GameData.add_mesh(_body, GameData.box(Vector3(1.9, 0.8, 3.4)), camo, Vector3(0, 0.75, 0))
				GameData.add_mesh(_body, GameData.box(Vector3(1.7, 0.5, 1.2)), team, Vector3(0, 1.4, 0.3))
				_wheels(dark, 0.95, [-1.1, 1.1], 0.42)
				GameData.add_mesh(_body, GameData.box(Vector3(0.12, 0.12, 1.1)), dark, Vector3(0, 1.9, -0.3))
				_muzzle = _marker(Vector3(0, 1.9, -0.9))
				bar_height = 2.8
			"apc":
				GameData.add_mesh(_body, GameData.box(Vector3(2.6, 1.4, 5.6)), camo, Vector3(0, 1.2, 0))
				_wheels(dark, 1.35, [-1.9, -0.65, 0.65, 1.9], 0.55)
				GameData.add_mesh(_body, GameData.box(Vector3(1.1, 0.5, 1.2)), team, Vector3(0, 2.15, -0.6))
				GameData.add_mesh(_body, GameData.cylinder(0.08, 1.4), dark, Vector3(0, 2.2, -1.7), Vector3(PI / 2, 0, 0))
				_muzzle = _marker(Vector3(0, 2.2, -2.4))
				bar_height = 3.3
			"tank":
				GameData.add_mesh(_body, GameData.box(Vector3(2.6, 0.9, 4.6)), camo, Vector3(0, 0.85, 0))
				for x in [-1.4, 1.4]:
					GameData.add_mesh(_body, GameData.box(Vector3(0.6, 0.85, 4.8)), dark, Vector3(x, 0.45, 0))
				GameData.add_mesh(_body, GameData.box(Vector3(1.8, 0.7, 2.1)), team, Vector3(0, 1.65, 0.3))
				GameData.add_mesh(_body, GameData.cylinder(0.14, 3.0), dark, Vector3(0, 1.65, -2.0), Vector3(PI / 2, 0, 0))
				_muzzle = _marker(Vector3(0, 1.65, -3.5))
				bar_height = 3.2
			"artillery":
				GameData.add_mesh(_body, GameData.box(Vector3(2.4, 1.0, 5.2)), camo, Vector3(0, 1.0, 0))
				GameData.add_mesh(_body, GameData.box(Vector3(2.2, 1.0, 1.4)), team, Vector3(0, 1.9, -1.9))
				_wheels(dark, 1.25, [-1.7, 0.4, 1.8], 0.5)
				GameData.add_mesh(_body, GameData.cylinder(0.18, 5.0), dark, Vector3(0, 2.9, -0.6), Vector3(deg_to_rad(55), 0, 0))
				_muzzle = _marker(Vector3(0, 4.9, -2.0))
				bar_height = 4.6
			"drone":
				GameData.add_mesh(_body, GameData.box(Vector3(0.7, 0.35, 1.3)), team, Vector3.ZERO)
				for a in [45.0, 135.0, 225.0, 315.0]:
					var dir := Vector3(sin(deg_to_rad(a)), 0, cos(deg_to_rad(a)))
					GameData.add_mesh(_body, GameData.box(Vector3(0.1, 0.1, 1.2)), dark, dir * 0.6, Vector3(0, deg_to_rad(a), 0))
					var rotor := Node3D.new()
					rotor.position = dir * 1.1 + Vector3(0, 0.2, 0)
					_body.add_child(rotor)
					GameData.add_mesh(rotor, GameData.box(Vector3(0.9, 0.03, 0.1)), dark, Vector3.ZERO)
					_rotors.append(rotor)
				_muzzle = _marker(Vector3(0, -0.2, -0.7))
				bar_height = 1.4
			"heli_transport":
				GameData.add_mesh(_body, GameData.box(Vector3(2.2, 2.2, 6.5)), camo, Vector3.ZERO)
				GameData.add_mesh(_body, GameData.box(Vector3(0.6, 0.8, 5.0)), camo, Vector3(0, 0.6, 5.5))
				GameData.add_mesh(_body, GameData.box(Vector3(2.25, 0.4, 2.0)), team, Vector3(0, 0.3, -2.0))
				for z in [-2.4, 2.4]:
					_rotor(dark, Vector3(0, 1.4, z), 7.0)
				_muzzle = _marker(Vector3(1.2, 0, -1.0))
				bar_height = 2.5
			"heli_attack":
				GameData.add_mesh(_body, GameData.box(Vector3(1.2, 1.5, 5.5)), camo, Vector3.ZERO)
				GameData.add_mesh(_body, GameData.box(Vector3(0.5, 0.6, 5.0)), camo, Vector3(0, 0.3, 5.0))
				GameData.add_mesh(_body, GameData.box(Vector3(3.6, 0.15, 0.8)), team, Vector3(0, -0.2, 0))
				for x in [-1.6, 1.6]:
					GameData.add_mesh(_body, GameData.cylinder(0.22, 1.4), dark, Vector3(x, -0.45, -0.2), Vector3(PI / 2, 0, 0))
				_rotor(dark, Vector3(0, 1.0, 0), 8.0)
				_muzzle = _marker(Vector3(1.6, -0.45, -1.0))
				bar_height = 2.4
	_build_common_visuals(bar_height)
	if is_air and _hp_root:
		_hp_root.position.y = bar_height


func _wheels(mat: Material, x: float, zs: Array, r: float) -> void:
	for side in [-x, x]:
		for z in zs:
			GameData.add_mesh(_body, GameData.cylinder(r, 0.3), mat, Vector3(side, r, z), Vector3(0, 0, PI / 2))


func _rotor(mat: Material, pos: Vector3, length: float) -> void:
	var rotor := Node3D.new()
	rotor.position = pos
	_body.add_child(rotor)
	GameData.add_mesh(rotor, GameData.box(Vector3(length, 0.05, 0.3)), mat, Vector3.ZERO)
	GameData.add_mesh(rotor, GameData.box(Vector3(0.3, 0.05, length)), mat, Vector3.ZERO)
	_rotors.append(rotor)


func _marker(pos: Vector3) -> Node3D:
	var m := Node3D.new()
	m.position = pos
	_body.add_child(m)
	return m
