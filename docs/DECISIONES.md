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
| 2026-10-22 | Rejilla de bloqueo de 1 m en `Mundo`, además de la malla de navegación | En Godot 4.3 preguntar al navegador por el punto más cercano recorre todos los polígonos del mapa (0,3 ms cada vez). Con la rejilla, separar 300 soldados pasó de 18 ms a 2 ms por paso |
| 2026-10-22 | Si el camino recto está libre y mide menos de 150 m, no se pide ruta al navegador | Cada ruta del navegador cuesta 1 a 1,5 ms en un mapa de 2 km. La mayoría de órdenes cortas y persecuciones van en línea recta |
| 2026-10-22 | Presupuesto de 5 ms por paso para calcular rutas; el resto espera al paso siguiente | Evita tirones cuando se mandan muchas unidades lejos a la vez. Un grupo de 100 puede tardar hasta 3 s en arrancar entero |
| 2026-10-22 | Al perseguir, solo se recalcula la ruta si el objetivo se ha alejado más de 3 m (o el 10% de la distancia) | Menos rutas sin cambiar cómo se juega |
| 2026-10-22 | Pendiente para la Fase 7 (mapas de 10 km): rutas por grupo y navegación por bloques | En 10 km la búsqueda de polígonos del navegador de Godot 4.3 será más lenta. Se valorará también actualizar a una 4.x más nueva |
