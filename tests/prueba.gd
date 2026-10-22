## Base de las pruebas: cada comprobación fallida se apunta en `errores`.
class_name Prueba
extends RefCounted

var errores: Array = []


func comprobar(condicion: bool, mensaje: String) -> void:
	if not condicion:
		errores.append(mensaje)


func iguales(actual, esperado, mensaje: String) -> void:
	if actual != esperado:
		errores.append("%s: esperado %s, hay %s" % [mensaje, str(esperado), str(actual)])
