# WARRTS

RTS multijugador de guerra moderna en **Godot 4.3 + GDScript**. Vito dirige y prueba; no programa. Habla con él en español, sin jerga.

## Documentos (leer antes de programar)

- `docs/GDD.md`: diseño completo y **fuente de verdad**. Si el código y el GDD no coinciden, gana el GDD. Imágenes en `docs/arte/`.
- `docs/ARQUITECTURA.md`: cómo se construye (capas, órdenes, unidades por piezas, IA en tres niveles, daño, mundo, red).
- `docs/AUDITORIA.md`: qué se aprovecha del prototipo y qué se rehace.
- `docs/DECISIONES.md`: decisiones técnicas. Apunta aquí las nuevas.
- `docs/PRUEBAS.md`: cómo se prueba cada cosa.

## Reglas

- Trabaja por fases (prompt maestro de Vito). Al terminar una fase, para y espera su visto bueno.
- Números en `data/`, nunca en medio del código. Comprueba con `python3 tools/comprobar_gdd.py`.
- Toda acción del jugador o de la IA es una orden (`scripts/ordenes/`) que pasa por `Simulacion.enviar()`. La lógica solo cambia dentro de `Simulacion.avanzar_paso()`.
- Nunca copies código, datos, nombres ni recursos de otros juegos.
- Pregunta a Vito cualquier cambio que altere cómo se juega.
- Commits en español, una rama por fase (`fase-N-nombre`) y una pull request al terminar.

## Probar

```
godot --headless --path . -s tests/run_tests.gd    # pruebas
godot --headless --path . -- --autotest            # partida automática
```

Skills del proyecto en `.claude/skills/`: `godot-probar`, `unidad-desde-gdd`, `balance-sincronizar`, `informe-de-fase`.

## Estado

- Fase 0 (auditoría y arquitectura): hecha.
- Fase 1 (núcleo: mapa de pruebas, cámara, selección, órdenes, 300 unidades): hecha, pendiente del visto bueno de Vito.
- El prototipo antiguo se borró en la Fase 1; sigue en el historial de `main`.

## Mapa del código

- `escenas/partida.tscn` + `scripts/partida/partida.gd`: arranque, despliegue, partida automática.
- `scripts/partida/simulacion.gd`: reloj a paso fijo, órdenes, rutas, separación.
- `scripts/mundo/`: mapa, rejilla de bloqueo de 1 m, navegación, índice espacial.
- `scripts/unidades/`: definición (`UnidadDef`), unidad y formaciones.
- `scripts/ordenes/`: órdenes y `Comandos` (cola y registro).
- `scripts/interfaz/`: cámara, selección, controles del jugador e interfaz.
