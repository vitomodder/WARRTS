# WARRTS

RTS de guerra moderna con 3 facciones que luchan a la vez. Empiezas con una cantidad de dinero
y **solo ganas dinero eliminando unidades y edificios enemigos**.

Hecho con **Godot 4** (probado en 4.3; también abre en versiones 4.x más nuevas).

## Cómo jugar el prototipo

1. Abre Godot, pulsa **Importar** y elige el archivo `project.godot` de esta carpeta.
2. Pulsa **Ejecutar** (F5).

Controles:

| Acción | Control |
|---|---|
| Seleccionar | Clic izquierdo o arrastrar un recuadro (Mayús para añadir) |
| Mover / atacar | Clic derecho en el suelo o sobre un enemigo |
| Ataque-movimiento | Ctrl + clic derecho |
| Mover cámara | WASD, flechas o ratón en el borde |
| Zoom | Rueda del ratón |
| Volver a la base | H |
| Cancelar | Esc |

Tú eres la **Coalición** (azul). La Federación (roja) y la Insurgencia (amarilla) las controla la IA.
Ganas si destruyes los cuarteles generales de las otras dos facciones.

## Dónde se cambia cada cosa

- `scripts/game_data.gd`: precios, vida, daño, alcance, recompensa por baja, dinero inicial.
- `scripts/unit.gd`: comportamiento de las unidades.
- `scripts/building.gd`: edificios y producción.
- `scripts/ai_controller.gd`: IA enemiga.
- `scripts/main.gd`: mapa, economía, selección y órdenes.
- `scripts/hud.gd`: interfaz.

## Prueba automática

`godot --headless --path . -- --autotest` hace que la IA juegue las 3 facciones e imprime el estado
cada 30 segundos de juego hasta que una gana.
