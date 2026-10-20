class_name WarZone
extends Node3D
## Zona de guerra central y hot zone móvil. Cada pocos segundos puntúa el equipo con
## más medida de guerra dentro de la zona (lo que está en la hot zone cuenta doble).

var game: Node
var hot_center: Vector3 = Vector3.ZERO
var next_hot_center: Vector3 = Vector3.ZERO
var hot_timer: float = GameData.HOT_ZONE_MOVE_TIME
var scores: Array = [0, 0, 0]
## Medida de guerra actual de cada equipo dentro de la zona (ya con el doble de la hot zone).
var current_mg: Array = [0.0, 0.0, 0.0]
## Equipo que está puntuando ahora (-1 si nadie: empate o zona vacía).
var leader: int = -1

var _score_timer: float = GameData.SCORE_INTERVAL
var _mg_timer: float = 0.0
var _rng := RandomNumberGenerator.new()
var _hot: Node3D
var _next: Node3D


func setup(p_game: Node, zone_seed: int) -> void:
	game = p_game
	_rng.seed = zone_seed
	GameData.add_mesh(self, GameData.ring(GameData.WAR_ZONE_RADIUS, 1.4), GameData.unshaded(Color(1.0, 0.6, 0.15, 0.8)), Vector3(0, 0.08, 0)).scale.y = 0.15
	var war_disc := GameData.cylinder(GameData.WAR_ZONE_RADIUS, 0.02)
	war_disc.radial_segments = 64
	GameData.add_mesh(self, war_disc, GameData.unshaded(Color(1.0, 0.6, 0.15, 0.05)), Vector3(0, 0.05, 0))

	_hot = Node3D.new()
	add_child(_hot)
	GameData.add_mesh(_hot, GameData.ring(GameData.HOT_ZONE_RADIUS, 1.0), GameData.unshaded(Color(1.0, 0.15, 0.1, 0.9)), Vector3(0, 0.1, 0)).scale.y = 0.15
	var hot_disc := GameData.cylinder(GameData.HOT_ZONE_RADIUS, 0.02)
	hot_disc.radial_segments = 48
	GameData.add_mesh(_hot, hot_disc, GameData.unshaded(Color(1.0, 0.15, 0.1, 0.15)), Vector3(0, 0.07, 0))

	_next = Node3D.new()
	add_child(_next)
	GameData.add_mesh(_next, GameData.ring(GameData.HOT_ZONE_RADIUS, 0.6), GameData.unshaded(Color(1.0, 0.9, 0.2, 0.7)), Vector3(0, 0.1, 0)).scale.y = 0.15
	_next.visible = false

	hot_center = _pick_hot_center()
	_hot.position = hot_center


func _pick_hot_center() -> Vector3:
	var angle := _rng.randf() * TAU
	var dist := sqrt(_rng.randf()) * (GameData.WAR_ZONE_RADIUS - GameData.HOT_ZONE_RADIUS)
	return Vector3(cos(angle), 0, sin(angle)) * dist


func in_war_zone(pos: Vector3) -> bool:
	return Vector2(pos.x, pos.z).length() <= GameData.WAR_ZONE_RADIUS


func in_hot_zone(pos: Vector3) -> bool:
	return Vector2(pos.x - hot_center.x, pos.z - hot_center.z).length() <= GameData.HOT_ZONE_RADIUS


## true durante el aviso previo a que la hot zone cambie de sitio.
func is_moving_soon() -> bool:
	return _next.visible


func _physics_process(delta: float) -> void:
	if game == null or game.game_over:
		return
	hot_timer -= delta
	if hot_timer <= GameData.HOT_ZONE_WARNING and not _next.visible:
		next_hot_center = _pick_hot_center()
		_next.position = next_hot_center
		_next.visible = true
		game.notify("La hot zone se moverá en %d segundos" % int(GameData.HOT_ZONE_WARNING))
	if hot_timer <= 0.0:
		hot_center = next_hot_center
		_hot.position = hot_center
		_next.visible = false
		hot_timer = GameData.HOT_ZONE_MOVE_TIME
		game.notify("¡La hot zone se ha movido!")

	_mg_timer -= delta
	if _mg_timer <= 0.0:
		_mg_timer = 0.5
		_compute_mg()

	_score_timer -= delta
	if _score_timer <= 0.0:
		_score_timer = GameData.SCORE_INTERVAL
		_compute_mg()
		if leader >= 0:
			scores[leader] += 1
			if scores[leader] >= GameData.SCORE_TO_WIN:
				game.on_team_won(leader)


func _compute_mg() -> void:
	current_mg = [0.0, 0.0, 0.0]
	for u in game.units:
		if u.is_dead or u.inside != null:
			continue
		if not in_war_zone(u.global_position):
			continue
		var value: float = u.war_measure()
		if in_hot_zone(u.global_position):
			value *= GameData.HOT_ZONE_MULT
		current_mg[u.faction] += value
	leader = -1
	var best := 0.0
	for i in current_mg.size():
		if current_mg[i] > best:
			best = current_mg[i]
			leader = i
		elif current_mg[i] == best and best > 0.0:
			leader = -1
