## Rejilla para encontrar unidades cercanas sin comprobar todas contra todas
## (ARQUITECTURA §8). Se reconstruye en cada paso.
class_name IndiceEspacial
extends RefCounted

var celda: float = 50.0
var _celdas: Dictionary = {}


func _init(p_celda: float = 50.0) -> void:
	celda = p_celda


func reconstruir(unidades: Array) -> void:
	_celdas.clear()
	for u in unidades:
		var k := _clave(u.posicion)
		if _celdas.has(k):
			_celdas[k].append(u)
		else:
			_celdas[k] = [u]


## Unidades a menos de `radio` metros de `pos` (en el plano).
func cerca(pos: Vector3, radio: float) -> Array:
	var res: Array = []
	var r := ceili(radio / celda)
	var c := _clave(pos)
	var r2 := radio * radio
	for x in range(c.x - r, c.x + r + 1):
		for z in range(c.y - r, c.y + r + 1):
			var lista: Variant = _celdas.get(Vector2i(x, z))
			if lista == null:
				continue
			for u in lista:
				var dx: float = u.posicion.x - pos.x
				var dz: float = u.posicion.z - pos.z
				if dx * dx + dz * dz <= r2:
					res.append(u)
	return res


func _clave(p: Vector3) -> Vector2i:
	return Vector2i(floori(p.x / celda), floori(p.z / celda))
