## Una orden de un jugador o de la IA (ARQUITECTURA §4).
## Se aplica en el paso de simulación `paso` y se puede convertir en diccionario
## para enviarla por red o guardarla en el registro.
class_name Orden
extends RefCounted

var equipo: int = 0
## Paso de simulación en que se aplica. Lo pone Comandos al recibirla.
var paso: int = -1
## Ids de las unidades a las que va dirigida.
var unidades: PackedInt32Array = PackedInt32Array()


func tipo() -> String:
	return "orden"


func a_dict() -> Dictionary:
	var d := {"tipo": tipo(), "equipo": equipo, "paso": paso, "unidades": Array(unidades)}
	_escribir(d)
	return d


## Crea la orden que describe un diccionario de `a_dict()`.
static func desde_dict(d: Dictionary) -> Orden:
	var o: Orden
	match d.get("tipo", ""):
		"mover":
			o = OrdenMover.new()
		"atacar":
			o = OrdenAtacar.new()
		"detener":
			o = OrdenDetener.new()
		_:
			return null
	o.equipo = d.equipo
	o.paso = d.paso
	o.unidades = PackedInt32Array(d.unidades)
	o._leer(d)
	return o


## Las subclases añaden sus datos aquí.
func _escribir(_d: Dictionary) -> void:
	pass


func _leer(_d: Dictionary) -> void:
	pass


## Aplica la orden. Solo afecta a unidades vivas del propio equipo.
func aplicar(_sim: Simulacion) -> void:
	pass


static func _v3(v: Vector3) -> Array:
	return [v.x, v.y, v.z]


static func _a_v3(a: Array) -> Vector3:
	return Vector3(a[0], a[1], a[2])
