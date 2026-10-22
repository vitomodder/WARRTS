---
name: unidad-desde-gdd
description: Añadir o actualizar una unidad de WARRTS copiando sus datos del GDD a data/ y comprobándolo con una prueba.
---

1. Localiza la unidad en `docs/GDD.md`: clase o vehículo (Partes 6, 7 u 8), daño por unidad (13.3 o 13.4), mecánicas (Parte 14), comportamiento (14.20 y 14.21), animaciones y efectos (19.3) y boceto (12.7 a 12.9).
2. Crea o actualiza su `UnitDef` en `data/unidades/<id>.tres` con las piezas de `docs/ARQUITECTURA.md` §5. Ningún número en el código.
3. Si tiene armas nuevas, añádelas en `data/armas/` (arma → proyectil → efecto).
4. Añade su fila de daño a `data/danio.tres` tal como está en el GDD.
5. Escribe o amplía una prueba en `tests/` que compruebe su vida, coste y daño contra al menos una unidad de cada blindaje.
6. Ejecuta `godot-probar` y `balance-sincronizar`.
7. Si el GDD no dice algo que necesitas, no lo inventes: apúntalo como pregunta para Vito.
