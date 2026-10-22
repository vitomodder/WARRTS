## 300 soldados moviéndose a la vez (objetivo de la Fase 1).
extends Prueba

## Milisegundos como mucho de media por paso. El paso dura 100 ms, así que esto deja
## sitio de sobra para el dibujo, la IA y la red.
const MS_MAXIMO := 10.0


func test_300_unidades() -> void:
	var cajas: Array = []
	for i in 12:
		cajas.append([Vector3(-250 + i * 45, 0, (i % 3 - 1) * 60), Vector3(10, 4, 12)])
	var sim: Simulacion = await escenario(700.0, cajas)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for equipo in 3:
		var lista: Array = []
		for i in 100:
			var p := Vector3(-300 + equipo * 250 + (i % 10) * 3.0, 0, -320 + (i / 10) * 3.0)
			lista.append(sim.crear_unidad(def("asalto"), equipo, p))
		for g in 5:
			mover(sim, lista.slice(g * 20, g * 20 + 20), Vector3(rng.randf_range(-300, 300), 0, rng.randf_range(0, 300)), equipo)
	var suma := 0.0
	var pasos := 300
	for i in pasos:
		sim.avanzar_paso()
		suma += sim.ms_ultimo_paso
	var media := suma / pasos
	print("        300 unidades: %.2f ms de media por paso, máximo %.2f ms" % [media, sim.ms_paso_maximo])
	comprobar(media < MS_MAXIMO, "media por paso %.2f ms (máximo %.1f)" % [media, MS_MAXIMO])
