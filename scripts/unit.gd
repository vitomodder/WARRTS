class_name Unit
extends Entity
## Unidad móvil: se mueve, busca enemigos cercanos y dispara.

## Distancia extra (sobre el alcance) a la que una unidad detecta enemigos.
const VISION_BONUS := 7.0
const TURN_SPEED := 8.0

var speed: float = 4.0
var attack_range: float = 10.0
var damage: float = 10.0
var fire_rate: float = 1.0
var dmg_type: String = "bullet"
var cost: int = 100

var move_target: Vector3 = Vector3.ZERO
var has_move_target: bool = false
## Ataque-movimiento: avanza hacia el destino pero se detiene a pelear.
var attack_move: bool = false
var target: Entity = null
## true si el jugador ordenó atacar este objetivo concreto.
var forced_target: bool = false

var _cooldown: float = 0.0
var _scan_timer: float = 0.0
var _body: Node3D
var _muzzle: Node3D


func setup(p_game: Node, p_faction: int, p_type: String) -> void:
	game = p_game
	faction = p_faction
	type_id = p_type
	var d: Dictionary = GameData.UNITS[p_type]
	max_hp = d.hp
	hp = max_hp
	speed = d.speed
	attack_range = d.range
	damage = d.damage
	fire_rate = d.rate
	dmg_type = d.dmg_type
	armor = d.armor
	cost = d.cost
	radius = d.radius
	_cooldown = randf() * fire_rate
	_build_visuals()


func get_reward() -> int:
	return int(cost * GameData.KILL_REWARD)


func is_idle() -> bool:
	return not has_move_target and target == null


func order_move(pos: Vector3, attack: bool = false) -> void:
	move_target = pos
	has_move_target = true
	attack_move = attack
	target = null
	forced_target = false


func order_attack(enemy: Entity) -> void:
	target = enemy
	forced_target = true
	has_move_target = false
	attack_move = false


func _physics_process(delta: float) -> void:
	if is_dead or game == null or game.game_over:
		return
	_cooldown = maxf(0.0, _cooldown - delta)
	if target != null and (not is_instance_valid(target) or target.is_dead):
		target = null
		forced_target = false

	_scan_timer -= delta
	if target == null and _scan_timer <= 0.0 and (not has_move_target or attack_move):
		_scan_timer = 0.25 + randf() * 0.15
		target = game.find_nearest_enemy(self, attack_range + VISION_BONUS)

	var desired := Vector3.ZERO
	var engaging := false
	if target != null:
		var to_t := target.global_position - global_position
		to_t.y = 0.0
		var dist := to_t.length() - target.radius
		if dist <= attack_range:
			engaging = true
			_face(to_t, delta)
			if _cooldown <= 0.0:
				_fire()
		elif forced_target or attack_move or not has_move_target:
			desired = to_t.normalized() * speed
			if not forced_target and dist > attack_range + VISION_BONUS * 2.0:
				target = null

	if not engaging and desired == Vector3.ZERO and has_move_target:
		var to_m := move_target - global_position
		to_m.y = 0.0
		if to_m.length() < 0.5 + radius * 0.3:
			has_move_target = false
			attack_move = false
		else:
			desired = to_m.normalized() * speed

	desired += game.separation_push(self) * speed * 0.8
	if desired.length() > 0.05:
		if desired.length() > speed:
			desired = desired.normalized() * speed
		global_position += desired * delta
		global_position = game.clamp_to_map(global_position)
		if not engaging:
			_face(desired, delta)


func _face(dir: Vector3, delta: float) -> void:
	if dir.length() < 0.01:
		return
	var yaw := atan2(-dir.x, -dir.z)
	_body.rotation.y = lerp_angle(_body.rotation.y, yaw, clampf(TURN_SPEED * delta, 0.0, 1.0))


func _fire() -> void:
	_cooldown = fire_rate * randf_range(0.9, 1.1)
	var from := _muzzle.global_position
	var to := target.global_position + Vector3(0, minf(target.radius, 1.2), 0)
	game.spawn_shot(from, to, dmg_type)
	target.take_damage(damage, dmg_type, faction)


func _build_visuals() -> void:
	_body = Node3D.new()
	add_child(_body)
	var col: Color = GameData.FACTIONS[faction].color
	var team := GameData.make_material(col.darkened(0.15))
	var dark := GameData.make_material(Color(0.12, 0.12, 0.12))
	var olive := GameData.make_material(Color(0.32, 0.34, 0.24).lerp(col, 0.25))
	var bar_height := 2.2
	match type_id:
		"infantry", "at":
			var capsule := CapsuleMesh.new()
			capsule.radius = 0.28
			capsule.height = 1.5
			GameData.add_mesh(_body, capsule, olive, Vector3(0, 0.75, 0))
			var head := SphereMesh.new()
			head.radius = 0.2
			head.height = 0.4
			GameData.add_mesh(_body, head, team, Vector3(0, 1.6, 0))
			if type_id == "at":
				GameData.add_mesh(_body, GameData.cylinder(0.12, 1.3), dark, Vector3(0.25, 1.35, -0.1), Vector3(PI / 2, 0, 0))
				_muzzle = _marker(Vector3(0.25, 1.35, -0.8))
			else:
				GameData.add_mesh(_body, GameData.box(Vector3(0.08, 0.1, 0.8)), dark, Vector3(0.2, 1.1, -0.35))
				_muzzle = _marker(Vector3(0.2, 1.1, -0.8))
		"jeep":
			GameData.add_mesh(_body, GameData.box(Vector3(1.8, 0.8, 3.2)), olive, Vector3(0, 0.75, 0))
			GameData.add_mesh(_body, GameData.box(Vector3(1.6, 0.5, 1.2)), team, Vector3(0, 1.4, 0.3))
			for x in [-0.95, 0.95]:
				for z in [-1.0, 1.0]:
					GameData.add_mesh(_body, GameData.cylinder(0.42, 0.3), dark, Vector3(x, 0.42, z), Vector3(0, 0, PI / 2))
			GameData.add_mesh(_body, GameData.box(Vector3(0.12, 0.12, 1.1)), dark, Vector3(0, 1.9, -0.3))
			_muzzle = _marker(Vector3(0, 1.9, -0.9))
			bar_height = 2.8
		"tank":
			GameData.add_mesh(_body, GameData.box(Vector3(2.6, 0.9, 4.4)), olive, Vector3(0, 0.85, 0))
			for x in [-1.35, 1.35]:
				GameData.add_mesh(_body, GameData.box(Vector3(0.6, 0.8, 4.6)), dark, Vector3(x, 0.45, 0))
			GameData.add_mesh(_body, GameData.box(Vector3(1.7, 0.65, 2.0)), team, Vector3(0, 1.62, 0.3))
			GameData.add_mesh(_body, GameData.cylinder(0.13, 2.8), dark, Vector3(0, 1.62, -1.9), Vector3(PI / 2, 0, 0))
			_muzzle = _marker(Vector3(0, 1.62, -3.3))
			bar_height = 3.0
	_build_common_visuals(bar_height)


func _marker(pos: Vector3) -> Node3D:
	var m := Node3D.new()
	m.position = pos
	_body.add_child(m)
	return m
