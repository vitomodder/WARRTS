## Espacio: las unidades se paran y olvidan sus órdenes (GDD 15.2).
class_name OrdenDetener
extends Orden


func tipo() -> String:
	return "detener"


func aplicar(sim: Simulacion) -> void:
	for u in sim.unidades_de_orden(self):
		u.limpiar_ordenes()
