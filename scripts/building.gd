class_name Building
extends Entity
## Edificio: base de salida (indestructible) o zona de despliegue avanzada (FOB),
## que construyen los ingenieros. Las unidades compradas aparecen en ellos.

var size: Vector3 = Vector3(6, 3, 6)
var complete: bool = true
var build_progress: float = 0.0
var invulnerable: bool = false
var _parts: Node3D
var _spawn_count: int = 0


func setup(p_game: Node, p_faction: int, p_type: String) -> void:
	game = p_game
	faction = p_faction
	type_id = p_type
	armor = "building"
	if p_type == "base":
		max_hp = 10000.0
		size = Vector3(22, 4, 22)
		invulnerable = true
	else:
		max_hp = 1500.0
		size = Vector3(9, 2.5, 9)
		complete = false
	hp = max_hp if complete else max_hp * 0.2
	radius = maxf(size.x, size.z) * 0.55
	_init_team_materials()
	_build_visuals()


func get_reward() -> int:
	return GameData.FOB_COST / 2


func take_damage(amount: float, dmg_type: String, attacker_faction: int) -> void:
	if invulnerable:
		return
	super.take_damage(amount, dmg_type, attacker_faction)


func add_build_progress(seconds: float) -> void:
	if complete:
		return
	build_progress += seconds
	hp = minf(max_hp, hp + max_hp * 0.8 * seconds / GameData.FOB_BUILD_TIME)
	_parts.scale.y = clampf(build_progress / GameData.FOB_BUILD_TIME, 0.1, 1.0)
	_update_hp_bar()
	if build_progress >= GameData.FOB_BUILD_TIME:
		complete = true
		_parts.scale.y = 1.0


## Punto libre alrededor del edificio donde aparece una unidad nueva.
func next_spawn_point() -> Vector3:
	_spawn_count += 1
	var angle := _spawn_count * 2.4
	var dist := radius + 3.0 + (_spawn_count % 5) * 2.0
	var to_center := -global_position.normalized() if global_position.length() > 1.0 else Vector3.FORWARD
	var dir := to_center.rotated(Vector3.UP, sin(angle) * 1.2)
	return global_position + dir * dist


func _build_visuals() -> void:
	_parts = Node3D.new()
	add_child(_parts)
	var sand := GameData.make_material(Color(0.6, 0.55, 0.43))
	var dark := GameData.make_material(Color(0.22, 0.22, 0.2))
	if type_id == "base":
		# Plataforma, hangar, torre y bandera.
		GameData.add_mesh(_parts, GameData.box(Vector3(size.x, 0.3, size.z)), GameData.make_material(Color(0.35, 0.35, 0.33)), Vector3(0, 0.15, 0))
		GameData.add_mesh(_parts, GameData.box(Vector3(9, 5, 7)), sand, Vector3(-5, 2.5, 5))
		GameData.add_mesh(_parts, GameData.box(Vector3(9.4, 0.5, 7.4)), _team_mat, Vector3(-5, 5.2, 5))
		GameData.add_mesh(_parts, GameData.box(Vector3(3, 9, 3)), sand, Vector3(7, 4.5, -7))
		GameData.add_mesh(_parts, GameData.box(Vector3(4, 1.5, 4)), _team_mat, Vector3(7, 9.5, -7))
		GameData.add_mesh(_parts, GameData.cylinder(0.1, 8.0), dark, Vector3(-8, 4, -8))
		GameData.add_mesh(_parts, GameData.box(Vector3(2.4, 1.4, 0.06)), _team_mat, Vector3(-6.7, 7.2, -8))
		var pad := GameData.ring(4.0, 0.4)
		GameData.add_mesh(_parts, pad, GameData.unshaded(Color(0.9, 0.9, 0.9)), Vector3(5, 0.35, 5))
	else:
		# Sacos terreros en anillo, tienda de mando y antena.
		for i in 10:
			var a := i * TAU / 10.0
			GameData.add_mesh(_parts, GameData.box(Vector3(2.6, 1.0, 0.9)), sand, Vector3(cos(a), 0, sin(a)) * 4.2 + Vector3(0, 0.5, 0), Vector3(0, -a + PI / 2, 0))
		GameData.add_mesh(_parts, GameData.box(Vector3(3.5, 2.2, 3.0)), _camo_mat, Vector3(0, 1.1, 0))
		GameData.add_mesh(_parts, GameData.box(Vector3(3.7, 0.3, 3.2)), _team_mat, Vector3(0, 2.3, 0))
		GameData.add_mesh(_parts, GameData.cylinder(0.06, 5.0), dark, Vector3(1.4, 2.5, 1.2))
		_parts.scale.y = 0.1
	_build_common_visuals(size.y + 2.0)
