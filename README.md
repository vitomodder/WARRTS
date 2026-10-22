# WARRTS

RTS multijugador de guerra moderna inspirado en WARDOGS (reglas) y Defilade (estética).
Tres equipos luchan por una zona de guerra central: puntúa el equipo con más
**medida de guerra** dentro de la zona y gana el primero que llega a **100 puntos**.
El dinero **solo se gana eliminando enemigos**.

Hecho con **Godot 4** (probado en 4.3; también abre en versiones 4.x más nuevas).
Las reglas completas están en el documento de diseño (GDD) del proyecto.

## Cómo probarlo (Fase 1)

1. Abre Godot 4.3, pulsa **Importar** y elige el archivo `project.godot` de esta carpeta.
2. Pulsa **Ejecutar** (F5).

Llevas a **Patriot** (azul). Hay 100 soldados por equipo en un mapa de pruebas de 2 × 2 km.
En esta fase solo se mueven: aún no disparan ni hay dinero (eso llega en las fases siguientes).
Los controles salen abajo a la izquierda de la pantalla.

| Acción | Control |
|---|---|
| Seleccionar | Clic izquierdo o arrastrar un recuadro (Shift para añadir o quitar, doble clic para todos los del mismo tipo en pantalla) |
| Mover / atacar | Clic derecho en el suelo o sobre un enemigo |
| Formar en línea | Arrastrar con el clic derecho: el largo es el ancho de la línea y miran hacia delante |
| Ataque-movimiento | Ctrl + clic derecho |
| Encadenar órdenes | Shift + clic derecho |
| Detener | Espacio |
| Grupos | Ctrl + número para guardar, número para elegir (dos veces para centrar la cámara) |
| Tipo activo | Tab |
| Cámara | WASD, flechas o ratón en el borde; rueda para el zoom; botón central para girar |
| Ir a la base / al centro | H / N |
| Velocidad del juego (pruebas) | RePág / AvPág, P para pausa |

## Dónde se cambia cada cosa

- `data/partida.tres`: parámetros de la partida (dinero, límites, tiempos).
- `data/unidades/*.tres`: cada clase de soldado (coste, vida, velocidad, alcance, visión).

Se pueden abrir y editar en el inspector de Godot sin programar. El diseño completo está en `docs/GDD.md`.

## Prueba automática

`godot --headless --path . -- --autotest` mueve los 3 equipos con órdenes al azar durante
180 segundos de juego y mide el rendimiento. Más detalles en `docs/PRUEBAS.md`.
