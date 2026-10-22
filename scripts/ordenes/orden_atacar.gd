## Atacar a una unidad concreta: clic derecho sobre un enemigo (GDD 15.1).
class_name OrdenAtacar
extends Orden

var objetivo: int = -1


func tipo() -> String:
	return "atacar"


func _escribir(d: Dictionary) -> void:
	d.objetivo = objetivo


func _leer(d: Dictionary) -> void:
	objetivo = d.objetivo


func aplicar(sim: Simulacion) -> void:
	var blanco := sim.unidad(objetivo)
	if blanco == null or blanco.equipo == equipo:
		return
	for u in sim.unidades_de_orden(self):
		u.limpiar_ordenes()
		u.objetivo = blanco
		sim.pedir_ruta(u)
