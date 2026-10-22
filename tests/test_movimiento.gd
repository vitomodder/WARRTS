## Movimiento, formaciones, rutas, detener y atacar (GDD 15).
extends Prueba


func test_llega_al_destino() -> void:
	var sim: Simulacion = await escenario()
	var u := sim.crear_unidad(def("asalto"), 0, Vector3(-50, 0, 0))
	mover(sim, [u], Vector3(50, 0, 0))
	sim.avanzar(30.0)
	comprobar(u.posicion.distance_to(Vector3(50, 0, 0)) < 2.0, "llega a menos de 2 m (está en %s)" % u.posicion)
	comprobar(not u.se_mueve(), "se queda quieta al llegar")


func test_rodea_un_obstaculo() -> void:
	var sim: Simulacion = await escenario(300.0, [[Vector3.ZERO, Vector3(10, 4, 60)]])
	var u := sim.crear_unidad(def("asalto"), 0, Vector3(-30, 0, 0))
	mover(sim, [u], Vector3(30, 0, 0))
	var dentro := false
	for i in 400:
		sim.avanzar_paso()
		if sim.mundo.bloqueado(u.posicion):
			dentro = true
	comprobar(not dentro, "nunca atraviesa el muro")
	comprobar(u.posicion.distance_to(Vector3(30, 0, 0)) < 2.0, "llega al otro lado (está en %s)" % u.posicion)


func test_formacion_en_linea() -> void:
	var sim: Simulacion = await escenario()
	var lista: Array = []
	for i in 10:
		lista.append(sim.crear_unidad(def("asalto"), 0, Vector3(i * 3.0 - 15.0, 0, -40)))
	var o := OrdenMover.new()
	for u in lista:
		o.unidades.append(u.id)
	o.destino = Vector3(0, 0, 40)
	o.mirar = Vector3(0, 0, 1)
	o.ancho_linea = 30.0
	sim.enviar(o)
	sim.avanzar(40.0)
	var min_x := INF
	var max_x := -INF
	var min_z := INF
	var max_z := -INF
	for u in lista:
		min_x = minf(min_x, u.posicion.x)
		max_x = maxf(max_x, u.posicion.x)
		min_z = minf(min_z, u.posicion.z)
		max_z = maxf(max_z, u.posicion.z)
		for v in lista:
			if u != v:
				comprobar(u.posicion.distance_to(v.posicion) >= 1.2, "%d y %d se solapan" % [u.id, v.id])
	comprobar(max_x - min_x > 22.0, "la línea ocupa unos 30 m de ancho (%.1f)" % (max_x - min_x))
	comprobar(max_z - min_z < 4.0, "es una sola fila (fondo %.1f)" % (max_z - min_z))
	comprobar(absf((min_z + max_z) * 0.5 - 40.0) < 3.0, "la fila está en el destino")


func test_formacion_sin_solapes() -> void:
	var sim: Simulacion = await escenario()
	var lista: Array = []
	for i in 30:
		lista.append(sim.crear_unidad(def("asalto"), 0, Vector3((i % 6) * 3.0, 0, (i / 6) * 3.0 - 80)))
	mover(sim, lista, Vector3(0, 0, 50))
	sim.avanzar(60.0)
	var solapes := 0
	for u in lista:
		comprobar(u.posicion.distance_to(Vector3(0, 0, 50)) < 15.0, "%d llega cerca del destino" % u.id)
		for v in lista:
			if u.id < v.id and u.posicion.distance_to(v.posicion) < 1.2:
				solapes += 1
	iguales(solapes, 0, "parejas de soldados solapados")


func test_encadenar_ordenes() -> void:
	var sim: Simulacion = await escenario()
	var u := sim.crear_unidad(def("asalto"), 0, Vector3(-60, 0, 0))
	mover(sim, [u], Vector3(0, 0, 60))
	var b := mover(sim, [u], Vector3(60, 0, 0))
	b.encadenar = true
	var cerca_a := INF
	for i in 600:
		sim.avanzar_paso()
		cerca_a = minf(cerca_a, u.posicion.distance_to(Vector3(0, 0, 60)))
	comprobar(cerca_a < 2.0, "pasa por el primer punto (a %.1f m)" % cerca_a)
	comprobar(u.posicion.distance_to(Vector3(60, 0, 0)) < 2.0, "acaba en el segundo punto")


func test_detener() -> void:
	var sim: Simulacion = await escenario()
	var u := sim.crear_unidad(def("asalto"), 0, Vector3(-60, 0, 0))
	mover(sim, [u], Vector3(60, 0, 0))
	sim.avanzar(3.0)
	var d := OrdenDetener.new()
	d.unidades = PackedInt32Array([u.id])
	sim.enviar(d)
	sim.avanzar(0.2)
	var parada := u.posicion
	sim.avanzar(5.0)
	comprobar(u.posicion.distance_to(parada) < 0.01, "no se mueve después de detener")
	comprobar(u.posicion.x > -55.0, "se había movido antes de detener")


func test_atacar_persigue_hasta_tener_alcance() -> void:
	var sim: Simulacion = await escenario(600.0)
	var u := sim.crear_unidad(def("ingeniero"), 0, Vector3(-200, 0, 0))
	var enemiga := sim.crear_unidad(def("asalto"), 1, Vector3(100, 0, 0))
	var o := OrdenAtacar.new()
	o.unidades = PackedInt32Array([u.id])
	o.objetivo = enemiga.id
	sim.enviar(o)
	sim.avanzar(80.0)
	var d := u.posicion.distance_to(enemiga.posicion)
	comprobar(d <= u.def.alcance + 1.0, "se acerca hasta su alcance (a %.1f m)" % d)
	comprobar(d >= u.def.alcance - 10.0, "no se acerca más de lo necesario (a %.1f m)" % d)


func test_ataque_movimiento_marca_la_unidad() -> void:
	var sim: Simulacion = await escenario()
	var u := sim.crear_unidad(def("asalto"), 0, Vector3(-50, 0, 0))
	var o := mover(sim, [u], Vector3(50, 0, 0))
	o.atacar_por_el_camino = true
	sim.avanzar(1.0)
	comprobar(u.atacando_por_el_camino, "va atacando por el camino")


func test_misma_partida_mismo_resultado() -> void:
	var a: Array = await _partida_corta()
	await limpiar_escenario()
	var b: Array = await _partida_corta()
	iguales(a.size(), b.size(), "número de unidades")
	var distintas := 0
	for i in a.size():
		if not a[i].is_equal_approx(b[i]):
			distintas += 1
	iguales(distintas, 0, "unidades en distinta posición entre dos repeticiones")


func _partida_corta() -> Array:
	var sim: Simulacion = await escenario(300.0, [[Vector3(0, 0, 10), Vector3(20, 4, 6)]])
	var lista: Array = []
	for i in 20:
		lista.append(sim.crear_unidad(def("asalto"), 0, Vector3((i % 5) * 3.0, 0, -60 + (i / 5) * 3.0)))
	mover(sim, lista, Vector3(5, 0, 60))
	sim.avanzar(40.0)
	return lista.map(func(u): return u.posicion)
