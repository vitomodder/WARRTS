# Cómo se prueba WARRTS

## Pruebas automáticas (sin ventana)

```
godot --headless --path . --import                       # solo la primera vez
godot --headless --path . -s tests/run_tests.gd          # todas
godot --headless --path . -s tests/run_tests.gd -- --solo=movimiento   # solo un archivo
```

Cada archivo `tests/test_*.gd` hereda de `Prueba` (`tests/prueba.gd`) y sus funciones `test_*` se ejecutan solas. Pueden esperar fotogramas: `escenario()` crea un mapa pequeño con navegación y una simulación parada que la prueba avanza a mano con `sim.avanzar(segundos)`. Sale con código 1 si alguna falla.

| Archivo | Qué comprueba |
| --- | --- |
| `test_datos.gd` | Las 6 clases de `data/unidades/` cargan, con valores positivos y letras de icono distintas; parámetros de partida básicos |
| `test_ordenes.gd` | Las órdenes se guardan y se leen como diccionario sin perder nada; se aplican en el paso siguiente y quedan en el registro; un equipo no puede mandar unidades de otro |
| `test_movimiento.gd` | Llegar al destino, rodear un muro, formación en línea, 30 soldados sin solaparse, encadenar órdenes, detener, atacar (se acerca justo hasta su alcance), ataque-movimiento, y que la misma partida da siempre el mismo resultado |
| `test_seleccion.gd` | Selección, Shift para añadir y quitar, grupos Ctrl + número, Tab entre tipos, quitar los muertos |
| `test_controles.gd` | Ratón y teclado simulados: recuadro, clic, Shift, doble clic, mover, atacar, línea, ataque-movimiento, detener, grupos, Tab y Esc; no se pueden seleccionar enemigos |
| `test_rendimiento.gd` | 300 soldados moviéndose a la vez: el paso de simulación debe tardar menos de 10 ms de media |

## Partida automática

```
godot --headless --path . -- --autotest
```

Mapa de pruebas de 2 × 2 km con 300 soldados (100 por equipo). Cada 10 s de juego, los 3 equipos reciben órdenes al azar (siempre las mismas): mover, mover en línea, ataque-movimiento, atacar y detener. Tras 180 s imprime el tiempo medio y máximo de cada paso, las órdenes registradas y cuántas unidades se han quedado atascadas. Termina con `RESULTADO: OK` (código 0) o `RESULTADO: FALLO` (código 1).

Los errores `Parameter "m" is null` y `mesh_get_surface_count` del modo sin ventana se pueden ignorar.

## Datos frente al GDD

```
python3 tools/comprobar_gdd.py
```

Compara `data/partida.tres` y `data/unidades/*.tres` con las tablas 3.2, 6.2, 13.3, 13.5 y 13.6 del GDD y lista las diferencias.

## Captura de pantalla y FPS

```
xvfb-run -a godot --path . --rendering-driver opengl3 -- --zoom=45 --captura=/ruta/captura.png
xvfb-run -a godot --path . --rendering-driver opengl3 -- --fps
```

En la nube no hay tarjeta gráfica, así que los FPS de allí no valen. La medida buena es la del PC de Vito: el número de FPS sale arriba a la izquierda durante la partida.

## Para Vito

1. Abre Godot 4.3, pulsa **Importar** y elige `project.godot`.
2. Pulsa **F5** para jugar.
