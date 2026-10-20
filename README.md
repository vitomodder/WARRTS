# WARRTS

RTS multijugador de guerra moderna inspirado en WARDOGS (reglas) y Defilade (estética).
Tres equipos luchan por una zona de guerra central: puntúa el equipo con más
**medida de guerra** dentro de la zona y gana el primero que llega a **100 puntos**.
El dinero **solo se gana eliminando enemigos**.

Hecho con **Godot 4** (probado en 4.3; también abre en versiones 4.x más nuevas).
Las reglas completas están en el documento de diseño (GDD) del proyecto.

## Cómo jugar el prototipo

1. Abre Godot, pulsa **Importar** y elige el archivo `project.godot` de esta carpeta.
2. Pulsa **Ejecutar** (F5).

Tú eres la **Coalición Atlántica** (azul). Los otros dos equipos los lleva la IA.
Empiezas con 1.000.000 $ en tu base: compra unidades con los botones de abajo y llévalas
a la zona de guerra (círculo naranja). La hot zone (círculo rojo) puntúa doble y cambia de
sitio cada 3 minutos (se avisa 30 segundos antes con un círculo amarillo).

| Acción | Control |
|---|---|
| Seleccionar | Clic izquierdo o arrastrar un recuadro (Mayús para añadir, doble clic para todas las del mismo tipo) |
| Mover / atacar | Clic derecho en el suelo o sobre un enemigo |
| Ataque-movimiento | Ctrl + clic derecho |
| Subir a un vehículo / robar uno enemigo vacío | Selecciona infantería y clic derecho sobre el vehículo |
| Bajar del vehículo | E |
| Pelotón gratis (si tienes menos de 20.000 $) | F |
| Mover cámara | WASD, flechas, ratón en el borde o clic en el minimapa |
| Zoom | Rueda del ratón |
| Ir a la base / a la hot zone | H / Z |
| Cancelar | Esc |

Los vehículos se compran vacíos y necesitan un conductor (o un piloto si vuelan). Con la
opción "Vehículos con tripulación: SÍ" se compra el conductor o piloto a la vez.
Los ingenieros construyen **zonas de despliegue avanzadas** (selecciona un ingeniero y pulsa
el botón): después puedes elegir desplegar ahí las unidades de tierra.

## Dónde se cambia cada cosa

- `scripts/game_data.gd`: precios, medida de guerra, vida, daño, alcance, recompensas, puntuación.
- `scripts/unit.gd`: unidades (movimiento, combate, tripulación, pasajeros).
- `scripts/building.gd`: base y zonas de despliegue.
- `scripts/map_builder.gd`: mapa, obstáculos y navegación.
- `scripts/war_zone.gd`: zona de guerra, hot zone y puntuación.
- `scripts/ai_controller.gd`: IA.
- `scripts/main.gd`: partida, economía, órdenes del jugador (`cmd_*`).
- `scripts/hud.gd`, `scripts/minimap.gd`: interfaz.

## Prueba automática

`godot --headless --path . -- --autotest` hace que la IA juegue los 3 equipos a velocidad x4
e imprime el estado cada 30 segundos de juego hasta que uno gana.
