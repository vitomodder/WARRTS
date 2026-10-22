## Selección, grupos Ctrl + número y tipo activo (GDD 15).
extends Prueba


func test_grupos_y_tipos() -> void:
	var sim: Simulacion = await escenario()
	var a := sim.crear_unidad(def("asalto"), 0, Vector3(0, 0, 0))
	var m := sim.crear_unidad(def("medico"), 0, Vector3(3, 0, 0))
	var f := sim.crear_unidad(def("francotirador"), 0, Vector3(6, 0, 0))
	var s := Seleccion.new()
	s.reemplazar([a, m])
	iguales(s.unidades.size(), 2, "selección inicial")
	comprobar(a.seleccionada and m.seleccionada and not f.seleccionada, "marca de selección")
	s.guardar_grupo(1)
	s.reemplazar([f])
	comprobar(not a.seleccionada, "se desmarca al cambiar")
	iguales(s.grupo(1).size(), 2, "el grupo 1 se guarda")
	s.alternar(a)
	iguales(s.unidades.size(), 2, "Shift añade")
	s.alternar(a)
	iguales(s.unidades.size(), 1, "Shift quita")
	s.reemplazar([a, m, f])
	iguales(s.tipos(), ["asalto", "medico", "francotirador"] as Array[String], "tipos en orden")
	iguales(s.tipo_activo, "francotirador", "el tipo activo se mantiene si sigue en la selección")
	s.siguiente_tipo()
	iguales(s.tipo_activo, "asalto", "Tab pasa al siguiente tipo y vuelve al principio")
	s.siguiente_tipo()
	iguales(s.tipo_activo, "medico", "Tab otra vez")
	m.vida = 0.0
	s.quitar_muertas()
	iguales(s.unidades.size(), 2, "las muertas salen de la selección")
	iguales(s.grupo(1).size(), 1, "y de los grupos")
