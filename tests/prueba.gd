## Base de las pruebas: cada comprobación fallida se apunta en `errores`.
## `escenario()` crea un mapa pequeño con navegación y una simulación parada, que
## la prueba avanza a mano con `sim.avanzar()`.
class_name Prueba
extends RefCounted

var errores: Array = []
var arbol: SceneTree
var _raiz: Node3D


func comprobar(condicion: bool, mensaje: String) -> void:
	if not condicion:
		errores.append(mensaje)


func iguales(actual, esperado, mensaje: String) -> void:
	if actual != esperado:
		errores.append("%s: esperado %s, hay %s" % [mensaje, str(esperado), str(actual)])


func def(id: String) -> UnidadDef:
	return load("res://data/unidades/%s.tres" % id)


## Mapa llano de `tamano` metros sin decorado. `cajas` es una lista de [posición, tamaño].
func escenario(tamano: float = 300.0, cajas: Array = []) -> Simulacion:
	_raiz = Node3D.new()
	arbol.root.add_child(_raiz)
	var mundo := Mundo.new()
	_raiz.add_child(mundo)
	mundo.construir(tamano, 1, false)
	for c in cajas:
		mundo.agregar_caja(c[0], c[1])
	mundo.hornear()
	while not mundo.listo():
		await arbol.physics_frame
	var contenedor := Node3D.new()
	_raiz.add_child(contenedor)
	var sim := Simulacion.new()
	sim.pausada = true
	_raiz.add_child(sim)
	sim.preparar(load("res://data/partida.tres"), mundo, contenedor, Partida.COLORES)
	return sim


## Borra el escenario y espera a que el navegador lo olvide.
func limpiar_escenario() -> void:
	if _raiz == null:
		return
	_raiz.queue_free()
	_raiz = null
	await arbol.physics_frame
	await arbol.physics_frame


func mover(sim: Simulacion, lista: Array, destino: Vector3, equipo: int = 0) -> OrdenMover:
	var o := OrdenMover.new()
	o.equipo = equipo
	for u in lista:
		o.unidades.append(u.id)
	o.destino = destino
	sim.enviar(o)
	return o
