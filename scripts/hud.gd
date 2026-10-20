class_name Hud
extends CanvasLayer
## Interfaz: marcador, dinero, compra de unidades, opciones de despliegue y minimapa.

var game: Node
var drag_box: ColorRect

var _money_label: Label
var _score_bars: Array = []
var _score_labels: Array = []
var _zone_label: Label
var _info_label: Label
var _message_label: Label
var _buttons: Dictionary = {}
var _deploy_button: Button
var _crew_button: Button
var _free_button: Button
var _fob_button: Button
var _unload_button: Button
var _end_panel: PanelContainer
var _end_label: Label
var _message_tween: Tween


func setup(p_game: Node) -> void:
	game = p_game
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# ---- Barra superior: dinero y marcador
	var top := PanelContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	root.add_child(top)
	var top_box := HBoxContainer.new()
	top_box.add_theme_constant_override("separation", 24)
	top.add_child(top_box)
	_money_label = Label.new()
	_money_label.add_theme_font_size_override("font_size", 26)
	_money_label.add_theme_color_override("font_color", Color(0.55, 1.0, 0.5))
	_money_label.custom_minimum_size.x = 190
	top_box.add_child(_money_label)
	for i in GameData.FACTIONS.size():
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 0)
		top_box.add_child(col)
		var label := Label.new()
		label.add_theme_font_size_override("font_size", 13)
		col.add_child(label)
		var bar := ProgressBar.new()
		bar.max_value = GameData.SCORE_TO_WIN
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(230, 10)
		var fill := StyleBoxFlat.new()
		fill.bg_color = GameData.FACTIONS[i].color
		bar.add_theme_stylebox_override("fill", fill)
		col.add_child(bar)
		_score_labels.append(label)
		_score_bars.append(bar)
	_zone_label = Label.new()
	_zone_label.add_theme_font_size_override("font_size", 14)
	top_box.add_child(_zone_label)

	# ---- Panel inferior: compra y opciones
	var bottom := PanelContainer.new()
	bottom.anchor_top = 1.0
	bottom.anchor_bottom = 1.0
	bottom.anchor_right = 1.0
	bottom.offset_right = -250
	bottom.grow_vertical = Control.GROW_DIRECTION_BEGIN
	root.add_child(bottom)
	var bottom_box := VBoxContainer.new()
	bottom.add_child(bottom_box)
	for group in [GameData.INFANTRY, GameData.VEHICLES]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		bottom_box.add_child(row)
		for t in group:
			var d: Dictionary = GameData.UNITS[t]
			_buttons[t] = _make_button(row, "%s\n%s · MG %d" % [d.name, GameData.format_money(d.cost), d.mg], game.player_buy.bind(t), Vector2(150, 46))
			_buttons[t].tooltip_text = GameData.describe(t)
	var opts := HBoxContainer.new()
	opts.add_theme_constant_override("separation", 4)
	bottom_box.add_child(opts)
	_deploy_button = _make_button(opts, "", game.cycle_deploy_point, Vector2(190, 34))
	_crew_button = _make_button(opts, "", func(): game.buy_with_crew = not game.buy_with_crew, Vector2(190, 34))
	_free_button = _make_button(opts, "Pelotón gratis (F)", func(): game.cmd_free_squad(game.player_faction), Vector2(170, 34))
	_fob_button = _make_button(opts, "Zona de despliegue\n%s" % GameData.format_money(GameData.FOB_COST), game.start_fob_placement, Vector2(170, 34))
	_unload_button = _make_button(opts, "Bajar del vehículo (E)", func(): game.cmd_unload(game.player_faction, game.selection), Vector2(170, 34))
	_info_label = Label.new()
	_info_label.add_theme_font_size_override("font_size", 12)
	opts.add_child(_info_label)

	# ---- Minimapa
	var minimap := Minimap.new()
	minimap.game = game
	minimap.anchor_left = 1.0
	minimap.anchor_right = 1.0
	minimap.anchor_top = 1.0
	minimap.anchor_bottom = 1.0
	minimap.offset_left = -244
	minimap.offset_top = -244
	minimap.offset_right = -4
	minimap.offset_bottom = -4
	root.add_child(minimap)

	var help := Label.new()
	help.text = "Clic izq: seleccionar (doble clic: mismo tipo)  ·  Clic der: mover / atacar / subir a vehículo  ·  Ctrl+clic der: ataque-movimiento  ·  WASD: cámara  ·  Rueda: zoom  ·  H: base  ·  Z: hot zone  ·  Esc: cancelar"
	help.add_theme_font_size_override("font_size", 12)
	help.add_theme_color_override("font_color", Color(1, 1, 1, 0.65))
	help.position = Vector2(10, 52)
	help.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(help)

	_message_label = Label.new()
	_message_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_message_label.offset_top = 80
	_message_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_font_size_override("font_size", 24)
	_message_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_message_label.add_theme_constant_override("outline_size", 6)
	_message_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_message_label)

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


func _make_button(parent: Control, text: String, callback: Callable, min_size: Vector2) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 12)
	b.pressed.connect(callback)
	parent.add_child(b)
	return b


func show_end(text: String) -> void:
	_end_label.text = text
	_end_panel.visible = true
	await get_tree().process_frame
	_end_panel.position = (get_viewport().get_visible_rect().size - _end_panel.size) * 0.5


func show_message(text: String) -> void:
	_message_label.text = text
	_message_label.modulate.a = 1.0
	if _message_tween:
		_message_tween.kill()
	_message_tween = create_tween()
	_message_tween.tween_interval(2.5)
	_message_tween.tween_property(_message_label, "modulate:a", 0.0, 1.0)


func _process(_delta: float) -> void:
	if game == null:
		return
	var me := game.player_faction as int
	var money: int = game.factions[me].money
	_money_label.text = GameData.format_money(money)
	var wz: WarZone = game.war_zone
	for i in game.factions.size():
		var tag := " (Tú)" if i == me else ""
		var scoring := "  ▲ PUNTÚA" if wz.leader == i else ""
		_score_labels[i].text = "%s%s: %d/%d · MG %.0f%s" % [game.factions[i].name, tag, wz.scores[i], GameData.SCORE_TO_WIN, wz.current_mg[i], scoring]
		_score_bars[i].value = wz.scores[i]
	var t := int(maxf(wz.hot_timer, 0.0))
	_zone_label.text = "Hot zone se mueve en %d:%02d" % [t / 60, t % 60]

	var pop: int = game.pop_count(me)
	for t_id in _buttons:
		var cost: int = GameData.UNITS[t_id].cost
		if game.buy_with_crew and GameData.is_vehicle(t_id):
			cost += GameData.UNITS[GameData.crew_type_for(t_id)].cost
		_buttons[t_id].disabled = money < cost or pop >= GameData.POP_CAP

	var points: Array = game.deploy_points(me)
	game.deploy_index = mini(game.deploy_index, points.size() - 1)
	var point_name := "Base" if game.deploy_index == 0 else "Zona avanzada %d" % game.deploy_index
	_deploy_button.text = "Desplegar en: %s\n(aeronaves siempre en la base)" % point_name
	_crew_button.text = "Vehículos con tripulación: %s\n(suma conductor o piloto)" % ("SÍ" if game.buy_with_crew else "NO")
	var cd: float = game.factions[me].free_cooldown
	_free_button.disabled = not game.can_free_squad(me)
	_free_button.text = "Pelotón gratis (F)" if cd <= 0.0 else "Pelotón gratis en %ds" % int(cd)
	var sel: Array = game.selected_units()
	_fob_button.disabled = money < GameData.FOB_COST or sel.filter(func(u): return u.builder).is_empty() or game.fob_count(me) >= GameData.FOB_MAX
	_unload_button.disabled = sel.filter(func(u): return u.is_vehicle and (u.crew != null or not u.passengers.is_empty())).is_empty()

	var lines: Array = ["Unidades: %d/%d · Seleccionadas: %d" % [pop, GameData.POP_CAP, sel.size()]]
	if sel.size() == 1 and sel[0].is_vehicle:
		var v: Unit = sel[0]
		lines.append("%s · %s · pasajeros %d/%d" % [
			GameData.UNITS[v.type_id].name,
			"con %s" % ("piloto" if v.crew_kind == "air" else "conductor") if v.crew else "SIN TRIPULACIÓN",
			v.passengers.size(), v.seats])
	var queue: Array = game.queued_for(me)
	if not queue.is_empty():
		lines.append("Desplegando: %d" % queue.size())
	if game.placing_type != "":
		lines.append("Clic izq: colocar zona de despliegue · Clic der: cancelar")
	_info_label.text = "\n".join(lines)
