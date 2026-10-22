## Reparte un grupo de unidades en huecos alrededor de un destino (GDD 15.1 y 19.3).
## Sin línea: un bloque de filas mirando hacia donde van. Con línea (arrastrar con clic
## derecho): filas del ancho arrastrado. Cada hueco lleva un pequeño desorden fijo por
## unidad para que no vayan en bloque perfecto.
class_name Formacion
extends RefCounted

## Metros entre soldados.
const SEPARACION := 3.0
## Desorden máximo de cada hueco, en metros.
const DESORDEN := 0.7


## Devuelve un hueco por unidad, en el mismo orden que `lista`.
static func posiciones(lista: Array, destino: Vector3, direccion: Vector3, ancho_linea: float) -> Array[Vector3]:
	var n := lista.size()
	var res: Array[Vector3] = []
	res.resize(n)
	if n == 0:
		return res
	var dir := Vector3(direccion.x, 0, direccion.z)
	dir = dir.normalized() if dir.length() > 0.01 else Vector3.FORWARD
	var lado := Vector3(-dir.z, 0, dir.x)
	var columnas: int
	if ancho_linea > 0.0:
		columnas = clampi(int(ancho_linea / SEPARACION) + 1, 1, n)
	else:
		columnas = clampi(ceili(sqrt(n * 2.0)), 1, n)
	var filas := ceili(float(n) / columnas)

	# Las unidades más adelantadas van a la primera fila y, dentro de cada fila,
	# se ordenan de izquierda a derecha para que no se crucen.
	var orden := range(n)
	orden.sort_custom(func(a, b): return lista[a].posicion.dot(dir) > lista[b].posicion.dot(dir))
	for f in filas:
		var ini := f * columnas
		var fin := mini(ini + columnas, n)
		var fila: Array = orden.slice(ini, fin)
		fila.sort_custom(func(a, b): return lista[a].posicion.dot(lado) < lista[b].posicion.dot(lado))
		var en_fila := fila.size()
		for c in en_fila:
			var i: int = fila[c]
			var x := (c - (en_fila - 1) * 0.5) * SEPARACION
			var z := -f * SEPARACION
			var p := destino + lado * x + dir * z + _desorden(lista[i].id)
			res[i] = Vector3(p.x, destino.y, p.z)
	return res


## Desplazamiento fijo para cada id, siempre el mismo.
static func _desorden(id: int) -> Vector3:
	var h := hash(id * 7919 + 17)
	var a := float(h % 6283) / 1000.0
	var r := float((h / 6283) % 1000) / 1000.0 * DESORDEN
	return Vector3(cos(a) * r, 0, sin(a) * r)
