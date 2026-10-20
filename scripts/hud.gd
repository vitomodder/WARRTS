class_name Hud
extends CanvasLayer
## Interfaz: dinero, botones de compra, cola de producción y mensajes de fin de partida.

var game: Node
var drag_box: ColorRect

var _money_label: Label
var _factions_label: Label
var _info_label: Label
var _buttons: Dictionary = {}
var _end_panel: PanelContainer
var _end_label: Label


func setup(p_game: Node) -> void:
	game = p_game
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# Barra superior
	var top := PanelContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	root.add_child(top)
	var top_box := HBoxContainer.new()
	top_box.add_theme_constant_override("separation", 30)
	top.add_child(top_box)
	_money_label = Label.new()
	_money_label.add_theme_font_size_override("font_size", 26)
	_money_label.add_theme_color_override("font_color", Color(0.55, 1.0, 0.5))
	top_box.add_child(_money_label)
	_factions_label = Label.new()
	_factions_label.add_theme_font_size_override("font_size", 16)
	top_box.add_child(_factions_label)

	# Panel inferior con botones de compra
	var bottom := PanelContainer.new()
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.grow_vertical = Control.GROW_DIRECTION_BEGIN
	root.add_child(bottom)
	var bottom_box := HBoxContainer.new()
	bottom_box.add_theme_constant_override("separation", 8)
	bottom.add_child(bottom_box)
	for t in GameData.UNITS:
		var d: Dictionary = GameData.UNITS[t]
		_buttons[t] = _make_button(bottom_box, "%s\n$%d" % [d.name, d.cost], game.player_buy_unit.bind(t))
	bottom_box.add_child(VSeparator.new())
	var f: Dictionary = GameData.BUILDINGS.factory
	_buttons["factory"] = _make_button(bottom_box, "%s\n$%d" % [f.name, f.cost], game.start_placement.bind("factory"))
	bottom_box.add_child(VSeparator.new())
	_info_label = Label.new()
	_info_label.add_theme_font_size_override("font_size", 14)
	bottom_box.add_child(_info_label)

	var help := Label.new()
	help.text = "Clic izq: seleccionar / arrastrar  ·  Clic der: mover o atacar  ·  Ctrl+clic der: ataque-movimiento  ·  WASD/flechas: cámara  ·  Rueda: zoom  ·  H: base  ·  Esc: cancelar"
	help.add_theme_font_size_override("font_size", 13)
	help.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	help.position = Vector2(10, 48)
	help.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(help)

	drag_box = ColorRect.new()
	drag_box.color = Color(0.3, 1.0, 0.4, 0.15)
	drag_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_box.visible = false
	root.add_child(drag_box)

	_end_panel = PanelContainer.new()
	_end_panel.set_anchors_preset(Control.PRESET_CENTER)
	_end_panel.visible = false
	root.add_child(_end_panel)
	var end_box := VBoxContainer.new()
	_end_panel.add_child(end_box)
	_end_label = Label.new()
	_end_label.add_theme_font_size_override("font_size", 44)
	_end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_box.add_child(_end_label)
	var restart := Button.new()
	restart.text = "Jugar otra vez"
	restart.pressed.connect(func(): get_tree().reload_current_scene())
	end_box.add_child(restart)


func _make_button(parent: Control, text: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(130, 56)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(callback)
	parent.add_child(b)
	return b


func show_end(text: String) -> void:
	_end_label.text = text
	_end_panel.visible = true
	_end_panel.position = (get_viewport().get_visible_rect().size - _end_panel.size) * 0.5


func _process(_delta: float) -> void:
	if game == null:
		return
	var me: Dictionary = game.factions[game.player_faction]
	_money_label.text = "$ %d" % me.money
	var parts: Array = []
	for i in game.factions.size():
		var f: Dictionary = game.factions[i]
		var tag := " (Tú)" if i == game.player_faction else ""
		var state := "$%d · %d unidades" % [f.money, game.units_of(i).size()] if f.alive else "ELIMINADA"
		parts.append("%s%s: %s" % [f.name, tag, state])
	_factions_label.text = "    ".join(parts)

	for t in _buttons:
		var cost: int = GameData.UNITS[t].cost if GameData.UNITS.has(t) else GameData.BUILDINGS[t].cost
		var available: bool = me.alive and me.money >= cost
		if GameData.UNITS.has(t):
			available = available and game.find_producer(game.player_faction, t) != null
		_buttons[t].disabled = not available

	var lines: Array = ["Seleccionadas: %d" % game.selection.size()]
	for b in game.buildings_of(game.player_faction):
		if not b.queue.is_empty():
			lines.append("%s: %s %d%% (+%d en cola)" % [
				GameData.BUILDINGS[b.type_id].name,
				GameData.UNITS[b.queue[0]].name,
				int(b.current_progress() * 100.0),
				b.queue.size() - 1,
			])
	if game.placing_type != "":
		lines.append("Coloca la fábrica cerca de tu cuartel (clic der. para cancelar)")
	_info_label.text = "\n".join(lines)
