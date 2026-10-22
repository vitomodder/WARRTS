## Interfaz mínima de la Fase 1: recuadro de selección, línea de formación, resumen
## de la selección, avisos y marcas en el suelo. El panel de compra y el resto de
## 12.3 y 19.6 llegan en fases posteriores.
class_name Hud
extends CanvasLayer

var recuadro: Rect2 = Rect2()
var linea: Array = []
var sim: Simulacion
var seleccion: Seleccion
var _dibujo: Control
var _info: Label
var _ayuda: Label
var _aviso: Label
var _aviso_t: float = 0.0
var _marcas: Node3D
var _nombres_equipo: Array = []


func preparar(p_sim: Simulacion, p_seleccion: Seleccion, marcas: Node3D, nombres_equipo: Array) -> void:
	sim = p_sim
	seleccion = p_seleccion
	_marcas = marcas
	_nombres_equipo = nombres_equipo
	_dibujo = Control.new()
	_dibujo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dibujo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dibujo.draw.connect(_dibujar)
	add_child(_dibujo)

	_info = _etiqueta(Vector2(16, 12), 17)
	_ayuda = _etiqueta(Vector2(16, 0), 13)
	_ayuda.anchor_top = 1.0
	_ayuda.anchor_bottom = 1.0
	_ayuda.offset_top = -150
	_ayuda.text = "\n".join([
		"Clic izq.: seleccionar · arrastrar: recuadro · doble clic: todas las de ese tipo · Shift: añadir/quitar",
		"Clic der.: mover o atacar · arrastrar: línea y hacia dónde miran · Ctrl: ataque-movimiento · Shift: encadenar",
		"Alt + clic izq.: marcar punto · Espacio: detener · Ctrl+1…0: guardar grupo · 1…0: elegir grupo (dos veces: centrar)",
		"WASD/bordes: mover cámara · rueda: zoom · botón central: girar · H: base · N: centro · Tab: tipo activo",
		"Pruebas: RePág/AvPág velocidad · P pausa",
	])
	_aviso = _etiqueta(Vector2(0, 70), 22)
	_aviso.anchor_left = 0.5
	_aviso.anchor_right = 0.5
	_aviso.offset_left = -300
	_aviso.offset_right = 300
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _etiqueta(pos: Vector2, tam: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("outline_size", 5)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l


func aviso(texto: String) -> void:
	_aviso.text = texto
	_aviso_t = 2.5


func _process(delta: float) -> void:
	_dibujo.queue_redraw()
	_aviso_t -= delta
	_aviso.visible = _aviso_t > 0.0
	var lineas: Array = []
	lineas.append("WARRTS · Fase 1 · %s · %d fps · paso %.1f ms" % [
		_nombres_equipo[0], Engine.get_frames_per_second(), sim.ms_ultimo_paso])
	var n := seleccion.unidades.size()
	if n > 0:
		var cuenta := {}
		for u in seleccion.unidades:
			cuenta[u.def.nombre] = cuenta.get(u.def.nombre, 0) + 1
		var partes: Array = []
		for k in cuenta:
			partes.append("%s ×%d" % [k, cuenta[k]])
		lineas.append("Seleccionadas: %d (%s)" % [n, ", ".join(partes)])
		var activo := seleccion.tipo_activo
		if activo != "":
			lineas.append("Tipo activo (Tab): %s" % seleccion.unidades.filter(func(u): return u.def.id == activo)[0].def.nombre)
	if sim.velocidad != 1.0 or sim.pausada:
		lineas.append("Velocidad ×%s%s" % [str(sim.velocidad), " · PAUSA" if sim.pausada else ""])
	_info.text = "\n".join(lineas)


func _dibujar() -> void:
	if recuadro.size != Vector2.ZERO:
		_dibujo.draw_rect(recuadro, Color(0.4, 1.0, 0.45, 0.15), true)
		_dibujo.draw_rect(recuadro, Color(0.4, 1.0, 0.45, 0.9), false, 1.5)
	if linea.size() == 2:
		_dibujo.draw_line(linea[0], linea[1], Color(1, 1, 1, 0.9), 2.0)


## Marca verde breve donde se ha ordenado ir.
func marcar_destino(p: Vector3) -> void:
	_marca(p, Color(0.4, 1.0, 0.45), 0.9, 4.0)


## Alt + clic: marca para el equipo que dura 3 s (GDD 15.1).
func marcar_punto(p: Vector3) -> void:
	_marca(p, Color(1.0, 0.85, 0.2), 3.0, 14.0)
	aviso("Punto marcado")


func _marca(p: Vector3, color: Color, dura: float, radio: float) -> void:
	var m := MeshInstance3D.new()
	var t := TorusMesh.new()
	t.inner_radius = radio * 0.8
	t.outer_radius = radio
	m.mesh = t
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.material_override = mat
	m.position = p + Vector3(0, 0.1, 0)
	_marcas.add_child(m)
	var tw := m.create_tween()
	tw.tween_property(mat, "albedo_color:a", 0.0, dura)
	tw.tween_callback(m.queue_free)
