## Ejecutor de pruebas sin ventana.
## Uso: godot --headless --path . -s tests/run_tests.gd
## Carga cada tests/test_*.gd, llama a sus funciones test_* (pueden esperar fotogramas)
## y sale con código 1 si alguna falla. Se puede filtrar: -- --solo=movimiento
extends SceneTree


func _initialize() -> void:
	_correr()


func _correr() -> void:
	# El árbol aún no está listo dentro de _initialize.
	await process_frame
	var filtro := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--solo="):
			filtro = a.trim_prefix("--solo=")
	var total := 0
	var fallos := 0
	var dir := DirAccess.open("res://tests")
	var archivos: Array = []
	for f in dir.get_files():
		if f.begins_with("test_") and f.ends_with(".gd") and (filtro.is_empty() or filtro in f):
			archivos.append(f)
	archivos.sort()
	for f in archivos:
		var prueba: Prueba = load("res://tests/" + f).new()
		prueba.arbol = self
		for m in prueba.get_method_list():
			var nombre: String = m.name
			if not nombre.begins_with("test_"):
				continue
			total += 1
			prueba.errores.clear()
			var inicio := Time.get_ticks_msec()
			await prueba.call(nombre)
			await prueba.limpiar_escenario()
			var ms := Time.get_ticks_msec() - inicio
			if prueba.errores.is_empty():
				print("  OK    %s · %s (%d ms)" % [f, nombre, ms])
			else:
				fallos += 1
				print("  FALLO %s · %s" % [f, nombre])
				for e in prueba.errores:
					print("        " + e)
	print("\n%d de %d pruebas pasan" % [total - fallos, total])
	quit(1 if fallos > 0 else 0)
