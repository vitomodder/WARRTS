## Órdenes: se pueden guardar y leer, y se aplican en el paso siguiente.
extends Prueba


func test_ida_y_vuelta_por_diccionario() -> void:
	var m := OrdenMover.new()
	m.equipo = 2
	m.paso = 14
	m.unidades = PackedInt32Array([3, 5, 8])
	m.destino = Vector3(10, 0, -4.5)
	m.mirar = Vector3(0, 0, 1)
	m.ancho_linea = 25.0
	m.atacar_por_el_camino = true
	m.encadenar = true
	var a := OrdenAtacar.new()
	a.equipo = 1
	a.unidades = PackedInt32Array([7])
	a.objetivo = 42
	var d := OrdenDetener.new()
	d.unidades = PackedInt32Array([1, 2])
	for o in [m, a, d]:
		var copia := Orden.desde_dict(o.a_dict())
		comprobar(copia != null, "%s se reconstruye" % o.tipo())
		if copia != null:
			iguales(copia.a_dict(), o.a_dict(), "%s igual tras ida y vuelta" % o.tipo())
	comprobar(Orden.desde_dict({"tipo": "inventada"}) == null, "tipo desconocido da null")


func test_se_aplica_en_el_paso_siguiente_y_queda_registrada() -> void:
	var sim: Simulacion = await escenario()
	var u := sim.crear_unidad(def("asalto"), 0, Vector3.ZERO)
	var o := mover(sim, [u], Vector3(20, 0, 0))
	iguales(o.paso, 1, "paso de la orden")
	sim.avanzar_paso()
	comprobar(u.destinos.is_empty(), "no se aplica en el mismo paso")
	sim.avanzar_paso()
	iguales(u.destinos.size(), 1, "se aplica en el paso siguiente")
	iguales(sim.comandos.registro.size(), 1, "queda en el registro")


func test_no_mueve_unidades_de_otro_equipo() -> void:
	var sim: Simulacion = await escenario()
	var enemiga := sim.crear_unidad(def("asalto"), 1, Vector3.ZERO)
	mover(sim, [enemiga], Vector3(20, 0, 0), 0)
	sim.avanzar(1.0)
	comprobar(enemiga.destinos.is_empty(), "la orden del equipo 0 no afecta al equipo 1")
