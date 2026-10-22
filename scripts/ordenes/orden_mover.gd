## Mover, ataque-movimiento y marcha encadenada (GDD 15.1).
class_name OrdenMover
extends Orden

var destino: Vector3 = Vector3.ZERO
## Hacia dónde miran al llegar. Si es cero, miran hacia donde iban.
var mirar: Vector3 = Vector3.ZERO
## Ancho de la línea si el jugador arrastró con clic derecho; 0 = formación automática.
var ancho_linea: float = 0.0
## Ctrl + clic derecho: avanzan y atacan lo que encuentren.
var atacar_por_el_camino: bool = false
## Shift + clic derecho: se añade a las órdenes que ya tenían.
var encadenar: bool = false


func tipo() -> String:
	return "mover"


func _escribir(d: Dictionary) -> void:
	d.destino = _v3(destino)
	d.mirar = _v3(mirar)
	d.ancho_linea = ancho_linea
	d.atacar_por_el_camino = atacar_por_el_camino
	d.encadenar = encadenar


func _leer(d: Dictionary) -> void:
	destino = _a_v3(d.destino)
	mirar = _a_v3(d.mirar)
	ancho_linea = d.ancho_linea
	atacar_por_el_camino = d.atacar_por_el_camino
	encadenar = d.encadenar


func aplicar(sim: Simulacion) -> void:
	var lista := sim.unidades_de_orden(self)
	if lista.is_empty():
		return
	var centro := Vector3.ZERO
	for u in lista:
		centro += u.posicion
	centro /= lista.size()
	var dir := mirar
	if dir == Vector3.ZERO:
		dir = destino - centro
	var huecos := Formacion.posiciones(lista, destino, dir, ancho_linea)
	for i in lista.size():
		var u: Unidad = lista[i]
		if not encadenar:
			u.limpiar_ordenes()
		u.encolar_destino(huecos[i], dir if mirar != Vector3.ZERO else Vector3.ZERO, atacar_por_el_camino)
		sim.pedir_ruta(u)
