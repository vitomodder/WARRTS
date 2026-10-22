# Auditoría del prototipo frente al GDD v1.0

Fase 0 · 22 de octubre de 2026

El prototipo (`scripts/`, unas 2.500 líneas) se hizo el 20 de octubre, antes de cerrar el GDD. Arranca bien en Godot 4.3, y la partida automática con 3 IA termina con un ganador a los 788 s. Pero muchas reglas son de la versión antigua del diseño.

## Resultado por sistema

| Sistema | Archivo | Decisión | Por qué |
|---|---|---|---|
| Cámara isométrica, zoom y desplazamiento | `rts_camera.gd` | **Se adapta** | Funciona. Falta el giro, el zoom hasta 10 km y los iconos al alejar (12.2) |
| Selección, recuadro y órdenes con el ratón | `main.gd` | **Se adapta** | Funciona. Se pasa a `interfaz/` y a las órdenes nuevas (sección 4 de ARQUITECTURA) |
| Órdenes `cmd_*` | `main.gd` | **Se mantiene la idea** | Ya es el patrón correcto. Se convierten en objetos `Resource` con paso y registro |
| Partida automática (`--autotest`) | `main.gd` | **Se mantiene** | Base de las pruebas. Se mueve a `tests/` |
| Mapa de 800 m con rocas, bosques y ruinas al azar | `map_builder.gd` | **Se rehace** | El GDD pide 4 mapas de 10 km diseñados (Parte 3) y bases a 4 km del centro |
| Navegación con NavigationServer | `map_builder.gd` | **Se adapta** | La idea sirve; hay que dividirla en bloques de 1 km |
| Zona de guerra y hot zone | `war_zone.gd` | **Se adapta** | La lógica de medida de guerra sirve. Cambian los números: zona de 2 a 3 km, hot zone de 400 m cada 5 min con 60 s de aviso, nunca a menos de 800 m de una FOB |
| Datos de unidades | `game_data.gd` | **Se rehace** | Unidades antiguas (dron como vehículo, transporte blindado, artillería, conductor y piloto separados). El GDD tiene 6 clases, 7 vehículos y 3 helicópteros con otros números |
| Daño por tipo × blindaje | `game_data.gd` | **Se rehace** | El GDD pide daño segmentado por unidad (13.3 y 13.4) |
| Unidad (todo en un archivo) | `unit.gd`, `entity.gd` | **Se rehace** | 490 líneas con todo mezclado. Pasa a unidades por piezas |
| Edificios y FOB | `building.gd` | **Se adapta** | La construcción con progreso sirve. Faltan las reglas de distancia, vida en zona y premio de 10.2 |
| IA | `ai_controller.gd` | **Se rehace** | Un solo nivel y gasta 1 millón en 30 s. Pasa a la IA en tres niveles con reserva de dinero |
| Interfaz | `hud.gd`, `minimap.gd` | **Se adapta** | Sirve de base. Faltan las pestañas, el menú circular, la lista del grupo y los avisos (12.3, 19.6) |
| Nombres de facción | `game_data.gd` | **Se cambia** | Siguen los antiguos (Coalición Atlántica, Ejército del Este, Guardia del Desierto). Ahora son Patriot, Jade y Sandstorm |

## Qué falta por completo

- Posturas, supresión, peligro y modos de comportamiento (14.1, 14.20, 14.21)
- Soldado caído, torniquete, reanimar y arrastrar (6.1, 19.3)
- XP por clase, rangos y mejoras (Parte 9)
- Mortero, trinchera, pozo, sacos, erizos y red de camuflaje (10, 19.5)
- Rejilla de visión y niebla de guerra (13.5, 19.1)
- Multijugador (Parte 11), tutorial (18), efectos (19)

## Recomendación

**Rehacer la base con la arquitectura nueva y traer las piezas que funcionan**: cámara, selección, navegación, zona de guerra, construcción, interfaz y partida automática. Unos 7 de 11 archivos se reaprovechan en parte. Lo que se rehace (datos, unidad, IA, mapa) es justo lo que el GDD cambió.

Adaptar el código antiguo pieza a pieza costaría más. Habría que deshacer el diseño viejo de `unit.gd` y `game_data.gd` en cada fase.

El prototipo antiguo queda en la rama `main` hasta que la Fase 1 lo sustituya, así que siempre se puede volver a él.
