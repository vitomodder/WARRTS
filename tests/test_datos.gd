## Los datos de data/ se cargan y tienen valores con sentido.
extends Prueba


func test_clases_de_soldado() -> void:
	var letras := {}
	for par in Partida.REPARTO:
		var d: UnidadDef = def(par[0])
		comprobar(d != null, "no se carga %s" % par[0])
		if d == null:
			continue
		iguales(d.id, par[0], "id de %s" % par[0])
		comprobar(d.coste > 0 and d.vida > 0 and d.velocidad > 0, "%s: coste, vida y velocidad > 0" % d.id)
		comprobar(d.alcance > 0 and d.vision > 0, "%s: alcance y visión > 0" % d.id)
		iguales(d.movimiento, UnidadDef.Movimiento.A_PIE, "%s va a pie" % d.id)
		iguales(d.letra.length(), 1, "%s: letra de icono" % d.id)
		comprobar(not letras.has(d.letra), "letra %s repetida" % d.letra)
		letras[d.letra] = true


func test_parametros_de_partida() -> void:
	var p: ParametrosPartida = load("res://data/partida.tres")
	iguales(p.paso, 0.1, "paso de simulación")
	iguales(p.limite_unidades, 100, "límite de unidades (GDD 13.6)")
	iguales(p.puntos_para_ganar, 100, "puntos para ganar")
	comprobar(p.dinero_inicial > 0, "dinero inicial > 0")
