# Decisiones técnicas

Decisiones que no cambian cómo se juega y que se pueden revisar. Las de diseño están en el [GDD](GDD.md).

| Fecha | Decisión | Por qué |
|---|---|---|
| 2026-10-22 | Godot 4.3 y GDScript | Es lo que usa el prototipo. Se actualizará a una 4.x más nueva solo si hace falta algo concreto |
| 2026-10-22 | Lógica a paso fijo de 0,1 s, separada del dibujado | Red, IA y pruebas ven lo mismo (ARQUITECTURA §3) |
| 2026-10-22 | Datos en `.tres` dentro de `data/` | Se editan en el inspector de Godot sin programar |
| 2026-10-22 | Pruebas con un ejecutor propio en `tests/` en vez de GUT | Sin dependencias externas por ahora. Si crecen mucho, se valora GUT (licencia MIT) |
| 2026-10-22 | Rehacer la base y reaprovechar piezas del prototipo | Ver [AUDITORIA](AUDITORIA.md) |
| 2026-10-22 | El estudio técnico de otro RTS se usa solo como inspiración de organización | No se copia código, datos, nombres ni recursos de ningún juego (GDD Parte 19 y regla general del proyecto) |
