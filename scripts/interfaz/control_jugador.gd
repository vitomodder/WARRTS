## Traduce el ratón y el teclado en selección y órdenes (GDD 15). Nunca cambia el
## estado del juego directamente: todo pasa por órdenes de la simulación.
class_name ControlJugador
extends Node

## Píxeles que hay que arrastrar para que cuente como recuadro.
const ARRASTRE := 8.0
## Píxeles de tolerancia al hacer clic sobre una unidad.
const RADIO_CLIC := 22.0
const DOBLE_CLIC := 0.35
## Metros que hay que arrastrar con clic derecho para formar una línea.
const ARRASTRE_LINEA := 4.0

var sim: Simulacion
var camara: CamaraRts
var hud: Hud
var equipo: int = 0
var seleccion := Seleccion.new()

var _izq_inicio := Vector2.ZERO
var _izq_pulsado := false
var _der_inicio: Variant = null
var _der_pantalla := Vector2.ZERO
var _ultimo_clic := -10.0
var _ultimo_clic_unidad: Unidad = null
var _ultimo_grupo := -1
var _ultimo_grupo_t := -10.0


func preparar(p_sim: Simulacion, p_camara: CamaraRts, p_hud: Hud, p_equipo: int) -> void:
	sim = p_sim
	camara = p_camara
	hud = p_hud
	equipo = p_equipo


func _process(_delta: float) -> void:
	seleccion.quitar_muertas()
	var m := get_viewport().get_mouse_position()
	hud.recuadro = Rect2(_izq_inicio, m - _izq_inicio).abs() if _izq_pulsado and m.distance_to(_izq_inicio) > ARRASTRE else Rect2()
	hud.linea = [_der_pantalla, m] if _der_inicio != null and m.distance_to(_der_pantalla) > ARRASTRE else []


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseButton:
		if e.button_index == MOUSE_BUTTON_LEFT:
			if e.pressed:
				if e.alt_pressed:
					_marcar_punto(e.position)
					return
				_izq_pulsado = true
				_izq_inicio = e.position
			elif _izq_pulsado:
				_izq_pulsado = false
				_soltar_izquierdo(e.position, e.shift_pressed)
		elif e.button_index == MOUSE_BUTTON_RIGHT:
			if e.pressed:
				_der_inicio = camara.punto_suelo(e.position)
				_der_pantalla = e.position
			elif _der_inicio != null:
				_soltar_derecho(e)
				_der_inicio = null
	elif e is InputEventKey and e.pressed and not e.echo:
		_tecla(e)


# ------------------------------------------------------------------ Selección

func _soltar_izquierdo(pos: Vector2, shift: bool) -> void:
	if pos.distance_to(_izq_inicio) > ARRASTRE:
		var rect := Rect2(_izq_inicio, pos - _izq_inicio).abs()
		var dentro := _propias().filter(func(u): return _en_rect(u, rect))
		if shift:
			seleccion.anadir(dentro)
		else:
			seleccion.reemplazar(dentro)
		return
	var u := unidad_bajo(pos)
	var ahora := Time.get_ticks_msec() / 1000.0
	# Doble clic: dos clics seguidos sobre la misma unidad.
	var doble := ahora - _ultimo_clic < DOBLE_CLIC and u != null and u == _ultimo_clic_unidad
	_ultimo_clic = ahora
	_ultimo_clic_unidad = u
	if u == null or u.equipo != equipo:
		if not shift:
			seleccion.limpiar()
		return
	if doble:
		# Todas las del mismo tipo que se ven en pantalla.
		var pantalla := get_viewport().get_visible_rect()
		seleccion.reemplazar(_propias().filter(func(o): return o.def == u.def and _en_rect(o, pantalla)))
	elif shift:
		seleccion.alternar(u)
	else:
		seleccion.reemplazar([u])


func _propias() -> Array:
	return sim.unidades_de(equipo).filter(func(u): return u.esta_viva())


func _en_rect(u: Unidad, rect: Rect2) -> bool:
	var p: Variant = camara.en_pantalla(u.position + Vector3(0, 0.9, 0))
	return p != null and rect.has_point(p)


## La unidad más cercana al puntero, de cualquier equipo.
func unidad_bajo(pos: Vector2) -> Unidad:
	var mejor: Unidad = null
	var mejor_d := RADIO_CLIC
	for u in sim.unidades:
		if not u.esta_viva():
			continue
		var p: Variant = camara.en_pantalla(u.position + Vector3(0, 0.9, 0))
		if p == null:
			continue
		var d: float = (p as Vector2).distance_to(pos)
		if d < mejor_d:
			mejor_d = d
			mejor = u
	return mejor


# ------------------------------------------------------------------ Órdenes

func _soltar_derecho(e: InputEventMouseButton) -> void:
	if seleccion.unidades.is_empty():
		return
	var fin: Variant = camara.punto_suelo(e.position)
	if fin == null:
		return
	var inicio: Vector3 = _der_inicio
	var arrastre: Vector3 = fin - inicio
	arrastre.y = 0.0
	if arrastre.length() < ARRASTRE_LINEA:
		var blanco := unidad_bajo(e.position)
		if blanco != null and blanco.equipo != equipo:
			var o := OrdenAtacar.new()
			o.equipo = equipo
			o.unidades = seleccion.ids()
			o.objetivo = blanco.id
			sim.enviar(o)
			return
	var m := OrdenMover.new()
	m.equipo = equipo
	m.unidades = seleccion.ids()
	m.atacar_por_el_camino = e.ctrl_pressed
	m.encadenar = e.shift_pressed
	if arrastre.length() >= ARRASTRE_LINEA:
		# Línea arrastrada: se reparten a lo largo y miran hacia el lado contrario
		# al que venían.
		m.destino = inicio + arrastre * 0.5
		m.ancho_linea = arrastre.length()
		var normal := Vector3(-arrastre.z, 0, arrastre.x).normalized()
		var centro := Vector3.ZERO
		for u in seleccion.unidades:
			centro += u.posicion
		centro /= seleccion.unidades.size()
		if normal.dot(m.destino - centro) < 0.0:
			normal = -normal
		m.mirar = normal
	else:
		m.destino = fin
	sim.enviar(m)
	hud.marcar_destino(m.destino)


func _tecla(e: InputEventKey) -> void:
	var k := e.keycode
	if k >= KEY_0 and k <= KEY_9:
		var n := k - KEY_0
		if e.ctrl_pressed:
			seleccion.guardar_grupo(n)
			hud.aviso("Grupo %d guardado" % n)
		else:
			seleccion.reemplazar(seleccion.grupo(n))
			var ahora := Time.get_ticks_msec() / 1000.0
			if _ultimo_grupo == n and ahora - _ultimo_grupo_t < DOBLE_CLIC * 1.5 and not seleccion.unidades.is_empty():
				camara.centrar(seleccion.unidades[0].posicion)
			_ultimo_grupo = n
			_ultimo_grupo_t = ahora
		return
	match k:
		KEY_SPACE:
			if e.alt_pressed:
				return
			if not seleccion.unidades.is_empty():
				var o := OrdenDetener.new()
				o.equipo = equipo
				o.unidades = seleccion.ids()
				sim.enviar(o)
		KEY_TAB:
			seleccion.siguiente_tipo()
		KEY_H:
			camara.centrar(sim.mundo.bases[equipo])
		KEY_N:
			camara.centrar(Vector3.ZERO)  # la hot zone llega en la Fase 3; de momento, el centro
		KEY_ESCAPE:
			seleccion.limpiar()
		KEY_PAGEUP:
			sim.velocidad = minf(sim.velocidad * 2.0, 16.0)
			hud.aviso("Velocidad ×%s" % str(sim.velocidad))
		KEY_PAGEDOWN:
			sim.velocidad = maxf(sim.velocidad / 2.0, 0.25)
			hud.aviso("Velocidad ×%s" % str(sim.velocidad))
		KEY_P:
			sim.pausada = not sim.pausada
			hud.aviso("Pausa" if sim.pausada else "Sigue la partida")


func _marcar_punto(pos: Vector2) -> void:
	var p: Variant = camara.punto_suelo(pos)
	if p != null:
		hud.marcar_punto(p)
