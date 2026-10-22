# Cómo se prueba WARRTS

## Pruebas automáticas (sin ventana)

```
godot --headless --path . --import           # solo la primera vez
godot --headless --path . -s tests/run_tests.gd
```

Cada archivo `tests/test_*.gd` hereda de `Prueba` (`tests/prueba.gd`) y sus funciones `test_*` se ejecutan solas. Sale con código 1 si alguna falla.

| Archivo | Qué comprueba |
| --- | --- |
| `test_datos.gd` | Que cada unidad tiene todos sus datos, valores positivos y fila en la tabla de daño, y que hay 3 facciones |

## Partida automática

```
godot --headless --path . -- --autotest
```

Las 3 facciones las juega la IA a velocidad ×4 y cada 30 s se imprime el estado: puntos, MG, dinero, bajas y unidades. Termina cuando alguien gana. Los errores `Parameter "m" is null` y `mesh_get_surface_count` del modo sin ventana se pueden ignorar.

## Datos frente al GDD

```
python3 tools/comprobar_gdd.py
```

Compara los parámetros generales del GDD (13.6 y 3.2) con el código y lista las diferencias. Se irá ampliando a todas las tablas (unidades, daño y construcciones) en la Fase 2.

## Captura de pantalla

```
xvfb-run -a godot --path . --rendering-driver opengl3 -- --autotest --shot=/ruta/captura.png
```

## Para Vito

1. Abre Godot 4.3, pulsa **Importar** y elige `project.godot`.
2. Pulsa **F5** para jugar.
