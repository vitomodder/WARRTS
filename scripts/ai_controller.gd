class_name AiController
extends Node
## IA básica de un equipo: compra un ejército variado, construye una zona de despliegue
## avanzada y manda a sus tropas a pelear por la hot zone.

## Peso de cada unidad al decidir qué comprar.
const BUY_WEIGHTS := {
	"assault": 4.0, "support": 2.0, "medic": 1.0, "engineer": 1.2, "sniper": 1.0,
	"light": 2.0, "apc": 1.2, "tank": 1.5, "artillery": 0.6,
	"drone": 0.8, "heli_attack": 0.8, "heli_transport": 0.2,
}

var game: Node
var faction: int = 0
var _think_timer: float = 1.0
var _regroup_timer: float = 20.0
var _last_hot_center: Vector3 = Vector3.INF


func setup(p_game: Node, p_faction: int) -> void:
	game = p_game
	faction = p_faction
	_think_timer = randf_range(0.5, 2.0)


func _process(delta: float) -> void:
	if game.game_over:
		return
	_think_timer -= delta
	_regroup_timer -= delta
	if _think_timer > 0.0:
		return
	_think_timer = randf_range(1.0, 1.8)
	if game.can_free_squad(faction):
		game.cmd_free_squad(faction)
	_spend_money()
	_build_fob()
	_command_army()


func _spend_money() -> void:
	var money: int = game.factions[faction].money
	var options: Array = []
	var total := 0.0
	for t in BUY_WEIGHTS:
		var cost: int = GameData.UNITS[t].cost
		if GameData.is_vehicle(t):
			cost += GameData.UNITS[GameData.crew_type_for(t)].cost
		if cost <= money:
			options.append(t)
			total += BUY_WEIGHTS[t]
	if options.is_empty():
		return
	var roll := randf() * total
	for t in options:
		roll -= BUY_WEIGHTS[t]
		if roll <= 0.0:
			var points: Array = game.deploy_points(faction)
			game.cmd_buy(faction, t, points.size() - 1, true)
			return


func _build_fob() -> void:
	if game.fob_count(faction) >= 1 or game.factions[faction].money < 150000:
		return
	var engineer: Unit = null
	for u in game.active_units_of(faction):
		if u.builder and u.build_target == null:
			engineer = u
			break
	if engineer == null:
		return
	var base_pos: Vector3 = game.map.base_positions[faction]
	var dir := base_pos.normalized()
	for i in 6:
		var side := dir.rotated(Vector3.UP, PI / 2.0) * randf_range(-40.0, 40.0)
		var pos := dir * (GameData.WAR_ZONE_RADIUS + randf_range(40.0, 70.0)) + side
		if game.cmd_build_fob(faction, [engineer], pos):
			return


func _command_army() -> void:
	var wz: WarZone = game.war_zone
	var hot_moved := _last_hot_center.distance_to(wz.hot_center) > 1.0 if _last_hot_center != Vector3.INF else true
	_last_hot_center = wz.hot_center
	var regroup := _regroup_timer <= 0.0 or hot_moved
	if regroup:
		_regroup_timer = 20.0
	for u in game.active_units_of(faction):
		if not u.is_operational() or u.build_target != null or u.enter_target != null:
			continue
		if u.target != null and not regroup:
			continue
		var heading_ok: bool = u.has_move_target and wz.in_hot_zone(u.move_target)
		if not u.is_idle() and (heading_ok or not regroup):
			continue
		if u.is_idle() and wz.in_hot_zone(u.global_position) and not hot_moved:
			continue
		u.order_move(_point_for(u), true)


## Punto de destino: dentro de la hot zone; la artillería se queda atrás.
func _point_for(u: Unit) -> Vector3:
	var wz: WarZone = game.war_zone
	if u.type_id == "artillery":
		var back: Vector3 = (game.map.base_positions[faction] - wz.hot_center).normalized()
		return wz.hot_center + back * 50.0
	var angle := randf() * TAU
	var dist := sqrt(randf()) * GameData.HOT_ZONE_RADIUS * 0.8
	return wz.hot_center + Vector3(cos(angle), 0, sin(angle)) * dist
