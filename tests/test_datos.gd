## Comprueba que los datos de unidades están completos y son coherentes.
extends Prueba

const CLAVES := ["name", "cost", "hp", "speed", "range", "damage", "rate", "dmg_type", "armor", "deploy"]


func test_unidades_tienen_todas_las_claves() -> void:
	for id in GameData.UNITS:
		var u: Dictionary = GameData.UNITS[id]
		for clave in CLAVES:
			comprobar(u.has(clave), "%s no tiene '%s'" % [id, clave])


func test_valores_positivos() -> void:
	for id in GameData.UNITS:
		var u: Dictionary = GameData.UNITS[id]
		comprobar(u.cost > 0, "%s: coste debe ser > 0" % id)
		comprobar(u.hp > 0, "%s: vida debe ser > 0" % id)
		comprobar(u.range > 0, "%s: alcance debe ser > 0" % id)
		comprobar(u.rate > 0, "%s: cadencia debe ser > 0" % id)


func test_tabla_de_danio_cubre_todo() -> void:
	for id in GameData.UNITS:
		var u: Dictionary = GameData.UNITS[id]
		comprobar(GameData.DAMAGE_MULT.has(u.dmg_type), "%s: tipo de daño '%s' sin tabla" % [id, u.dmg_type])
		for tipo in GameData.DAMAGE_MULT:
			comprobar(GameData.DAMAGE_MULT[tipo].has(u.armor), "%s: blindaje '%s' sin fila en '%s'" % [id, u.armor, tipo])


func test_tres_facciones() -> void:
	iguales(GameData.FACTIONS.size(), 3, "número de facciones")
