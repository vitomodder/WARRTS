class_name AiController
extends Node
## IA básica de una facción: gasta el dinero, defiende su base y ataca en oleadas.

var game: Node
var faction: int = 0
var wave_size: int = 5
var _think_timer: float = 1.0


func setup(p_game: Node, p_faction: int) -> void:
	game = p_game
	faction = p_faction
	_think_timer = randf_range(0.5, 2.0)


func _process(delta: float) -> void:
	if game.game_over or not game.factions[faction].alive:
		return
	_think_timer -= delta
	if _think_timer > 0.0:
		return
	_think_timer = randf_range(1.0, 1.8)
	_spend_money()
	_command_army()


func _spend_money() -> void:
	var money: int = game.factions[faction].money
	var factory_cost: int = GameData.BUILDINGS.factory.cost
	if not game.has_building(faction, "factory") and money >= factory_cost:
		# Primero ahorra para la fábrica si aún le quedan unidades con las que defenderse.
		var hq: Building = game.get_hq(faction)
		for i in 10:
			var angle := randf() * TAU
			var pos := hq.global_position + Vector3(cos(angle), 0, sin(angle)) * randf_range(12.0, 20.0)
			if game.try_place_building(faction, "factory", pos):
				return
	elif not game.has_building(faction, "factory") and game.units_of(faction).size() >= 6:
		return

	var weights := {"infantry": 3.0, "at": 2.0, "jeep": 2.0, "tank": 2.5}
	var options: Array = []
	var total := 0.0
	for t in weights:
		if game.factions[faction].money >= GameData.UNITS[t].cost and game.find_producer(faction, t) != null:
			options.append(t)
			total += weights[t]
	if options.is_empty():
		return
	var roll := randf() * total
	for t in options:
		roll -= weights[t]
		if roll <= 0.0:
			game.try_buy_unit(faction, t)
			return


func _command_army() -> void:
	var hq: Building = game.get_hq(faction)
	if hq == null:
		return
	var idle: Array = []
	for u in game.units_of(faction):
		if u.is_idle():
			idle.append(u)

	# Defensa: si hay enemigos cerca de la base, manda a los que estén libres.
	var threat: Entity = game.find_enemy_near(faction, hq.global_position, 35.0)
	if threat != null:
		for u in idle:
			u.order_move(threat.global_position, true)
		return

	if idle.size() < wave_size:
		return
	var target_faction := _pick_target_faction()
	if target_faction < 0:
		return
	var target_hq: Building = game.get_hq(target_faction)
	if target_hq == null:
		return
	var i := 0
	for u in idle:
		var offset := Vector3((i % 4) * 2.5 - 3.75, 0, (i / 4) * 2.5)
		u.order_move(target_hq.global_position + offset, true)
		i += 1
	wave_size = mini(wave_size + 1, 14)


## Ataca más a menudo al rival con menos tropas (presa fácil), a veces a uno al azar.
func _pick_target_faction() -> int:
	var enemies: Array = []
	for f in game.factions.size():
		if f != faction and game.factions[f].alive:
			enemies.append(f)
	if enemies.is_empty():
		return -1
	if randf() < 0.35:
		return enemies.pick_random()
	var best: int = enemies[0]
	for f in enemies:
		if game.units_of(f).size() < game.units_of(best).size():
			best = f
	return best
