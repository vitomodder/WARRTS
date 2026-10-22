## Recibe las órdenes, las aplica en el paso siguiente y las guarda en el registro
## (ARQUITECTURA §4). Jugador, IA y red pasan todos por aquí.
class_name Comandos
extends RefCounted

var _pendientes: Array[Orden] = []
## Todas las órdenes aplicadas, en orden, como diccionarios.
var registro: Array[Dictionary] = []


## Deja la orden lista para el siguiente paso de `paso_actual`.
func enviar(orden: Orden, paso_actual: int) -> void:
	orden.paso = paso_actual + 1
	_pendientes.append(orden)


## Aplica las órdenes de este paso o anteriores.
func aplicar(sim: Simulacion, paso_actual: int) -> void:
	var quedan: Array[Orden] = []
	for o in _pendientes:
		if o.paso <= paso_actual:
			o.aplicar(sim)
			registro.append(o.a_dict())
		else:
			quedan.append(o)
	_pendientes = quedan
