---
name: godot-probar
description: Ejecutar las pruebas automáticas, la partida automática o una captura de WARRTS en Godot sin ventana. Úsala antes de dar por terminado cualquier cambio de código.
---

1. Busca el binario de Godot 4.3. Si no está, descárgalo en el directorio temporal de la sesión:
   `curl -sSL -o g.zip https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip && unzip -q g.zip`
2. Importa el proyecto una vez: `godot --headless --path . --import`.
3. Pruebas: `godot --headless --path . -s tests/run_tests.gd`. Deben pasar todas.
4. Partida automática: `godot --headless --path . -- --autotest`. Debe terminar con «RESULTADO: OK». Filtra el ruido con `grep -v "mesh_get_surface_count\|Parameter \"m\" is null\|^ *at: "`.
5. Captura: `xvfb-run -a godot --path . --rendering-driver opengl3 -- --zoom=45 --captura=RUTA.png` y mírala.
6. Apunta el resultado (pruebas que pasan, ms por paso de la partida automática, unidades atascadas) para el informe de fase.
