class_name Building
extends Entity
## Edificio: tiene vida y fabrica unidades de su cola de producción.

var size: Vector3 = Vector3(6, 3, 6)
var produces: Array = []
var queue: Array = []
var progress: float = 0.0
var rally_point: Vector3 = Vector3.ZERO
var reward: int = 0
var _spawn_count: int = 0


func setup(p_game: Node, p_faction: int, p_type: String) -> void:
	game = p_game
	faction = p_faction
	type_id = p_type
	var d: Dictionary = GameData.BUILDINGS[p_type]
	max_hp = d.hp
	hp = max_hp
	armor = "building"
	size = d.size
	produces = d.produces
	reward = d.reward
	radius = maxf(size.x, size.z) * 0.55
	_build_visuals()


func get_reward() -> int:
	return reward


func can_produce(unit_type: String) -> bool:
	return unit_type in produces and queue.size() < GameData.MAX_QUEUE


func enqueue(unit_type: String) -> void:
	queue.append(unit_type)


func current_progress() -> float:
	if queue.is_empty():
		return 0.0
	return progress / float(GameData.UNITS[queue[0]].time)


func _process(delta: float) -> void:
	if is_dead or game == null or game.game_over or queue.is_empty():
		return
	progress += delta
	var unit_type: String = queue[0]
	if progress >= GameData.UNITS[unit_type].time:
		progress = 0.0
		queue.pop_front()
		var dir := (rally_point - global_position)
		dir.y = 0.0
		dir = dir.normalized() if dir.length() > 0.1 else Vector3.FORWARD
		var spawn_pos := global_position + dir * (radius + 1.5)
		var unit: Unit = game.spawn_unit(faction, unit_type, spawn_pos)
		# Reparte las unidades alrededor del punto de reunión para que no se amontonen.
		_spawn_count += 1
		var angle := _spawn_count * 2.4
		var offset := Vector3(cos(angle), 0, sin(angle)) * (1.5 + (_spawn_count % 6) * 0.8)
		unit.order_move(rally_point + offset)


func _build_visuals() -> void:
	var col: Color = GameData.FACTIONS[faction].color
	var wall := GameData.make_material(Color(0.55, 0.52, 0.45))
	var roof := GameData.make_material(col.darkened(0.2))
	var dark := GameData.make_material(Color(0.2, 0.2, 0.2))
	GameData.add_mesh(self, GameData.box(size), wall, Vector3(0, size.y * 0.5, 0))
	GameData.add_mesh(self, GameData.box(Vector3(size.x + 0.4, 0.4, size.z + 0.4)), roof, Vector3(0, size.y + 0.2, 0))
	if type_id == "hq":
		GameData.add_mesh(self, GameData.box(Vector3(2.5, 1.6, 2.5)), wall, Vector3(0, size.y + 1.2, 0))
		GameData.add_mesh(self, GameData.cylinder(0.08, 5.0), dark, Vector3(size.x * 0.35, size.y + 2.5, size.z * 0.35))
		var flag := GameData.make_material(col)
		GameData.add_mesh(self, GameData.box(Vector3(1.4, 0.9, 0.05)), flag, Vector3(size.x * 0.35 + 0.75, size.y + 4.4, size.z * 0.35))
	else:
		GameData.add_mesh(self, GameData.box(Vector3(size.x * 0.6, size.y * 0.8, 0.2)), dark, Vector3(0, size.y * 0.4, -size.z * 0.5 - 0.05))
		GameData.add_mesh(self, GameData.cylinder(0.5, 3.0), wall, Vector3(size.x * 0.3, size.y + 1.5, size.z * 0.2))
	_build_common_visuals(size.y + 1.2)
