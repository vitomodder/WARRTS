## Controles del jugador con eventos de ratón y teclado simulados (GDD 15).
extends Prueba

var sim: Simulacion
var camara: CamaraRts
var control: ControlJugador
var propias: Array = []
var enemiga: Unidad


func _preparar() -> void:
	sim = await escenario()
	camara = CamaraRts.new()
	sim.get_parent().add_child(camara)
	camara.centrar(Vector3.ZERO)
	var marcas := Node3D.new()
	sim.get_parent().add_child(marcas)
	control = ControlJugador.new()
	var hud := Hud.new()
	sim.get_parent().add_child(hud)
	hud.preparar(sim, control.seleccion, marcas, Partida.NOMBRES)
	sim.get_parent().add_child(control)
	control.preparar(sim, camara, hud, 0)
	propias.clear()
	for i in 4:
		propias.append(sim.crear_unidad(def("asalto"), 0, Vector3(i * 4.0 - 6.0, 0, 0)))
	propias.append(sim.crear_unidad(def("medico"), 0, Vector3(0, 0, 5)))
	enemiga = sim.crear_unidad(def("asalto"), 1, Vector3(0, 0, -20))


func _raton(boton: int, pulsado: bool, pos: Vector2, ctrl := false, shift := false) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = boton
	e.pressed = pulsado
	e.position = pos
	e.ctrl_pressed = ctrl
	e.shift_pressed = shift
	control._unhandled_input(e)


func _clic(boton: int, pos: Vector2, ctrl := false, shift := false) -> void:
	_raton(boton, true, pos, ctrl, shift)
	_raton(boton, false, pos, ctrl, shift)


func _tecla(k: int, ctrl := false) -> void:
	var e := InputEventKey.new()
	e.keycode = k
	e.pressed = true
	e.ctrl_pressed = ctrl
	control._unhandled_input(e)


func _pantalla(p: Vector3) -> Vector2:
	return camara.en_pantalla(p + Vector3(0, 0.9, 0))


func test_recuadro_y_ordenes() -> void:
	await _preparar()
	var tam := control.get_viewport().get_visible_rect().size
	_raton(MOUSE_BUTTON_LEFT, true, Vector2(5, 5))
	_raton(MOUSE_BUTTON_LEFT, false, tam - Vector2(5, 5))
	iguales(control.seleccion.unidades.size(), 5, "el recuadro coge solo las propias")

	_clic(MOUSE_BUTTON_RIGHT, _pantalla(Vector3(15, 0, 10)))
	sim.avanzar(0.2)
	comprobar(propias.all(func(u): return not u.destinos.is_empty()), "clic derecho en el suelo: se mueven")

	_clic(MOUSE_BUTTON_RIGHT, _pantalla(enemiga.posicion))
	sim.avanzar(0.2)
	comprobar(propias.all(func(u): return u.objetivo == enemiga), "clic derecho en un enemigo: lo atacan")

	_raton(MOUSE_BUTTON_RIGHT, true, _pantalla(Vector3(-10, 0, 15)))
	_raton(MOUSE_BUTTON_RIGHT, false, _pantalla(Vector3(10, 0, 15)))
	sim.avanzar(0.2)
	var ultima: Dictionary = sim.comandos.registro[-1]
	comprobar(ultima.ancho_linea > 15.0, "arrastrar con el derecho hace una línea (ancho %.1f)" % ultima.ancho_linea)

	_clic(MOUSE_BUTTON_RIGHT, _pantalla(Vector3(5, 0, 5)), true)
	sim.avanzar(0.2)
	comprobar(sim.comandos.registro[-1].atacar_por_el_camino, "Ctrl + clic derecho: ataque-movimiento")

	_tecla(KEY_SPACE)
	sim.avanzar(0.2)
	comprobar(propias.all(func(u): return not u.se_mueve()), "Espacio: se detienen")


func test_clic_grupos_y_tipos() -> void:
	await _preparar()
	_clic(MOUSE_BUTTON_LEFT, _pantalla(propias[0].posicion))
	iguales(control.seleccion.unidades, [propias[0]] as Array[Unidad], "clic izquierdo selecciona una")
	_clic(MOUSE_BUTTON_LEFT, _pantalla(propias[4].posicion), false, true)
	iguales(control.seleccion.unidades.size(), 2, "Shift + clic añade")
	_tecla(KEY_1, true)
	_tecla(KEY_ESCAPE)
	iguales(control.seleccion.unidades.size(), 0, "Esc limpia la selección")
	_tecla(KEY_1)
	iguales(control.seleccion.unidades.size(), 2, "1 recupera el grupo")
	_tecla(KEY_TAB)
	iguales(control.seleccion.tipo_activo, "medico", "Tab cambia el tipo activo")
	_clic(MOUSE_BUTTON_LEFT, _pantalla(propias[1].posicion))
	_clic(MOUSE_BUTTON_LEFT, _pantalla(propias[1].posicion))
	iguales(control.seleccion.unidades.size(), 4, "doble clic: todos los Asaltos en pantalla")
	_clic(MOUSE_BUTTON_LEFT, _pantalla(enemiga.posicion))
	iguales(control.seleccion.unidades.size(), 0, "no se pueden seleccionar enemigos")
