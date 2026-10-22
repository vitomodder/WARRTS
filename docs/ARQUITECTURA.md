# WARRTS: arquitectura técnica

Fase 0 · 22 de octubre de 2026 · Godot 4 + GDScript

Este documento dice **cómo se construye** WARRTS. **Qué** se construye está en el [GDD](GDD.md). Si los dos no coinciden, manda el GDD.

La arquitectura se apoya en patrones habituales de los RTS con muchas unidades. Varios coinciden con el estudio técnico que Vito hizo de un RTS comercial, del que solo se toman **ideas generales de organización**. No se usa código, datos, nombres ni recursos de ningún otro juego.

---

## 1. Principios

1. **El anfitrión manda.** Toda la partida se calcula en un solo sitio, el anfitrión o *host*. Los jugadores envían órdenes y reciben el resultado. En las partidas contra la IA, el anfitrión es tu propio ordenador.
2. **Toda acción es una orden.** Comprar, mover, construir o cambiar de modo es un dato que se puede guardar y enviar. La IA usa exactamente las mismas órdenes que un jugador.
3. **Los números viven en datos, no en el código.** Cada valor del GDD está en un solo archivo de `data/`, y hay una herramienta que comprueba que coinciden con las tablas.
4. **Unidades por piezas, no por herencia.** Una unidad es la suma de sus piezas: movimiento, salud, armas, asientos, visión y habilidad de clase. Una unidad nueva es una combinación nueva de piezas, no un `if tipo ==` más.
5. **Cada capa habla con la de abajo solo con datos.** Partida → Mundo → Unidades. Así cada capa se prueba por separado.
6. **Pensado para 300 unidades y mapas de 10 km desde el primer día.**

## 2. Capas

```
Partida      reglas: dinero, puntos, medida de guerra, hot zone, XP, victoria
   ↓ (órdenes y consultas)
Mundo        mapa, zona de guerra, rejilla de visión, índice espacial, navegación
   ↓
Unidades     piezas: movimiento, salud y blindaje, armas, asientos, visión, clase
   ↑
IA           comandante (equipo) → grupo → soldado
```

| Capa | Nodo o autoload | Responsabilidad |
|---|---|---|
| Partida | `Match` (autoload) | Reloj de simulación, dinero por equipo, puntos, hot zone, XP por clase, fin de partida y registro de eventos |
| Órdenes | `Commands` | Recibe órdenes, las valida, las aplica en el siguiente paso y las guarda en el registro |
| Mundo | `World` | Carga el mapa, la zona de guerra, las FOB y las construcciones; da consultas como «¿qué enemigos hay a 300 m?» |
| Visión | `VisionGrid` | Rejilla de terreno precalculada y visibilidad por equipo |
| Unidades | `Unit` + piezas | Cada unidad con sus piezas |
| IA | `AiCommander`, `AiGroup`, `AiSoldier` | Tres niveles (sección 6) |
| Red | `Net` | ENet ahora y Steam después; envía órdenes al anfitrión y estado a los clientes |
| Presentación | `Hud`, cámara, efectos | Solo lee el estado. Nunca cambia reglas |

## 3. Simulación a paso fijo

- La lógica avanza en **pasos fijos de 0,1 s** (10 por segundo), separados del dibujado (60 fps o más). El movimiento se suaviza entre pasos.
- Las órdenes llevan el número de paso en que se aplican. Por eso funcionan igual en red, en la IA y en las pruebas.
- Para las pruebas automáticas, el reloj se puede acelerar (×4, ×8) o avanzar paso a paso sin ventana.

## 4. Órdenes

Cada orden es un `Resource` pequeño con `equipo`, `paso` y sus datos.

| Orden | Datos | Parte del GDD |
|---|---|---|
| `Comprar` | tipo de unidad, punto de despliegue (base o FOB), con tripulación | 5, 10 |
| `Mover` / `AtacarMover` | unidades, destino, formación | 15 |
| `Atacar` | unidades, objetivo | 15 |
| `Subir` / `Bajar` | unidades, vehículo | 14.1 |
| `Construir` | ingeniero, tipo, posición o trazado (trinchera) | 10, 19.5 |
| `Modo` | unidades, Cobertura / Vigila / Prioridad / Alto el fuego | 14.20 |
| `Prioridad` | unidades, prioridad de clase | 14.21 |
| `Postura` | unidades, de pie / agachado / cuerpo a tierra | 14.1 |
| `UsarObjeto` | unidad, objeto (granada, humo, C4, dron), objetivo | 6, 14 |
| `ComprarMejora` | clase, mejora | 9 |
| `PelotonGratis` | — | 5 |

**El registro de órdenes** (con semilla y mapa) da tres cosas gratis:

- Pruebas reproducibles: se repite una partida y se compara el resultado.
- Las estadísticas de final de partida (11.2).
- Repeticiones más adelante.

## 5. Unidades por piezas

Cada tipo de unidad se define en `data/unidades/<id>.tres` (`UnitDef`) con estas piezas:

| Pieza | Qué guarda | Unidades |
|---|---|---|
| `Movimiento` | a pie, ruedas, orugas o vuelo; velocidad; giro | Todas |
| `Salud` | vida, clase de blindaje (13.1), blindaje trasero +50 % (14.8) | Todas |
| `Armas` | lista de armas, cada una en un **punto de montaje con nombre** (`torreta`, `artillero`, `lateral`) | Todas |
| `Asientos` | conductor o piloto, artillero, pasajeros, carga colgada | Vehículos y helicópteros |
| `Vision` | alcance, si ve aeronaves, radar (AA 1 km) | Todas |
| `Postura` | de pie, agachado, cuerpo a tierra; supresión | Infantería |
| `Peligro` | valor de 0 a 1 que mueve la IA del soldado (sección 6) | Infantería y vehículos |
| `Clase` | habilidad: curar, reparar, construir, abastecer, apuntar; objetos | Según clase |
| `Caido` | soldado en el suelo, torniquete, reanimar, arrastrar (6.1, 19.3) | Infantería |
| `Aspecto` | modelo por facción (Patriot, Jade, Sandstorm) | Todas |

Los puntos de montaje con nombre sirven también para el arte: el modelo de cada facción solo tiene que tener los mismos puntos (`torreta`, `artillero`...) y la lógica no cambia.

## 6. IA en tres niveles

La IA juega con **las mismas órdenes y el mismo dinero** que un jugador (GDD 16), sin trampas salvo las que diga el GDD para la dificultad.

| Nivel | Decide | Cada cuánto | Ejemplos |
|---|---|---|---|
| **Comandante** (1 por equipo) | Qué comprar con el dinero que hay, dónde construir FOB, qué grupo va a la zona, a la hot zone o a defender | Cada 2 a 5 s | Reserva de dinero (corrige el fallo del prototipo de gastar 1 millón en 30 s), proporción de clases por dificultad |
| **Grupo** (de 4 a 12 unidades) | Cómo cumplir su misión: tomar zona, defender, escoltar, retirarse. Lleva un **informe de amenazas** (qué enemigos hay, dónde y de qué tipo) | Cada 1 s | Si hay tanques enemigos, pide Apoyo con lanzamisiles; si hay aviones, pide antiaéreo |
| **Soldado** | Qué hace él ahora: avanzar, cubrirse, disparar, curar, reparar | Cada paso | Con **peligro** alto se cubre, con medio dispara y con bajo avanza. Aplica los modos de comportamiento de 14.20 |

- **Las misiones son datos:** `{tipo, zona, prioridad}`. El comandante las crea, el grupo las reparte y el soldado no conoce el objetivo general: sigue a su líder y reacciona a lo que ve.
- **El peligro** sube con el fuego recibido, los enemigos vistos y las explosiones cercanas, y baja con el tiempo y estando a cubierto. Es el mismo número que decide la supresión (14.1). Así el jugador entiende por qué sus soldados se tiran al suelo.
- **El jugador usa los niveles de soldado y grupo:** sus unidades se cubren y eligen objetivo solas, pero él hace de comandante.

## 7. Daño: arma → proyectil → efecto

| Paso | Qué es | Datos |
|---|---|---|
| **Arma** | Cadencia, alcance, precisión, munición | `data/armas/<id>.tres` |
| **Proyectil** | Cómo llega: bala instantánea, balístico (mortero, cañón), misil guiado, granada lanzada | Velocidad, dispersión (mortero hasta 25 m) |
| **Efecto** | Qué hace al llegar: daño a cada unidad (13.3 y 13.4), radio, supresión, humo que corta la visión (19.2) | Tabla por unidad del GDD |

La tabla de daño **por unidad** de las Partes 13.3 y 13.4 se guarda tal cual en `data/danio.tres`. Así se cumple la regla de Vito de segmentar el daño por unidad, y la herramienta `balance-sincronizar` la compara con el GDD.

## 8. Mundo

- **Mapas de 10 × 10 km** en bloques de 1 km. Solo se dibuja con detalle lo que está cerca de la cámara; lo lejano se simplifica.
- **Rejilla de visión precalculada:** al cargar el mapa se genera una rejilla de 20 m (500 × 500 celdas) con la altura y lo que tapa (bosque, edificio, colina). La visibilidad de cada equipo se recalcula 4 veces por segundo, solo para las celdas cercanas a sus unidades, y la niebla se pinta con una textura (19.1).
- **Índice espacial:** rejilla de 50 m para encontrar enemigos cercanos sin comprobar todos contra todos.
- **Navegación:** NavigationServer de Godot por bloques. Los grupos se mueven con un líder y seguidores con separación y algo de desorden, para no ir en bloque (19.3). Carreteras +30 % para vehículos y ríos solo por puentes (3.3).
- **Zona de guerra y hot zone** como estado: centro, radio, medida de guerra por equipo y próximo cambio. La regla de no estar a menos de 800 m de una FOB se calcula aquí.

## 9. Dibujado y rendimiento

- **Muchas unidades:** `MultiMeshInstance3D` para infantería lejana y animación sencilla por GPU; iconos de clase al alejar la cámara (12.2).
- **Efectos con límite:** marcas en el suelo (huellas, cráteres, sangre) con `Decal`, con un máximo por zona y borrado de las más antiguas; muertes físicas solo cerca de la cámara (19.2).
- **Objetivo:** 60 fps con 300 unidades en un equipo medio, y nunca menos de 30.

## 10. Red

- **ENet** para LAN y pruebas; **GodotSteam** para jugar en línea más adelante (Fase 9).
- Los clientes envían órdenes. El anfitrión envía el estado 10 veces por segundo, solo de lo que cada equipo puede ver, para que nadie vea la niebla de otro.
- Desconexiones: pausa y elección del compañero en 2v2v2, IA automática en 1v1v1 (11.1).

## 11. Registro económico

Cada entrada y salida de dinero se apunta: baja, construcción destruida, compra, mejora o pelotón gratis. Sirve para:

- Las estadísticas de fin de partida (11.2).
- Ajustar el balance con datos.
- Detectar fallos como el de la IA que gastaba todo al empezar.

## 12. Tutorial y avisos como guiones

Las misiones de entrenamiento (18) son listas de pasos `{condición → acción}` en datos, por ejemplo «cuando el jugador seleccione 3 soldados → mostrar el mensaje 2». Los avisos en pantalla (12.3, 19.6) salen de los mismos eventos del registro.

## 13. Carpetas

```
data/
  unidades/        UnitDef por unidad (6 soldados, 7 vehículos, 3 helicópteros)
  armas/           armas, proyectiles y efectos
  construcciones/  FOB, muros, alambre, mortero, trinchera, pozo, sacos, erizos, red
  mapas/           Montaña, Desierto, Nieve, Mixto
  partida.tres     parámetros generales (13.6)
  danio.tres       tabla de daño por unidad (13.3, 13.4)
scripts/
  partida/         Match, economía, puntos, XP, registro
  ordenes/         una clase por orden + Commands
  mundo/           World, VisionGrid, índice espacial, zona de guerra
  unidades/        Unit y sus piezas
  ia/              comandante, grupo, soldado
  red/             Net
  interfaz/        HUD, menú circular, minimapa, avisos
  efectos/         marcas, explosiones, muertes físicas
tests/             pruebas automáticas (sin ventana)
tools/             comprobación de datos frente al GDD
docs/              GDD, arquitectura, decisiones, pruebas
```

## 14. Ideas generales que no usamos

| Idea | Por qué no |
|---|---|
| Mapas generados desde mapas reales | Los 4 mapas del GDD están diseñados a mano (Parte 3) |
| Clima que cambia las reglas | Decidido: el clima es solo visual (19.1) |
| Guardar la partida por fases y campaña | WARRTS es multijugador por partidas, sin campaña |
| Muchas zonas capturables | WARRTS tiene una zona de guerra central y la hot zone (Parte 4) |
| IA de división con muchos tipos de escuadra | Con 3 equipos y 100 de población bastan los tres niveles de la sección 6 |
