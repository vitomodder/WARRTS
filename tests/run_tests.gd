## Ejecutor de pruebas sin ventana.
## Uso: godot --headless --path . -s tests/run_tests.gd
## Carga cada tests/test_*.gd, llama a sus funciones test_* y sale con código 1 si alguna falla.
extends SceneTree


func _init() -> void:
	var total := 0
	var fallos := 0
	var dir := DirAccess.open("res://tests")
	var archivos: Array = []
	for f in dir.get_files():
		if f.begins_with("test_") and f.ends_with(".gd"):
			archivos.append(f)
	archivos.sort()
	for f in archivos:
		var prueba: Object = load("res://tests/" + f).new()
		for m in prueba.get_method_list():
			var nombre: String = m.name
			if not nombre.begins_with("test_"):
				continue
			total += 1
			prueba.errores.clear()
			prueba.call(nombre)
			if prueba.errores.is_empty():
				print("  OK    %s · %s" % [f, nombre])
			else:
				fallos += 1
				print("  FALLO %s · %s" % [f, nombre])
				for e in prueba.errores:
					print("        " + e)
	print("\n%d de %d pruebas pasan" % [total - fallos, total])
	quit(1 if fallos > 0 else 0)
