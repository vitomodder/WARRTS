## Las unidades seleccionadas por el jugador y sus grupos Ctrl + número (GDD 15).
class_name Seleccion
extends RefCounted

signal cambiada

var unidades: Array[Unidad] = []
## Tipo activo para las acciones de clase (Tab).
var tipo_activo: String = ""
var _grupos: Dictionary = {}


func reemplazar(lista: Array) -> void:
	for u in unidades:
		u.marcar_seleccion(false)
	unidades.clear()
	for u in lista:
		if u.esta_viva() and not unidades.has(u):
			unidades.append(u)
			u.marcar_seleccion(true)
	_ajustar_tipo()
	cambiada.emit()


func anadir(lista: Array) -> void:
	var todas: Array = unidades.duplicate()
	todas.append_array(lista)
	reemplazar(todas)


## Shift + clic: añade la unidad o la quita si ya estaba.
func alternar(u: Unidad) -> void:
	var lista: Array = unidades.duplicate()
	if lista.has(u):
		lista.erase(u)
	else:
		lista.append(u)
	reemplazar(lista)


func limpiar() -> void:
	reemplazar([])


func ids() -> PackedInt32Array:
	var res := PackedInt32Array()
	for u in unidades:
		res.append(u.id)
	return res


func guardar_grupo(n: int) -> void:
	_grupos[n] = unidades.duplicate()


func grupo(n: int) -> Array:
	var lista: Array = _grupos.get(n, [])
	return lista.filter(func(u): return is_instance_valid(u) and u.esta_viva())


## Tipos de unidad presentes, en orden de aparición.
func tipos() -> Array[String]:
	var res: Array[String] = []
	for u in unidades:
		if not res.has(u.def.id):
			res.append(u.def.id)
	return res


## Tab: pasa al siguiente tipo de la selección.
func siguiente_tipo() -> void:
	var t := tipos()
	if t.is_empty():
		tipo_activo = ""
	else:
		tipo_activo = t[(t.find(tipo_activo) + 1) % t.size()]
	cambiada.emit()


func quitar_muertas() -> void:
	var vivas := unidades.filter(func(u): return is_instance_valid(u) and u.esta_viva())
	if vivas.size() != unidades.size():
		reemplazar(vivas)


func _ajustar_tipo() -> void:
	var t := tipos()
	if not t.has(tipo_activo):
		tipo_activo = t[0] if not t.is_empty() else ""
