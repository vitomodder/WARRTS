# WARRTS: documento de diseño (GDD)

Oct 20, 2026 · @Vito · Versión 1.0, base completa

Este documento es la referencia del juego y sustituye a la ficha de unidades antigua. Los números son una base que se ajustará al probar el juego. El estado de cada parte está en la tabla del final.

## Parte 1. Visión y modos de juego

WARRTS es un RTS multijugador de guerra moderna con las reglas de WARDOGS y la estética isométrica de Defilade. **Tres equipos** salen de sus bases en **mapas enormes** y luchan por una **zona de guerra central**. Gana el primero que llegue a **100 puntos**, que se consiguen teniendo más **medida de guerra** que nadie dentro de la zona. El dinero **solo se gana eliminando enemigos**.

| Modo | Jugadores | Control |
| --- | --- | --- |
| 1 vs 1 vs 1 | 3 | Cada jugador lleva un equipo |
| 2 vs 2 vs 2 | 6 | Dos jugadores por equipo; se reparten las tareas como quieran |
| Contra IA | 1–5 | Los huecos vacíos los ocupa la IA |

## Parte 2. Facciones

- Las tres facciones tienen **exactamente las mismas unidades y edificios, con los mismos datos**. Solo cambia el **diseño visual** (uniformes, vehículos, edificios).
- No hay lore: como en WARDOGS, el contexto es mínimo. El país donde se lucha es ficticio.

| Facción | Estilo visual inspirado en |
| --- | --- |
| Patriot | Estadounidense |
| Jade | Chino |
| Sandstorm | Árabe |

**Decidido:** los nombres son en clave, como en WARDOGS: **Patriot**, **Jade** y **Sandstorm**.

## Parte 3. Mapas

- **4 mapas iniciales**: montaña, desierto, nieve y mixto.
- Tamaño: **10 × 10 km** para empezar; más adelante se puede ampliar.
- Cada equipo tiene una **base de salida** en una de las **tres puntas de un triángulo**, donde despliega sus unidades.
- En el centro, la **zona de guerra**, de **2 a 3 km de diámetro**.
- Dentro de ella, la **hot zone** (un círculo), que **se mueve a un sitio aleatorio** de la zona de guerra cada cierto tiempo.
- Por el tamaño, los transportes y las zonas de despliegue avanzadas son clave para llegar al frente.

### 3.1 Distribución del mapa *(propuesta)*

- Las 3 bases están a unos **4 km del centro** del mapa. Desde cada base hasta el borde de la zona de guerra hay unos **2,5 a 3 km de tierra de nadie**: a pie son unos 11 minutos, en Hummer unos 4.
- Colocación como en WARDOGS: una base abajo en el centro y las otras dos arriba, una en la esquina izquierda y otra en la derecha, todas a la misma distancia de la zona de guerra, que queda justo en el centro del mapa. Cada base tiene **su propio camino** (una carretera directa) hacia la zona de guerra, para que ningún equipo tenga que pasar por la base de otro.
- **Las bases no se pueden destruir.** Tienen defensas automáticas que atacan a cualquier enemigo a menos de 300 m, para que nadie mate a las unidades nada más aparecer. Se gana por puntos, no destruyendo bases.
- La **zona de guerra** es un círculo en el centro, marcado en el suelo y en el minimapa.

### 3.2 Hot zone *(propuesta)*

| Parámetro | Valor |
| --- | --- |
| Forma y tamaño | Círculo de 400 m de diámetro |
| Al empezar la partida | Aparece en el centro de la zona de guerra |
| Cada cuánto se mueve | Cada 5 minutos |
| Aviso | 60 s antes se marca en el minimapa dónde irá la siguiente |
| Dónde aparece | En un sitio aleatorio de la zona de guerra, nunca a menos de 800 m de una FOB, para que ningún equipo la tenga en la puerta |
| Qué da | La MG cuenta doble (Parte 4), las bajas pagan el 75% (Parte 5) y la XP vale el doble (Parte 9) |

### 3.3 Terreno *(propuesta)*

- **Colinas, rocas, bosques y edificios tapan la vista y los disparos.** Son lo que decide si el francotirador con .50 o el tanque lanzamisiles pueden disparar de lejos.
- **Carreteras:** los vehículos van un 30% más rápido por ellas.
- **Ríos:** los vehículos solo los cruzan por los puentes; la infantería puede vadearlos, pero va a la mitad de velocidad.
- **Pueblos:** casas que sirven de cobertura a la infantería; los tanques no pueden entrar en las calles estrechas.

### 3.4 Los 4 mapas *(propuesta)*

| Mapa | Zona de guerra | Cómo es | Qué favorece |
| --- | --- | --- | --- |
| Montaña | 2 km | Valles con carreteras y crestas altas; pasos estrechos | Francotiradores, morteros y helicópteros |
| Desierto | 3 km | Muy abierto, dunas y pocas coberturas; se ve muy lejos | Tanques y tanque lanzamisiles |
| Nieve | 2,5 km | Bosques y un lago helado; la nieve frena un 20% a la infantería | Vehículos y emboscadas en el bosque |
| Mixto | 2,5 km | Un pueblo en el centro, un río con puentes, campos y bosques | Un poco de todo; el mapa más equilibrado |

### 3.5 Reglas de diseño de los mapas *(propuesta)*

- **Justos para los 3 equipos:** las 3 bases están a la misma distancia del centro, y cada equipo tiene su carretera, su zona de bosque o cobertura y su sitio para la FOB en el borde de la zona de guerra. El terreno no es idéntico, pero ningún equipo tiene ventaja.
- **3 caminos por equipo hacia la zona:** la carretera (rápida pero vigilada), un camino a cubierto (bosque, zanja o valle) para la infantería y un flanco abierto para los tanques.
- **Tierra de nadie con vida:** entre las bases y la zona hay bosques, colinas y algún edificio suelto, para que el camino también tenga emboscadas.
- **La zona de guerra es lo más detallado:** pueblo, edificios, muros y coberturas; fuera de la zona el terreno puede ser más simple.
- **La hot zone nunca cae en un sitio imposible:** no aparece dentro de un lago, en un acantilado ni a menos de 800 m de una FOB (Parte 3.2).
- **Cuadrícula de 1 km** en el minimapa, con coordenadas, para que los compañeros se entiendan como en WARDOGS.

### 3.6 Mapa 1: Montaña

&#91;image: Plano del mapa Montaña\]

- **Ambiente:** valle alpino en primavera tardía, con nieve solo en las cumbres. Luz de mañana y niebla ligera en el fondo del valle.
- **Relieve:** las 3 bases están en valles que bajan hacia un valle central rodeado de crestas. Las crestas no se pueden cruzar con vehículos; la infantería sí, despacio.
- **Zona de guerra (2 km):** el pueblo de Valle Alto en el centro, un río que la cruza de norte a sur y una presa, que es el único paso para vehículos pesados por el este.
- **Rutas:** Patriot y Jade llegan por pasos estrechos entre crestas, perfectos para emboscar. Sandstorm entra por el valle sur, más ancho pero vigilado desde la cresta sur.
- **Sitios de FOB:** en la boca de cada paso, justo antes de entrar al valle central.
- **Cómo se juega:** la altura manda. El que controla la cresta sur y los bosques ve todo el valle; los francotiradores, morteros y helicópteros son clave. Los tanques sufren en los pasos.

### 3.7 Mapa 2: Desierto

&#91;image: Plano del mapa Desierto\]

- **Ambiente:** desierto de arena y roca a mediodía, con calima a lo lejos y viento que levanta arena.
- **Relieve:** dunas bajas que casi no tapan, y mesetas de roca que son los únicos puntos altos. Se ve muy lejos.
- **Zona de guerra (3 km):** la más grande. En el centro hay un aeródromo abandonado con una pista larga y hangares, el oasis de Al-Rimal con casas y palmeras, y el lecho seco de un wadi que la cruza de oeste a este.
- **Rutas:** una autopista cruza todo el mapa de este a oeste y conecta las bases de Patriot y Jade con la zona. Sandstorm sube desde el sur por una carretera de tierra.
- **Sitios de FOB:** junto a la autopista para Patriot y Jade, y al sur del oasis para Sandstorm.
- **Cómo se juega:** mapa de tanques y de largo alcance. La infantería solo está a salvo en el oasis, en los hangares y dentro del wadi. El tanque lanzamisiles es muy fuerte porque casi nada tapa la vista.

### 3.8 Mapa 3: Nieve

&#91;image: Plano del mapa Nieve\]

- **Ambiente:** invierno en un bosque del norte, nublado y con nieve cayendo. La nieve frena un 20% a la infantería (Parte 3.4).
- **Relieve:** suave, con bosques de pinos muy espesos que tapan la vista, y un río helado que cruza el mapa.
- **Zona de guerra (2,5 km):** un lago helado en el centro, la aldea de Kholm al norte y un aserradero con naves grandes al este.
- **Mecánica especial (propuesta): el hielo.** La infantería y los vehículos ligeros y medios pueden cruzar el lago. Un tanque pesado rompe el hielo y se hunde, así que tiene que rodearlo.
- **Rutas:** las 3 carreteras atraviesan bosques, así que cualquier convoy puede ser emboscado. El río helado solo se cruza con vehículos por los puentes.
- **Sitios de FOB:** al borde de los bosques, frente al lago.
- **Cómo se juega:** emboscadas y combate a corta distancia en el bosque, donde el Ingeniero con MP5 y el C4 brillan. Cruzar el lago es rápido pero te deja al descubierto.

### 3.9 Mapa 4: Mixto

&#91;image: Plano del mapa Mixto\]

- **Ambiente:** campiña europea en verano, con campos de cultivo, bosques y un pueblo.
- **Relieve:** llano en el oeste y con colinas suaves en el este.
- **Zona de guerra (2,5 km):** el pueblo de San Martín en el centro, partido por un río con 3 puentes, y una iglesia en una colina, que es el mejor mirador.
- **Rutas:** Patriot llega por el puente norte, Sandstorm por el puente sur y Jade desde las colinas del este.
- **Sitios de FOB:** en los bordes del pueblo, cada uno frente a su puente o carretera.
- **Cómo se juega:** el mapa más equilibrado. En el pueblo pelea la infantería (los tanques no caben en las calles), en los campos abiertos pelean los tanques, y los puentes son los puntos que hay que controlar. Es el mejor mapa para aprender y para el tutorial.

**Números por probar.** Los planos son de diseño: muestran la distribución, no el aspecto final del mapa.

## Parte 4. Puntuación y victoria

- Cada unidad tiene un valor de **medida de guerra (MG)**. Dentro de la zona de guerra se suma la MG de todas las unidades de cada equipo; **las que están en la hot zone cuentan doble**.
- Cada cierto tiempo (propuesta: **6 segundos**), el equipo con **más MG** en la zona gana **1 punto**. Si otro equipo lo supera, deja de puntuar y empieza a puntuar el nuevo líder. En empate no puntúa nadie.
- **Gana el primero que llegue a 100 puntos.** La duración la decide la propia partida.
- Un vehículo sin tripulación no suma MG.

**Decidido como base:** 1 punto cada 6 s (Parte 13.6). La MG de cada unidad está en 6.2, 7.1 y 8.1.

## Parte 5. Economía

- Cada equipo empieza con **1.000.000 $**. En 2v2v2 **el dinero es compartido por equipo**.
- **Única fuente de ingresos: eliminar unidades enemigas.** Se cobra el **50% del coste** de lo destruido (75% si muere dentro de la hot zone).
- Robar un vehículo enemigo vacío es otra forma de ganar: te lo quedas gratis.
- **Unidades gratuitas**: si la caja del equipo baja de **20.000 $**, puede desplegar gratis un pelotón de 4 soldados de asalto cada 90 segundos.

**Decidido como base:** para que no se gaste todo de golpe, hay un límite de **100 unidades por equipo** (Parte 13.6). Se ajustará al probar.

## Parte 6. Infantería

Todos los soldados llevan arma. Cada clase tiene **2 mejoras**: se desbloquean al subir de rango con XP y después se pagan (Parte 9).

### 6.1 Reglas comunes

- **Caídos y reanimación**: un soldado que cae en combate queda **herido en el suelo durante 1 minuto**. En ese tiempo solo un **médico** puede reanimarlo; si nadie lo hace, muere. Con torniquete aguanta 90 s (Parte 19.3).
- **Arrastrar**: cualquier soldado puede arrastrar a un compañero caído hasta una cobertura para que el médico lo reanime sin recibir fuego.
- **Artillero**: cualquier soldado excepto el francotirador puede ocupar el puesto de artillero de un vehículo.
- Los datos de combate (daño, cadencia, alcance, vida) están en la Parte 13.

### 6.2 Clases

| Clase | Coste | MG | Arma y objetos de inicio | Papel | Mejora 1 | Mejora 2 |
| --- | --- | --- | --- | --- | --- | --- |
| Conductor / Piloto | 4.000 $ | 1 | Pistola | Una sola clase: maneja **cualquier vehículo, de tierra o aéreo** | Chaleco: más resistencia a las balas | Paracaídas: si derriban su helicóptero salta antes de tocar el suelo y se salva |
| Asalto | 5.000 $ | 2 | Fusil de asalto + 2 granadas | Combate general | Chaleco y casco | Arma mejorada con láser: más daño |
| Médico | 8.000 $ | 1 | Carabina + botiquín | Reanima a los caídos (tarda **mínimo 10 segundos** por soldado) | Adrenalina: los soldados cercanos se mueven más rápido durante 1 minuto | Desfibrilador: reanima a los caídos al instante |
| Ingeniero | 8.000 $ | 1 | Subfusil tipo MP5: dispara más rápido pero hace menos daño | Construye FOB, fortificaciones y morteros (ver Parte 10); repara | Construcción más rápida | C4: cargas explosivas contra vehículos y estructuras |
| Apoyo | 10.000 $ | 2 | Ametralladora pesada + granada de humo | Soldado pesado: más lento, pero con más vida y más daño | Lanzamisiles: derriba vehículos medianos (de tierra y aéreos) y daña tanques pesados | Dron: revela unidades enemigas o hace ataques bomba contra vehículos pequeños |
| Francotirador | 15.000 $ | 2 | Rifle de precisión | La unidad más débil pero la que más daño hace; dispara desde más lejos que nadie. Puede dañar vehículos pequeños pero no destruirlos | Rifle calibre .50: daña vehículos y dispara al **doble de distancia** | Traje ghillie: solo se le ve cuando dispara o corre; cuerpo a tierra y quieto no se le detecta |

### 6.3 Contra tanques pesados

A pie, solo pueden dañar un tanque pesado el **C4 del ingeniero** y el **lanzamisiles del apoyo**. Desde vehículos: sobre todo el cañón de otro tanque pesado, que es lo que más daño les hace; el cañón del tanque mediano les hace poco; y también los que llevan **misiles** (tanque lanzamisiles, helicóptero de combate y helicóptero pequeño con mejora).

**Decidido:** la XP necesaria y el precio de cada mejora están en la Parte 9.

## Parte 7. Vehículos de tierra

Todos los vehículos se compran **vacíos**: sin conductor no se mueven, y las armas de un puesto de **artillero** solo disparan si alguien va sentado ahí. **Se pueden robar** vehículos enemigos vacíos.

| Vehículo | Tripulación | Pasajeros | Armas | Papel |
| --- | --- | --- | --- | --- |
| Hummer de transporte | 1 conductor | 4 | Ninguna | Llevar tropas rápido |
| Hummer armado | 1 conductor + 1 artillero (ocupa plaza de pasajero) | 4 contando al artillero | Ametralladora en torreta | Transporte con apoyo de fuego |
| Camión de tropas | 1 conductor | 8 en la caja trasera | Ninguna | Llevar muchas tropas |
| Tanque mediano | 1 conductor + 1 artillero | — | Cañón de daño medio + ametralladora | Blindado versátil |
| Tanque pesado | 1 conductor + 1 artillero | 2 | Cañón de gran daño + ametralladora | Romper líneas y llevar tropas a la zona |
| Tanque antiaéreo | 1 conductor + 1 artillero | — | Cañones o misiles antiaéreos | Derribar helicópteros y drones |
| Tanque lanzamisiles | 1 (conductor y artillero a la vez) | — | Misiles | Ataque a distancia |

### 7.1 Datos de los vehículos de tierra *(propuesta para ajustar)*

La MG solo cuenta si el vehículo lleva conductor. Velocidad en m/s (10 m/s = 36 km/h).

| Vehículo | Coste | MG | Vida | Blindaje | Velocidad | Arma principal | Despliegue | Mejora 1 | Mejora 2 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Hummer de transporte | 30.000 $ | 3 | 300 | Ligero | 12 | — | 10 s | Blindaje (+30% vida) | Motor (+20% velocidad) |
| Hummer armado | 50.000 $ | 5 | 350 | Ligero | 11 | Ametralladora: 12 de daño (bala), muy rápida, 200 m | 12 s | Blindaje | Munición perforante (más daño contra vehículos) |
| Camión de tropas | 45.000 $ | 4 | 400 | Ligero | 9 | — | 12 s | Blindaje | Motor |
| Tanque mediano | 150.000 $ | 8 | 900 | Medio | 7,5 | Cañón: 100 de daño (proyectil), cada 3 s, 400 m + ametralladora | 20 s | Blindaje reactivo | Munición antitanque |
| Tanque pesado | 250.000 $ | 12 | 1.600 | Pesado | 5,5 | Cañón pesado: 180 de daño (proyectil), cada 4 s, 450 m + ametralladora | 30 s | Blindaje reactivo | Munición antitanque |
| Tanque antiaéreo | 140.000 $ | 7 | 700 | Medio | 7 | Cañones antiaéreos: 25 de daño, muy rápidos, 800 m; doble daño contra aeronaves | 20 s | Blindaje | Munición de proximidad (más daño a aeronaves) |
| Tanque lanzamisiles | 180.000 $ | 8 | 600 | Medio | 6,5 | Misiles: 150 de daño en área, cada 6 s, de 200 a 1.500 m | 25 s | Blindaje | Misiles de mayor alcance |

**Decidido:** la artillería (obús) se elimina; el **tanque lanzamisiles** cumple ese papel de ataque a distancia.

**Números por probar.** El daño contra cada blindaje y los alcances completos están en la Parte 13.4.

## Parte 8. Vehículos aéreos

| Helicóptero | Tripulación | Carga | Armas | Mejoras | Cómo se consigue |
| --- | --- | --- | --- | --- | --- |
| Transporte pequeño | 1 piloto | 4 soldados | Ninguna al principio | 2 mejoras de ataque: ametralladora y lanzamisiles aire-tierra | Desde el inicio |
| Transporte grande | 1 piloto | 12 soldados (13 personas con el piloto) **o** enganchar un vehículo pequeño o mediano (Hummer, camión o tanque mediano; nunca el pesado) | Ninguna | Solo 2 mejoras de defensa | Desde el inicio |
| Combate | 1 piloto + 1 artillero | — | Balas explosivas + misiles contra vehículos, tanques y otros helicópteros | — | Se desbloquea por bajas del equipo |

### 8.1 Datos de los helicópteros *(propuesta para ajustar)*

| Helicóptero | Coste | MG | Vida | Velocidad | Armas | Despliegue | Mejora 1 | Mejora 2 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Transporte pequeño | 80.000 $ | 4 | 450 | 20 | Ninguna | 15 s | Ametralladora: 10 de daño (bala), muy rápida, 200 m | Cohetes aire-tierra: 80 de daño (cohete), 400 m |
| Transporte grande | 150.000 $ | 6 | 900 | 15 | Ninguna | 25 s | Blindaje (+30% vida) | Bengalas: esquiva parte de los misiles |
| Combate | 300.000 $ | 14 | 1.000 | 17 | Balas explosivas: 20 de daño en área pequeña, muy rápidas, 300 m + misiles: 120 de daño contra vehículos y helicópteros, 600 m | 35 s | Blindaje | Munición mejorada |

- El helicóptero de combate se desbloquea cuando el equipo llega a **40 bajas** *(propuesta)*.
- Los helicópteros despegan siempre desde la base de salida.

**Números por probar.** El daño contra cada blindaje está en la Parte 13.4.

## Parte 9. Rangos y mejoras

Hay **dos marcadores distintos**:

- **Puntos de partida**: solo se ganan teniendo más medida de guerra en la zona (Parte 4). Deciden quién gana.
- **Puntos de experiencia (XP)**: se ganan con las acciones. Sirven para subir de rango y desbloquear las mejoras de cada clase.

### 9.1 Principio: cuanto más impacto, más XP *(propuesta)*

Cada unidad tiene un **valor** = su coste ÷ 1.000. Ejemplos: Asalto (5.000 $) vale 5; un vehículo de 200.000 $ vale 200. Derribar algo caro da mucha más XP que algo barato, igual que da más dinero.

### 9.2 XP por acciones de combate *(propuesta)*

| Acción | XP | Ejemplo |
| --- | --- | --- |
| Hacer daño | (daño hecho ÷ vida total del objetivo) × valor del objetivo | Quitar media vida a un Asalto: 0,5 × 5 = 2,5 XP |
| Rematar (baja o vehículo destruido) | + 50% del valor del objetivo | Matar un Asalto: 5 + 2,5 = 7,5 XP en total |
| Asistencia | Cada uno se lleva la XP del daño que hizo; el bonus de remate es para quien lo remata | — |
| Destruir una construcción | Valor de la construcción (coste ÷ 1.000) | FOB de 50.000 $: 50 XP |

### 9.3 XP por acciones de apoyo *(propuesta)*

Para que médicos, ingenieros y pilotos también suban de rango sin matar.

| Acción | XP |
| --- | --- |
| Reanimar a un caído (médico) | 3 × valor del soldado reanimado |
| Curar (médico) | 1 XP por cada 50 de vida curada |
| Arrastrar a un caído a cobertura | 2 XP |
| Reparar (ingeniero) | 1 XP por cada 100 de vida reparada |
| Construir un FOB / una fortificación | 20 XP / 3 XP |
| Llevar tropas a la zona de guerra (conductor o piloto) | 1 XP por cada soldado que baja dentro de la zona |
| Revelar enemigos con el dron (apoyo) | 25% de la XP que gane el equipo matando a esos enemigos |
| Robar un vehículo enemigo | 50% del valor del vehículo |

### 9.4 Multiplicadores *(propuesta)*

- Acción **dentro de la zona de guerra**: XP ×1,5.
- Acción **dentro de la hot zone**: XP ×2.
- Fuego amigo: 0 XP.

### 9.5 Rangos *(propuesta)*

| Rango | XP acumulada | Desbloquea |
| --- | --- | --- |
| Rango 1 (inicial) | 0 | Equipo básico |
| Rango 2 | 100 XP | Mejora 1 de la clase |
| Rango 3 | 300 XP | Mejora 2 de la clase |

El helicóptero de combate se desbloquea cuando **el equipo** llega a 40 bajas (Parte 8.1).

**Decisiones:**

1. **Decidido:** la XP es **por clase de soldado y por tipo de vehículo dentro del equipo** (por ejemplo, «Asaltos» o «Tanques medianos»). Todo lo que hagan las unidades de esa clase suma al mismo contador, y al subir de rango mejoran todas las unidades de esa clase del equipo, también las que se compren después. **La XP ganada no se pierde** aunque mueran las unidades.
2. **Decidido:** la XP y los rangos **duran solo la partida**; cada partida empieza desde cero.
3. **Decidido:** subir de rango **desbloquea** la mejora, pero hay que **pagarla** con el dinero del equipo. Propuesta de precios: infantería 50.000 $ (mejora 1) y 100.000 $ (mejora 2); vehículos 150.000 $ y 300.000 $.
4. *Pendiente:* números por probar.

## Parte 10. Construcción y despliegue

| Construcción | Quién la hace | Coste | Función |
| --- | --- | --- | --- |
| Base de salida | Viene con el mapa | — | Aquí aparecen todas las unidades; los helicópteros despegan siempre de aquí |
| FOB (base avanzada) | Ingeniero | 50.000 $ | Los soldados pueden aparecer aquí, más cerca del frente |
| Muro de hormigón | Ingeniero | 2.000 $ | Cobertura que bloquea disparos y paso |
| Valla de espino | Ingeniero | 500 $ | Frena y hiere a la infantería; se puede cruzar, pero cuesta |
| Mortero | Ingeniero | 15.000 $ | Puesto fijo que **puede ocupar cualquier soldado menos el francotirador,** para disparar a larga distancia; solo se construye junto a una FOB |

Los costes, tiempos de construcción y vida de cada construcción están en 10.1. Las fortificaciones de campo (trinchera, pozo de tirador, sacos, erizos y red de camuflaje) están en la Parte 19.5.

- Cada unidad tarda unos segundos en aparecer después de comprarla: los soldados 5 s y los vehículos y helicópteros lo que indica su tabla (7.1 y 8.1).

### 10.1 Datos de las construcciones *(propuesta para ajustar)*

| Construcción | Coste | Tiempo de construcción | Vida | Máximo por equipo | Detalles |
| --- | --- | --- | --- | --- | --- |
| FOB | 50.000 $ | 45 s | 2.000 | 3 | Aparecen soldados y vehículos de tierra; los helicópteros siempre en la base |
| Muro de hormigón | 2.000 $ | 8 s | 800 | 40 (sumando muros y vallas) | Bloquea disparos y paso; solo lo rompen explosivos, cañones y misiles |
| Valla de espino | 500 $ | 4 s | 200 | 40 (sumando muros y vallas) | La infantería puede cruzarla, pero va al 25% de su velocidad y pierde 10 de vida por segundo mientras está dentro. Los tanques la aplastan; los vehículos con ruedas no pueden pasar |
| Mortero | 15.000 $ | 20 s | 300 | 6 | Lo maneja 1 soldado (cualquiera menos el francotirador). Solo a menos de 100 m de una FOB propia, máximo 2 por FOB |

### 10.2 Reglas de construcción *(propuesta)*

- Solo el **ingeniero** construye, y tiene que estar al lado mientras dura la obra. Varios ingenieros juntos construyen más rápido; su mejora «construcción más rápida» reduce el tiempo a la mitad.
- El dinero se paga al empezar la obra.
- La FOB no se puede poner a menos de **1.000 m de una FOB enemiga**, ni a menos de **500 m de otra FOB propia**. La idea es que cada equipo monte las suyas en su esquina de la zona de guerra.
- **El enemigo puede destruir todo**: FOB, muros, vallas y morteros. Destruirlos da el 50% de su coste en dinero, igual que una baja, y XP (Parte 9).
- Si una FOB está siendo atacada (hay enemigos a menos de 50 m) no se puede desplegar en ella.
- La FOB se puede poner en cualquier parte del mapa, dentro o fuera de la zona de guerra.
- **Premio por arriesgarse (como en WARDOGS):** las unidades que aparecen en una FOB **dentro de la zona de guerra** ganan **el doble de XP** y **un 25% más de dinero por cada baja**, mientras sigan vivas. La pega: una FOB dentro de la zona tiene un 25% menos de vida (1.500 en vez de 2.000), así que se destruye antes. Una FOB fuera de la zona es más segura pero no da este premio.

### 10.3 Mortero *(propuesta)*

- Alcance: de **100 m hasta el radio de la zona de guerra** de ese mapa (entre **1.000 y 1.500 m**, porque la zona mide de 2 a 3 km de ancho). Así, un mortero en una FOB del borde de la zona llega hasta el centro. Daño: **90 en un área de 6 m**, un disparo cada **5 s**.
- Cuanto más lejos dispara, menos precisión: el proyectil cae a unos 5 m del objetivo a corta distancia y hasta a 25 m al alcance máximo, y tarda más en llegar (hasta unos 10 s). Así no sustituye al tanque de misiles, sirve para castigar zonas.
- Solo se construye a **menos de 100 m de una FOB propia**, con un máximo de **2 morteros por FOB** (6 en total). Si la FOB cae, sus morteros siguen en pie hasta que los destruyan.
- Munición: **20 disparos**. Se recarga cerca de una FOB o con un soldado de Apoyo al lado.
- Necesita que alguien vea el objetivo: un aliado o el dron del Apoyo.

**Números por probar.**

## Parte 11. Multijugador

- Partidas por **LAN** y **online** (a través de Steam, sin abrir puertos).
- Un jugador hace de anfitrión; los huecos vacíos los ocupa la IA.
- En 2v2v2 los dos jugadores de un equipo comparten dinero, puntos, visión y edificios; cada uno manda las unidades que compra.

### 11.1 Desconexiones

**En 2v2v2** (decidido):

- Si un jugador se desconecta, **la partida se pausa para todos**.
- A su compañero de equipo le salen 2 opciones:
  1. **La IA toma el control** de las unidades del desconectado hasta que vuelva o hasta que acabe la partida.
  2. **Él controla todas las unidades** del equipo.
- La partida sigue en cuanto elige. *Propuesta:* si no elige en 30 s, se aplica la opción 1.
- Si el jugador vuelve, recupera sus unidades.

**En 1v1v1** (decidido): la IA toma el mando siempre, sin pausa, y se avisa a todos los jugadores con un mensaje en pantalla. Si el jugador vuelve, recupera el control.

### 11.2 Estadísticas de cada jugador

- De momento **solo partidas normales**, sin clasificatorias.
- Cada jugador tiene un **perfil con sus victorias y partidas jugadas, separadas por modo** (1v1v1 y 2v2v2).
- **Las partidas contra la IA no cuentan** para las estadísticas.
- *Propuesta:* si la IA solo entra por una desconexión, la partida sí cuenta. Abandonar una partida cuenta como derrota.

### 11.3 Sala de espera *(propuesta)*

- El anfitrión crea la sala y elige el **mapa** y el **modo** (1v1v1 o 2v2v2).
- Cada equipo elige una facción distinta: Patriot, Jade o Sandstorm.
- Los huecos vacíos se pueden llenar con **IA** (fácil, normal o difícil).
- Hay chat en la sala y la partida empieza cuando todos marcan «Listo».

## Parte 12. Arte, sonido e interfaz

- Cámara isométrica como Defilade; modelos militares realistas como WARDOGS (sin copiar sus modelos).
- Soldados animados de Mixamo; vehículos y edificios generados con IA (Meshy o Tripo) con una misma guía de estilo.
- Cada unidad necesita 3 versiones, una por facción.

### 12.1 Estilo visual *(propuesta)*

- **Realista pero fácil de leer**: colores apagados en el terreno (verdes, grises, arena) para que las unidades y los efectos destaquen.
- **Color de cada equipo** en marcas, iconos y minimapa: **Patriot azul**, **Jade rojo** y **Sandstorm verde**, como en WARDOGS.

| Facción | Uniforme y camuflaje | Estilo de vehículos |
| --- | --- | --- |
| Patriot | Camuflaje multiterreno, casco moderno | Tipo estadounidense: Humvee, Abrams, Black Hawk |
| Jade | Camuflaje digital verde y gris | Tipo chino: blindados angulosos, helicópteros tipo Z |
| Sandstorm | Camuflaje desértico, pañuelos | Mezcla de material soviético y pick-ups modificadas |

Solo cambia el aspecto: los datos son iguales (Parte 2). Ningún modelo se copia de otro juego.

### 12.2 Cámara *(propuesta)*

- Isométrica como Defilade, con **zoom** desde ver a un soldado de cerca hasta ver unos 800 m de terreno.
- Se puede **girar** la cámara (con el botón central del ratón, Parte 15) y moverla con WASD, con el ratón en el borde o arrastrando.
- Al alejar el zoom, cada unidad se ve como un **icono de su clase** con el color del equipo, para no perderla en un mapa tan grande.

### 12.3 Interfaz en partida *(propuesta)*

- **Barra superior:** dinero del equipo, puntos de los 3 equipos con su barra, líder actual y tiempo hasta el siguiente cambio de la hot zone.
- **Panel de compra** abajo, con pestañas: Infantería, Vehículos, Helicópteros y Construcción. Cada botón muestra precio y MG, y una ficha con los datos al pasar el ratón.
- **Minimapa** abajo a la derecha, con la zona de guerra, la hot zone, el aviso de la siguiente y las FOB.
- **Ficha de la unidad seleccionada:** vida, rango, XP de su clase y botón de comprar mejora cuando esté desbloqueada.
- Barras de vida sobre las unidades, y un **registro de bajas** en una esquina, con los nombres de los soldados (19.6). Para construir se usa el menú circular de 19.6.
- Avisos en pantalla: FOB atacada, hot zone moviéndose, helicóptero de combate desbloqueado y jugador desconectado.

### 12.4 Sonido *(propuesta)*

- Cada arma tiene su sonido, y suena distinto de cerca que de lejos.
- **Voces por radio** cortas al dar órdenes y en avisos («Moviendo», «FOB bajo ataque»), en español y en inglés.
- **Música** en los menús; en partida, solo cuando cambia la hot zone o al final.
- Los sonidos salen de bibliotecas gratuitas con licencia para juegos.

### 12.5 Menús *(propuesta)*

- **Menú principal:** Jugar online, Jugar en LAN, Partida contra la IA, Perfil (estadísticas, Parte 11.2) y Opciones.
- **Opciones:** gráficos, sonido, controles y idioma (español e inglés).

### 12.6 Guía de diseño de las unidades *(propuesta)*

Las imágenes de 12.7 a 12.9 son **bocetos de diseño**: sirven para fijar la silueta, el equipo y el camuflaje de cada facción antes de hacer los modelos 3D. No son los modelos finales.

- **Misma silueta por clase:** un tanque pesado se tiene que reconocer como tanque pesado sea de la facción que sea. Entre facciones cambian la torreta, las armas, el casco y el camuflaje, pero no el tamaño ni la forma general.
- **Rasgos grandes que se lean desde lejos:** con la cámara isométrica las unidades se ven pequeñas. Cada clase tiene algo inconfundible: el tubo lanzamisiles del Apoyo, la capa ghillie del francotirador, el radar del antiaéreo, el lanzador inclinado del tanque lanzamisiles.
- **Color de equipo:** cada unidad lleva un panel o brazalete con el color de su equipo (Patriot azul, Jade rojo, Sandstorm verde). Además, al seleccionarla se ve un contorno de ese color y, con el zoom lejos, su icono (Parte 12.2).
- **Camuflaje de cada facción:** Patriot usa multiterreno en los soldados y verde OTAN en los vehículos. Jade usa digital verde y gris en todo. Sandstorm usa camuflaje desértico con franjas marrones.
- **Símbolo del médico:** cruz blanca sobre fondo verde. **Nunca la cruz roja**, que es un emblema protegido y no se puede usar en juegos.
- **Nada real con nombre:** «tipo Abrams» o «tipo AK» es solo una referencia de estilo. Los modelos finales son originales y no llevan nombres ni logotipos de fabricantes reales.

| Unidad | Tamaño real aproximado | Polígonos orientativos del modelo 3D |
| --- | --- | --- |
| Soldado | 1,8 m de alto | 5.000 a 8.000 |
| Hummer y pick-up | 5 m de largo | 12.000 a 18.000 |
| Camión | 8 m de largo | 15.000 a 20.000 |
| Tanques | 7 a 10 m de largo | 20.000 a 30.000 |
| Helicópteros | 12 a 30 m de largo | 20.000 a 30.000 |

Cada modelo lleva además 2 versiones más simples para cuando la cámara está lejos.

### 12.7 Infantería

&#91;image: Conductor / Piloto en las 3 facciones\]

**Conductor / Piloto:** el único sin chaleco. Lleva casco de tripulación con micrófono y mono de trabajo, y solo pistola. Se distingue de lejos porque es el soldado más «vacío».

&#91;image: Asalto en las 3 facciones\]

**Asalto:** chaleco con cargadores y 2 granadas. Es donde más se nota la facción por el fusil: tipo M4 en Patriot, bullpup tipo QBZ en Jade y tipo AK con madera en Sandstorm, que además lleva pañuelo shemagh.

&#91;image: Médico en las 3 facciones\]

**Médico:** mochila con la cruz blanca sobre verde, bien visible desde arriba, y carabina corta.

&#91;image: Ingeniero en las 3 facciones\]

**Ingeniero:** mochila con pala, protectores auditivos, cargas C4 en el chaleco y subfusil tipo MP5, el mismo en las 3 facciones.

&#91;image: Apoyo en las 3 facciones\]

**Apoyo:** el más voluminoso. Lleva una ametralladora con bípode, una mochila grande y el tubo lanzamisiles cruzado a la espalda; al comprar la mejora 1, el tubo pasa a sus manos al disparar.

&#91;image: Francotirador en las 3 facciones\]

**Francotirador:** gorro de ala ancha, rifle largo con mira y capa ghillie sobre los hombros. Con la mejora del traje ghillie, la capa le cubre entero.

### 12.8 Vehículos de tierra

&#91;image: Hummer de transporte\]

**Hummer de transporte:** 4 ruedas y cabina cerrada en Patriot y Jade. Sandstorm usa una pick-up con barra antivuelco, pero con el mismo tamaño y la misma silueta baja.

&#91;image: Hummer armado\]

**Hummer armado:** igual que el de transporte, con torreta y el artillero asomado (Parte 14.10), que debe verse claramente para que se entienda que se le puede disparar.

&#91;image: Camión de tropas\]

**Camión de tropas:** cabina delante, caja con lona y 3 ejes. Lo que cambia entre facciones es la forma del morro.

&#91;image: Tanque mediano\]

**Tanque mediano:** orugas, casco bajo y cañón medio. La forma de la torreta identifica a la facción: plana y angulosa (Patriot), en cuña (Jade) y redonda (Sandstorm).

&#91;image: Tanque pesado\]

**Tanque pesado:** las mismas formas de torreta que el mediano, pero más grande, con faldones laterales y un cañón mucho más largo. Tiene que verse claramente más grande que el mediano.

&#91;image: Tanque antiaéreo\]

**Tanque antiaéreo:** torreta alta con los cañones apuntando al cielo y el radar encima. Es lo primero que un piloto tiene que reconocer.

&#91;image: Tanque lanzamisiles\]

**Tanque lanzamisiles:** cabina delante y lanzador inclinado detrás. Patriot y Jade llevan un contenedor cerrado; Sandstorm, los tubos a la vista. Al desplegarse para disparar, el lanzador se levanta (Parte 14.15).

### 12.9 Helicópteros

&#91;image: Helicóptero de transporte pequeño\]

**Transporte pequeño:** cabina redonda y cola fina. Con las mejoras se le añaden la ametralladora y los cohetes a los lados.

&#91;image: Helicóptero de transporte grande\]

**Transporte grande:** el más grande del juego. Patriot usa doble rotor; Jade y Sandstorm, un rotor grande. Tiene un gancho bajo el fuselaje para colgar vehículos.

&#91;image: Helicóptero de combate\]

**Combate:** fuselaje estrecho con cabina en tándem, alas cortas con misiles y cañón bajo el morro.

**Pendiente:** que un artista convierta estos bocetos en modelos 3D (Parte 12: Meshy o Tripo y Mixamo).

## Parte 13. Sistema de combate y parámetros

Aquí se junta todo lo que decide quién gana un tiroteo: vida, daño, tipos de blindaje, alcances, visión y los números generales de la partida. Todo es **propuesta para ajustar** cuando probemos el juego.

### 13.1 Tipos de blindaje

Cada unidad tiene uno de estos 4 blindajes. Sustituye a la columna «Blindaje» de la tabla 7.1.

| Blindaje | Unidades |
| --- | --- |
| Infantería | Todos los soldados |
| Ligero | Hummer de transporte, Hummer armado, camión de tropas, helicóptero de transporte pequeño |
| Medio | Tanque mediano, tanque antiaéreo, tanque lanzamisiles, helicóptero de transporte grande, helicóptero de combate |
| Pesado | Tanque pesado |

Las construcciones (FOB, muros, mortero) cuentan como blindaje Medio, salvo el muro de hormigón, que solo lo rompen explosivos, cañones y misiles.

### 13.2 Reglas generales de daño

- Un 0 en las tablas significa que esa arma **no le hace nada** a ese blindaje.
- «En 5 m» significa que hace daño en área: a todo lo que esté en ese radio.
- Un soldado detrás de cobertura (muro, roca, edificio) recibe **la mitad de daño de las balas**.
- **Fuego amigo:** las balas no dañan a aliados; los explosivos, misiles y cañones sí.
- Si un vehículo es destruido, los que van dentro **caen heridos** y pueden ser reanimados (Parte 6.1). El piloto con paracaídas se salva.

### 13.3 Soldados

| Clase | Vida | Velocidad |
| --- | --- | --- |
| Conductor / Piloto | 80 | 4,5 m/s |
| Asalto | 100 | 4 m/s |
| Médico | 100 | 4 m/s |
| Ingeniero | 100 | 4 m/s |
| Apoyo | 150 | 3 m/s |
| Francotirador | 70 | 4 m/s |

Daño por disparo de cada soldado según el objetivo (helicópteros: ligero / medio):

| Soldado | Arma | Infantería | Veh. ligeros | Veh. medios | Veh. pesados | Helicópteros | Cadencia | Alcance |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Conductor / Piloto | Pistola | 15 | 0 | 0 | 0 | 0 | 2 por s | 50 m |
| Asalto | Fusil de asalto | 20 | 0 | 0 | 0 | 0 | 4 por s | 150 m |
| Médico | Carabina | 15 | 0 | 0 | 0 | 0 | 3 por s | 100 m |
| Ingeniero | Subfusil MP5 | 10 (5 a más de 40 m) | 0 | 0 | 0 | 0 | 12 por s | 80 m |
| Ingeniero | C4 (mejora 2) | 1.000 en 5 m | 1.000 | 800 | 600 | Solo si está en el suelo | 2 cargas | Se pega a mano |
| Apoyo | Ametralladora | 15 (acierta el 60%) | 4 | 0 | 0 | 4 / 0 | 8 por s | 200 m |
| Apoyo | Lanzamisiles (mejora 1) | 150 en 3 m | 360 | 300 | 180 | 360 / 300 | 1 cada 6 s | 250 m |
| Apoyo | Dron bomba (mejora 2) | 200 en 4 m | 200 | 0 | 0 | 0 | 1 uso | 600 m |
| Francotirador | Rifle de precisión | 150 | 15 (no lo destruye) | 0 | 0 | 0 | 1 cada 2,5 s | 500 m |
| Francotirador | Rifle .50 (mejora 1) | 250 | 62 | 25 | 0 | 62 / 25 | 1 cada 3 s | 1.000 m |

Cómo encaja con lo que pediste:

- **Ingeniero (MP5):** mata a un Asalto en 0,75 s, el más rápido de cerca, pero cada bala hace poco y a más de 40 m la mitad. De lejos pierde contra el Asalto (que lo mata en 1 s).
- **Francotirador:** mata a cualquier soldado de **un tiro**, pero dispara una vez cada 2,5 s. En ese tiempo un Asalto mata a 2.
- **Rifle .50:** llega a **1.000 m** si no hay nada en medio (rocas, edificios, muros o el terreno). Daña poco a los vehículos ligeros (un Hummer necesita 5 tiros) y medios, y **nada a los pesados**.
- Granada de humo del Apoyo: no hace daño, corta la visión 15 s en 10 m.

### 13.4 Vehículos, helicópteros y mortero

La vida de cada vehículo está en 7.1 y 8.1. Los alcances de esta tabla sustituyen a los de 7.1 y 8.1, que eran del prototipo de 800 m.

| Unidad | Arma | Infantería | Veh. ligeros | Veh. medios | Veh. pesados | Helicópteros | Cadencia | Alcance |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Hummer armado | Ametralladora | 12 | 3 | 0 | 0 | 3 / 0 | 10 por s | 200 m |
| Tanque mediano | Cañón | 60 en 5 m | 100 | 100 | 40 | No apunta al aire | 1 cada 3 s | 400 m |
| Tanque mediano | Ametralladora | 12 | 3 | 0 | 0 | 3 / 0 | 10 por s | 200 m |
| Tanque pesado | Cañón pesado | 110 en 6 m | 180 | 180 | 180 | No apunta al aire | 1 cada 4 s | 450 m |
| Tanque pesado | Ametralladora | 12 | 3 | 0 | 0 | 3 / 0 | 10 por s | 200 m |
| Tanque antiaéreo | Cañones antiaéreos | 12 | 12 | 7 | 0 | 25 / 15 (drones 50) | 6 por s | 800 m |
| Tanque lanzamisiles | Misiles | 75 en 8 m | 180 | 150 | 120 | No apunta al aire | 1 cada 6 s | De 200 a 1.500 m |
| Helicóptero pequeño | Ametralladora (mejora 1) | 10 | 2 | 0 | 0 | 2 / 0 | 10 por s | 200 m |
| Helicóptero pequeño | Cohetes (mejora 2) | 40 en 4 m | 96 | 80 | 64 | 0 | 1 cada 4 s | 400 m |
| Helicóptero de combate | Balas explosivas | 20 en 2 m | 20 | 16 | 0 | 20 / 16 | 6 por s | 300 m |
| Helicóptero de combate | Misiles | 60 | 144 | 120 | 96 | 144 / 120 | 1 cada 5 s | 600 m |
| Mortero | Granadas | 90 en 6 m | 90 | 72 | 54 | 0 | 1 cada 5 s | De 100 m al radio de la zona |

**Contra un tanque pesado (1.600 de vida)**, lo que más daño le hace es **otro tanque pesado**: lo destruye en 9 disparos (unos 32 s). Después: el lanzamisiles del Apoyo en 9 disparos (48 s), el tanque lanzamisiles en 14 (78 s), el helicóptero de combate en 17 misiles y el tanque mediano en 40 disparos. Con C4 bastan 3 cargas, pero hay que llegar hasta él.

### 13.5 Visión

Solo se ve lo que alguna unidad del equipo está viendo. Las rocas, edificios, bosques y colinas tapan la vista.

| Unidad | Ve hasta |
| --- | --- |
| Soldados | 250 m |
| Francotirador | 400 m (mira telescópica) |
| Vehículos de tierra | 300 m |
| Helicópteros | 500 m |
| Dron del Apoyo | 250 m alrededor del dron (vuela hasta 600 m del Apoyo) |
| FOB y base | 300 m |

Para disparar más lejos de lo que ve la propia unidad (francotirador con .50, tanque lanzamisiles, mortero) alguien del equipo tiene que estar viendo el objetivo.

### 13.6 Parámetros generales de la partida

| Parámetro | Valor |
| --- | --- |
| Dinero inicial | 1.000.000 $ por equipo |
| Límite de unidades | 100 por equipo (propuesta; en el prototipo eran 70 y se llegaba enseguida) |
| Dinero por baja | 50% del coste (75% en la hot zone) |
| Pelotón gratis | 4 Asaltos cada 90 s si el equipo tiene menos de 20.000 $ |
| Puntos para ganar | 100 |
| Intervalo de puntuación | 1 punto cada 6 s al equipo con más MG |
| Tiempo en el suelo herido | 60 s (90 s con torniquete, 19.3) |
| Tiempo de reanimación | 10 s (al instante con desfibrilador) |
| FOB máximas | 3 por equipo |
| Cambio de la hot zone | Cada 5 minutos, con 60 s de aviso (Parte 3.2) |
| Despliegue de soldados | 5 s desde la compra |
| Helicóptero de combate | Se desbloquea con 40 bajas del equipo |

**Pendiente:** probar estos números en el juego y ajustar.

## Parte 14. Mecánicas de cada unidad

Una ficha por unidad con cómo se comporta, qué órdenes especiales tiene y contra qué es fuerte o débil. Los números de vida y daño están en la Parte 13. Todo es **propuesta para revisar**.

### 14.1 Mecánicas comunes de la infantería

- **Posturas:** de pie (velocidad normal), agachado (va a la mitad de velocidad y acierta un 25% más) y cuerpo a tierra (casi no se mueve, recibe la mitad de daño de explosivos y el enemigo solo lo ve a la mitad de distancia). Los soldados se agachan solos al recibir fuego; el jugador puede ordenar la postura.
- **Supresión:** un soldado que recibe mucho fuego (sobre todo de ametralladora) queda **suprimido**: acierta la mitad y se mueve más lento durante 3 s. Así el Apoyo inmoviliza al enemigo aunque no lo mate.
- **Edificios:** hasta 6 soldados pueden meterse en una casa. Dentro reciben la mitad de daño de las balas, pero un tanque o un misil puede derrumbarla.
- **Munición:** las armas normales tienen munición infinita. Los objetos especiales (granadas, misiles, C4, dron) se gastan y se reponen en una FOB o junto a un Apoyo.
- **Subir a vehículos:** cualquier soldado puede ir de pasajero; para conducir hace falta un Conductor / Piloto, y cualquiera menos el francotirador puede ser artillero.
- **Grupos:** se compran de uno en uno; el jugador los agrupa con Ctrl + número.

### 14.2 Conductor / Piloto

- **Papel:** el único que puede conducir vehículos y pilotar helicópteros. Sin él, un vehículo no se mueve ni suma MG.
- **En combate:** solo lleva pistola. Lo lógico es que vaya siempre dentro de un vehículo.
- **Órdenes especiales:** subir a un vehículo o helicóptero (también a uno enemigo vacío, para robarlo) y bajar.
- **Mejora 1, chaleco:** recibe un 30% menos de daño de las balas.
- **Mejora 2, paracaídas:** si derriban su helicóptero, salta y llega al suelo vivo.
- **XP:** sobre todo llevando tropas a la zona de guerra (Parte 9.3) y con las bajas que haga el vehículo que conduce.
- **Fuerte contra:** nada a pie. **Débil contra:** todo.

### 14.3 Asalto

- **Papel:** el soldado básico y barato. Es el que más se compra y el que llena la zona de guerra de MG.
- **Objeto:** 2 granadas de fragmentación (100 de daño en 5 m, se lanzan a 30 m). Útiles para sacar enemigos de edificios.
- **Mejora 1, chaleco y casco:** recibe un 25% menos de daño de las balas.
- **Mejora 2, arma con láser:** +25% de daño y de precisión.
- **Fuerte contra:** infantería a media distancia (gana al Ingeniero de lejos y al Médico). **Débil contra:** vehículos, francotirador, Apoyo y explosivos.

### 14.4 Médico

- **Papel:** mantiene vivo al equipo. Cada soldado reanimado es dinero que no se pierde.
- **Reanimar:** solo él reanima a los caídos (Parte 6.1). Tarda 10 s y tiene que estar al lado; si recibe daño, empieza de nuevo. El soldado vuelve con un 30% de vida.
- **Curar:** cura 10 de vida por segundo a un aliado herido que tenga al lado.
- **Mejora 1, adrenalina:** se activa con un botón. Los aliados en 20 m van un 30% más rápido durante 1 minuto. Se recarga en 2 minutos.
- **Mejora 2, desfibrilador:** reanima al instante, con 20 s de espera entre usos.
- **Fuerte contra:** nada en combate directo. **Débil contra:** todo; hay que protegerlo.

### 14.5 Ingeniero

- **Papel:** construye FOB, muros, vallas y morteros (Parte 10), y repara.
- **Arma:** MP5, el que mata más rápido de cerca (Parte 13.3). Ideal para defender la FOB y luchar en edificios.
- **Reparar:** repara 25 de vida por segundo a vehículos y construcciones aliadas, tocando. Varios ingenieros juntos suman. También puede reparar un vehículo vacío.
- **Mejora 1, construcción rápida:** construye y repara al doble de velocidad.
- **Mejora 2, C4:** lleva 2 cargas. Las pega a mano a un vehículo o construcción (no a un helicóptero en el aire) y explotan a los 5 s, o cuando él las detone. Las repone en una FOB.
- **Fuerte contra:** infantería de cerca y, con C4, tanques pesados. **Débil contra:** infantería de lejos, francotirador y vehículos antes de tener C4.

### 14.6 Apoyo

- **Papel:** soldado pesado. Inmoviliza al enemigo con la ametralladora y es la defensa a pie contra vehículos.
- **Ametralladora:** acierta el 60% si está quieto y solo el 30% si dispara moviéndose. Suprime mucho (Parte 14.1).
- **Humo:** lleva 2 granadas. Corta la visión 15 s en un área de 10 m, para cruzar zonas abiertas o rescatar caídos.
- **Reabastecer:** los aliados en 15 m recuperan granadas y misiles, y los morteros cercanos recuperan munición.
- **Mejora 1, lanzamisiles:** lleva 4 misiles. Tarda 2 s en fijar el blanco y el misil lo sigue. Sirve contra vehículos y helicópteros.
- **Mejora 2, dron:** lo lanza y lo controla el jugador. Vuela hasta 600 m del Apoyo durante 90 s, revela a los enemigos que ve y se puede derribar (50 de vida). Puede estrellarse como bomba contra vehículos ligeros. Se recarga en 2 minutos.
- **Fuerte contra:** grupos de infantería y, con mejoras, vehículos y helicópteros. **Débil contra:** francotirador, tanques de cerca y explosivos; es lento.

### 14.7 Francotirador

- **Papel:** elimina soldados clave (médicos, apoyos, artilleros) desde muy lejos. También sirve de vigía porque ve más lejos que nadie (400 m).
- **Disparo:** solo dispara quieto. Tras moverse tarda 1 s en apuntar. Mata a cualquier soldado de un tiro (Parte 13.3).
- **No puede ser artillero** de un vehículo.
- **Mejora 1, rifle .50:** dispara hasta 1.000 m si nada tapa el tiro, y daña a vehículos ligeros y medios.
- **Mejora 2, traje ghillie:** si está quieto o cuerpo a tierra no se le ve. Al disparar o correr se le ve durante 3 s.
- **Fuerte contra:** infantería a larga distancia. **Débil contra:** vehículos, el dron (que lo revela), morteros y cualquiera que llegue cerca.

### 14.8 Mecánicas comunes de los vehículos de tierra

- **Tripulación:** sin conductor no se mueve ni suma MG; sin artillero no dispara (salvo el tanque lanzamisiles, que lleva uno solo).
- **Vehículo dañado:** por debajo del 25% de vida echa humo y va a la mitad de velocidad hasta que un Ingeniero lo repare.
- **Blindaje trasero:** los tanques (mediano, pesado, antiaéreo y lanzamisiles) reciben un **50% más de daño por detrás**. Flanquear es clave.
- **Atropellar:** los tanques aplastan a la infantería que no se aparta. Los Hummer y el camión le hacen 50 de daño.
- **Romper obstáculos:** los tanques aplastan vallas de espino; los cañones y misiles rompen muros y casas.
- **Robar:** un vehículo enemigo vacío pasa a ser tuyo en cuanto tu conductor se sube.
- **Ruido:** un tanque en marcha aparece en el minimapa del enemigo como una marca aproximada a 500 m, aunque no lo vean.

### 14.9 Hummer de transporte

- **Papel:** llevar a 4 soldados rápido a la zona de guerra o a una FOB. El más rápido de los vehículos de tierra.
- **Mejoras:** blindaje (+30% vida) y motor (+20% velocidad).
- **Fuerte contra:** nada; es transporte. **Débil contra:** cualquier arma antivehículo y el rifle .50.

### 14.10 Hummer armado

- **Papel:** transporte con fuego de apoyo contra infantería.
- **Artillero expuesto:** el artillero va asomado en la torreta. Un francotirador puede matarlo sin destruir el Hummer, y entonces deja de disparar hasta que otro ocupe su sitio.
- **Mejoras:** blindaje y munición perforante (+50% de daño a vehículos ligeros).
- **Fuerte contra:** infantería en campo abierto. **Débil contra:** tanques, lanzamisiles y francotirador.

### 14.11 Camión de tropas

- **Papel:** llevar a 8 soldados de una vez. También hace de **suministro móvil**: los aliados en 15 m reponen granadas, misiles y munición de mortero, como junto a un Apoyo.
- **Mejoras:** blindaje y motor.
- **Fuerte contra:** nada. **Débil contra:** todo; si cae lleno, caen heridos 8 soldados.

### 14.12 Tanque mediano

- **Papel:** el blindado versátil. Gana a vehículos ligeros y apoya a la infantería con el cañón y la ametralladora.
- **Torreta:** gira sola hacia el objetivo mientras el tanque se mueve.
- **Mejoras:** blindaje reactivo (los 2 primeros misiles que reciba hacen la mitad de daño; se repone en una FOB) y munición antitanque (+25% de daño a vehículos).
- **Fuerte contra:** vehículos ligeros e infantería. **Débil contra:** tanque pesado, lanzamisiles, C4 y helicóptero de combate.

### 14.13 Tanque pesado

- **Papel:** romper líneas. Es lo que más daño hace a otro tanque pesado y lleva 2 pasajeros para meter tropas en la zona.
- **Lento:** el más lento de todos; necesita apoyo de infantería contra los Ingenieros con C4.
- **Mejoras:** blindaje reactivo y munición antitanque, como el mediano.
- **Fuerte contra:** todo lo de tierra. **Débil contra:** C4, lanzamisiles en grupo, ataques por detrás y helicóptero de combate.

### 14.14 Tanque antiaéreo

- **Papel:** controlar el cielo.
- **Radar:** detecta helicópteros y drones a 1.000 m y los muestra en el minimapa a todo el equipo.
- **Aviso:** el piloto enemigo recibe un aviso cuando el radar le apunta.
- **Mejoras:** blindaje y munición de proximidad (+25% de daño a aeronaves).
- **Fuerte contra:** helicópteros, drones e infantería. **Débil contra:** tanques y C4.

### 14.15 Tanque lanzamisiles

- **Papel:** ataque a distancia, sustituto de la artillería. Un solo soldado hace de conductor y artillero.
- **Disparo:** tiene que parar 2 s para desplegarse antes de disparar. No puede disparar a menos de 200 m. Necesita que un aliado vea el objetivo.
- **Mejoras:** blindaje y misiles de mayor alcance (+30%).
- **Fuerte contra:** grupos de infantería, FOB, morteros y tanques quietos. **Débil contra:** cualquier cosa que llegue cerca, y los helicópteros.

### 14.16 Mecánicas comunes de los helicópteros

- **Despegan siempre de la base** y vuelven a ella para repararse y recargar munición.
- **Vuelo:** pasan por encima de todo; ven hasta 500 m.
- **Bajar tropas:** el pequeño tiene que aterrizar (3 s). El grande puede descolgarlas con cuerdas sin aterrizar (5 s).
- **Derribado:** cae y explota; los que van dentro caen heridos, salvo el piloto con paracaídas.

### 14.17 Helicóptero de transporte pequeño

- **Papel:** llevar a 4 soldados rápido a cualquier punto, sin carreteras.
- **Mejoras de ataque:** ametralladora (mejora 1) y cohetes aire-tierra (mejora 2). Con ellas se convierte en un helicóptero de ataque ligero.
- **Fuerte contra:** con mejoras, infantería y vehículos ligeros. **Débil contra:** tanque antiaéreo, lanzamisiles y rifle .50.

### 14.18 Helicóptero de transporte grande

- **Papel:** llevar a 12 soldados o colgar un vehículo ligero o el tanque mediano (nunca el pesado).
- **Con un vehículo colgado** va un 30% más lento. Lo suelta tocando suelo en 3 s, y el vehículo llega vacío.
- **Mejoras de defensa:** blindaje (+30% vida) y bengalas (3 usos; cada una desvía los misiles que vengan en ese momento).
- **Fuerte contra:** nada; es transporte. **Débil contra:** todo lo antiaéreo.

### 14.19 Helicóptero de combate

- **Papel:** la unidad más fuerte del juego. Se desbloquea cuando el equipo llega a 40 bajas.
- **Tripulación:** piloto y artillero. El piloto lo mueve y el artillero usa las balas explosivas y los misiles.
- **Mejoras:** blindaje y munición mejorada.
- **Fuerte contra:** vehículos, tanques, infantería y otros helicópteros. **Débil contra:** tanque antiaéreo y lanzamisiles del Apoyo.

### 14.20 Modos de comportamiento

Cada unidad tiene un **modo** que decide qué hace sola cuando el jugador no le da órdenes. Se elige con botones en la ficha de la unidad o con una tecla, y se aplica a todas las seleccionadas. Las órdenes del jugador (mover, atacar) siempre se cumplen; al terminarlas, la unidad vuelve a actuar según su modo.

| Modo | Qué hace | Para qué sirve |
| --- | --- | --- |
| **Cobertura** (decidido) | Busca algo con lo que cubrirse cerca de donde está (muro, roca, casa) y se queda ahí. Solo dispara a los enemigos que ve; no los persigue. | Aguantar una posición perdiendo pocos soldados |
| **Vigila** (decidido) | No busca cobertura. Solo ataca a los enemigos que están dentro de la hot zone, y se mueve lo justo para dispararles. | Defender la hot zone y sumar MG sin dispersarse |
| **Prioridad** (decidido) | Se mueve sola buscando enemigos y los ataca. | Limpiar una zona sin dar órdenes una a una |
| **Alto el fuego** *(propuesta)* | No dispara hasta que el jugador lo ordene o le disparen. | Emboscadas y francotirador con traje ghillie |

Detalles *(propuesta)*:

- Al comprar una unidad empieza en modo **Cobertura**.
- En **Vigila**, si a la unidad le disparan desde fuera de la hot zone, responde al fuego; si no, ignora a quien esté fuera.
- En **Prioridad**, la unidad no se aleja más de 300 m del sitio donde se le dio la orden, para no acabar sola en la otra punta del mapa.
- Los vehículos también tienen los 4 modos. En Cobertura se quedan quietos detrás de un obstáculo en vez de buscar cobertura.

### 14.21 Prioridades especiales de cada clase

Además del modo, algunas unidades tienen un botón de **prioridad especial** que cambia lo que hacen primero.

| Unidad | Prioridad especial | Qué hace |
| --- | --- | --- |
| Médico | **Solo curar** (decidido) | No busca pelea: va a reanimar caídos y curar heridos en 50 m, y solo dispara si le atacan. Primero los caídos, después los heridos. |
| Ingeniero | **Solo reparar** (decidido) | Repara solo los vehículos y construcciones aliados dañados en 50 m, empezando por el más dañado. |
| Apoyo | **Abastecer** *(propuesta)* | Se acerca a los aliados sin granadas o misiles para reponérselos. |
| Apoyo con lanzamisiles | **Antivehículos** *(propuesta)* | Usa el lanzamisiles contra vehículos y helicópteros antes que la ametralladora contra soldados. |
| Francotirador | **Objetivos clave** *(propuesta)* | Dispara primero a médicos, apoyos, francotiradores y artilleros asomados. |
| Tanques y Hummer armado | **Preferir vehículos o infantería** *(propuesta)* | Elige a qué dispara primero cuando tiene varios objetivos. |
| Tanque antiaéreo | **Solo aire** *(propuesta)* | Ignora lo de tierra y solo dispara a helicópteros y drones. |

**Pendiente:** confirmar las propuestas y decidir si hay más prioridades especiales.

## Parte 15. Controles *(propuesta)*

Basado en Company of Heroes y Men of War, con la cámara de Defilade. Todas las teclas se pueden cambiar en Opciones.

### 15.1 Ratón

| Acción | Qué hace |
| --- | --- |
| Clic izquierdo | Seleccionar una unidad |
| Arrastrar con clic izquierdo | Seleccionar varias con un recuadro |
| Doble clic izquierdo | Seleccionar todas las del mismo tipo que se ven en pantalla |
| Shift + clic izquierdo | Añadir o quitar de la selección |
| Clic derecho | Mover, atacar, subir a un vehículo o meterse en una casa, según dónde se pulse |
| Arrastrar con clic derecho | Mover y elegir hacia dónde miran al llegar (las unidades se reparten en una línea) |
| Ctrl + clic derecho | Ataque-movimiento: avanzan y atacan lo que encuentren |
| Alt + clic derecho | Marcha atrás (vehículos): retroceder sin dar la espalda, importante por el blindaje trasero |
| Shift + clic derecho | Encadenar órdenes (ir a A, luego a B…) |
| Alt + clic izquierdo en el mapa | Marcar un punto para el equipo, con aviso sonoro |
| Botón central | Mantener y mover para girar la cámara |
| Rueda | Zoom |

### 15.2 Teclado

| Tecla | Qué hace |
| --- | --- |
| W A S D o flechas | Mover la cámara (también con el ratón en el borde) |
| H | Ir a la base |
| N | Ir a la hot zone |
| Alt + Espacio | Ir al último aviso |
| Espacio | Detener a las unidades seleccionadas |
| Ctrl + 1…0 | Guardar la selección como grupo |
| 1…0 | Seleccionar ese grupo; pulsar dos veces centra la cámara |
| Tab | Pasar entre los tipos de unidad de la selección |
| Q | Objeto 1 de la clase (granada, humo, C4, lanzamisiles) |
| E | Objeto 2 de la clase (dron, adrenalina, desfibrilador) |
| R | Acción de la clase (reanimar, reparar, abastecer, desplegar el tanque lanzamisiles) |
| B | Menú de construcción (Ingeniero) |
| T | Cambiar postura: de pie, agachado, cuerpo a tierra |
| U | Bajar del vehículo o salir de la casa |
| Z / X / C / V | Modo Cobertura / Vigila / Prioridad / Alto el fuego |
| G | Prioridad especial de la clase (encender o apagar) |
| F1 / F2 / F3 / F4 | Pestaña de compra: Infantería / Vehículos / Helicópteros / Construcción |
| Ctrl + F | Pedir el pelotón gratis |
| Enter / Shift + Enter | Chat de equipo / chat de todos |
| Esc | Cancelar o abrir el menú de pausa |

## Parte 16. IA enemiga *(propuesta)*

**La IA nunca hace trampas** en ningún nivel: mismo dinero, misma visión y mismas reglas que un jugador. Lo que cambia es lo bien que juega.

### 16.1 Niveles

|  | Fácil | Normal | Difícil |
| --- | --- | --- | --- |
| Tiempo de reacción | 3 s | 1,5 s | 0,5 s |
| Gasto | Compra poco a poco y guarda mucho dinero | Compra por oleadas | Compra por oleadas y guarda una reserva para responder |
| Qué compra | Sobre todo Asaltos y Hummer | Mezcla equilibrada de infantería y vehículos | Responde a lo que tú usas (antiaéreos si usas helicópteros, lanzamisiles si usas tanques) |
| Mejoras | No compra | Compra algunas | Compra todas las que puede |
| FOB y construcción | No construye | 1 FOB y algunos muros | Hasta 3 FOB, muros, vallas y morteros |
| Táctica | Va recto a la zona | Usa coberturas y modos | Flanquea, ataca tanques por detrás, retira vehículos dañados para repararlos y reanima a sus caídos |
| Hot zone | Va cuando ya se ha movido | Va al recibir el aviso | Se adelanta y prepara la posición antes de que cambie |

### 16.2 Cómo decide

- **Objetivo principal:** tener más MG que nadie en la hot zone; si no puede, en la zona de guerra.
- **A quién ataca:** sobre todo al equipo que va ganando. Así, en partidas de 3, el que va primero no se escapa.
- **Cuándo se retira:** si pierde más de la mitad de un grupo, se retira a la FOB más cercana para reagruparse.

### 16.3 IA como compañero

- En 2v2v2 se puede tener una IA de compañero. Comparte dinero como un jugador, sigue tus marcas en el mapa (Alt + clic) y no gasta más de la mitad del dinero del equipo.
- Cuando la IA sustituye a un jugador desconectado (Parte 11.1) juega en nivel Normal, pero de forma más defensiva: mantiene sus unidades y no gasta casi dinero, para que el jugador las encuentre al volver.

## Parte 17. Desarrollo de una partida *(propuesta)*

### 17.1 Inicio

- **Pantalla de carga** con el mapa, los equipos y un consejo.
- **30 s de preparación:** se puede comprar y las unidades aparecen en la base, pero nadie puntúa hasta que acaba la cuenta atrás.

### 17.2 Durante la partida

- No hay límite de tiempo por defecto: se juega hasta que alguien llega a 100 puntos. En la sala se puede poner un límite opcional; al acabar el tiempo gana quien tenga más puntos.
- **Rendición:** a partir del minuto 10, un equipo puede rendirse. En 2v2v2 tienen que estar de acuerdo los dos jugadores. El equipo que se rinde sale de la partida y los otros dos siguen.
- **Pausa:** solo por desconexión (Parte 11.1). Contra la IA se puede pausar cuando se quiera.

### 17.3 Final

- Al llegar a 100 puntos aparece «Victoria» o «Derrota» y la cámara se acerca a la hot zone.
- **Pantalla de estadísticas:**
  - Gráfica de los puntos de cada equipo a lo largo de la partida.
  - Por jugador: bajas, pérdidas, dinero ganado y gastado, MG media en la zona, XP y rangos conseguidos.
  - La **unidad más valiosa**: la clase o vehículo que más daño hizo.
  - Botones: volver a la sala y salir.

### 17.4 Repeticiones

- Las últimas 10 partidas se guardan solas.
- Se ven con cámara libre, se puede ver lo que veía cada equipo y se puede acelerar de x1 a x8.
- Puede quedar para más adelante si complica el desarrollo.

## Parte 18. Tutorial *(propuesta)*

### 18.1 Misiones de entrenamiento

5 misiones cortas (5 a 10 minutos cada una), con texto y voz que guían paso a paso contra una IA preparada.

| Misión | Qué enseña |
| --- | --- |
| 1. Primeros pasos | Cámara, seleccionar, mover, grupos |
| 2. Combate | Disparar, coberturas, posturas, modos de comportamiento, médico y reanimar |
| 3. Vehículos | Conductor, artillero, transportar tropas, robar un vehículo, blindaje trasero |
| 4. Ganar la partida | MG, zona de guerra, hot zone, puntos y dinero por bajas |
| 5. Base avanzada | Ingeniero, FOB, muros, mortero, mejoras de rango y helicópteros |

### 18.2 Ayudas

- **Consejos en pantalla** durante las primeras partidas (por ejemplo, «Tu tanque está recibiendo daño por detrás»). Se pueden apagar.
- **Enciclopedia** en el menú: la ficha de cada unidad con sus datos, contra qué es fuerte y débil (Partes 13 y 14).
- **Partida de práctica** contra la IA en Fácil desde el menú principal.

## Parte 19. Efectos, animaciones y fortificaciones *(propuesta)*

Esta parte sale del vídeo de referencia de Defilade que trajo Vito el 22 de octubre de 2026 (análisis completo en el PDF «WARRTS\_analisis\_video\_Defilade»). Copiamos las ideas y la sensación, nunca modelos, texturas ni sonidos. Quedan fuera la rendición, el ataque aéreo, la bomba nuclear y el modo Supervivencia.

### 19.1 Aspecto en partida

- **Efecto maqueta:** los bordes de la pantalla se ven un poco desenfocados (tilt-shift), como en Defilade. Se puede desactivar en Opciones.
- **Luz:** sol fuerte y bajo, con sombras largas y nítidas de árboles, casas y unidades. Colores limpios y claros.
- **El suelo guarda la batalla:** huellas de soldados, rodadas de vehículos, cráteres, manchas de sangre y quemaduras de explosión se quedan en el mapa. Hay un límite por zona y las más antiguas se borran poco a poco, para no perder rendimiento.
- **Clima por mapa, solo visual:** nieve cayendo en Nieve, polvo y arena en Desierto, niebla ligera en Montaña y nada en Mixto.
- **Niebla de guerra:** lo que tu equipo no ve se muestra oscurecido en gris; lo que ve queda iluminado con bordes suaves. Las reglas de visión no cambian (13.5).

### 19.2 Efectos de combate

- **Disparos:** trazadoras finas, fogonazo en el cañón y nube de humo hacia atrás al disparar lanzamisiles.
- **Explosiones con volumen:** fogonazo, bola de humo gris o negro que tarda en irse y tierra, arena o nieve que salta. Las grandes (cañón de tanque pesado, misil, mortero) muestran una onda expansiva.
- **El humo de las explosiones grandes corta la visión** en 5 m durante 5 s. La granada de humo del Apoyo sigue igual (15 s en 10 m).
- **Metralla:** se ve saltar en las explosiones. A efectos de reglas es el daño en área que ya tienen las tablas de la Parte 13.
- **Muertes físicas (ragdoll):** los soldados caen de forma realista y las explosiones los lanzan. Solo cerca de la cámara; lejos se usa una animación normal de caída.
- **Vehículo con poca vida:** echa humo (ya en 14.8). Al ser destruido arde 30 s con fuego y humo negro.

### 19.3 Soldados: coberturas y animaciones

- **Cobertura automática:** en modo Cobertura (14.20) el soldado se pega a paredes, esquinas, rocas, sacos y restos de vehículos, y se asoma para disparar. En trincheras y pozos se mete dentro y apenas asoma.
- **Granadas enemigas:** el soldado que ve caer una granada a menos de 5 m se tira al suelo, y al estar cuerpo a tierra recibe la mitad de daño (14.1). Si la granada cae a menos de 2 m de un Asalto o un Apoyo que no esté suprimido, tiene un **15% de probabilidad de devolverla**.
- **Torniquete:** el soldado caído (6.1) se pone un torniquete solo y aguanta **90 s en vez de 60** esperando al médico. Se arrastra despacio hacia la cobertura más cercana.
- **Arrastrar heridos:** los compañeros arrastran al caído a un lugar seguro, como ya dice la Parte 6, ahora con su animación.
- **Animaciones que hay que hacer:** correr agachado, pegarse a la pared, asomarse por la esquina, tirarse al suelo, recargar, lanzar granada, devolver granada, saltar obstáculos bajos, cavar, ponerse el torniquete y arrastrar a un compañero.
- **Movimiento:** los soldados de un grupo no van en bloque. Cada uno sigue su camino con algo de separación y, al llegar, busca dónde cubrirse.
- **Nombres:** cada soldado tiene un nombre y el rango de su clase (la XP sigue siendo por clase, Parte 9). Su nombre sale en los avisos de baja y de ascenso.

### 19.4 Restos y edificios

- **Restos de vehículos:** el casco de un vehículo destruido se queda 3 minutos en el mapa. Sirve de cobertura a la infantería (mitad de daño de balas) y los vehículos tienen que rodearlo.
- **Edificios por fases:**

| Fase | Cuándo | Cómo se ve | Efecto |
| --- | --- | --- | --- |
| Intacto | Más del 50% de vida | Casa entera | Hasta 6 soldados dentro, mitad de daño de balas (14.1) |
| Dañado | Del 50% al 1% | Sin tejado, con agujeros en las paredes | Igual que intacto, pero los explosivos que caen dentro hacen daño completo |
| Ruina | 0% | Paredes bajas y escombros | Ya no se puede entrar. Los escombros dan cobertura como un muro bajo |

### 19.5 Fortificaciones de campo

Se suman a las construcciones de la Parte 10 y siguen sus reglas: las hace el ingeniero, se pagan al empezar y el enemigo puede destruirlas.

| Fortificación | Coste | Tiempo | Vida | Máximo por equipo | Qué hace |
| --- | --- | --- | --- | --- | --- |
| Trinchera | 1.000 $ por tramo de 10 m | 15 s por tramo | No se destruye | 30 tramos | El jugador la dibuja en zigzag. Dentro, la infantería recibe un 75% menos de daño de balas y la mitad de explosivos, salvo si el explosivo cae dentro. Se mueve a la mitad de velocidad. Los vehículos con ruedas no la cruzan; los tanques sí |
| Pozo de tirador | 500 $ | 8 s | No se destruye | 20 | Hoyo con sacos para 2 soldados, con la misma protección que la trinchera |
| Sacos terreros | 300 $ | 4 s | 300 | 40 (sumando muros, vallas, sacos y erizos) | Cobertura ligera: mitad de daño de balas. Los tanques los aplastan |
| Erizos antitanque | 1.000 $ | 6 s | 600 | 40 (sumando muros, vallas, sacos y erizos) | Los vehículos de tierra no pueden pasar; la infantería sí. Solo los rompen explosivos, cañones y misiles |
| Red de camuflaje | 2.000 $ | 6 s | 100 | 10 | Cubre 10 × 10 m. Las unidades quietas debajo no las ven el dron, los helicópteros ni los morteros. Las unidades de tierra enemigas solo las ven a menos de 50 m |

### 19.6 Interfaz nueva

- **Menú circular de construcción:** al seleccionar un ingeniero y pulsar el botón de construir sale un menú en círculo con cada construcción, su icono y su coste. Sustituye a la pestaña Construcción del panel de compra (12.3).
- **Planos azules:** el jugador coloca o dibuja la construcción en azul y el ingeniero va a hacerla. Si no cabe o incumple una regla (por ejemplo, la distancia entre FOB), el plano sale en rojo con el aviso «No cabe» o el motivo.
- **Lista del grupo:** al seleccionar un grupo sale la lista de sus soldados con su nombre y lo que hace en ese momento: avanzando, a cubierto, buscando cobertura, cavando, caído.
- **Avisos de eventos** abajo a la izquierda: «Ascendido: Cabo Martín» y «Baja: Soldado Pérez · Asalto». Sustituye al registro de bajas de 12.3.

## Estado de cada parte

| Parte | Estado |
| --- | --- |
| 1. Visión y modos | Decidido |
| 2. Facciones | Decidido |
| 3. Mapas | Decidido (números por probar) |
| 4. Puntuación y victoria | Decidido (números por probar) |
| 5. Economía | Decidido (números por probar) |
| 6. Infantería | Decidido |
| 7. Vehículos de tierra | Decidido (números por probar) |
| 8. Vehículos aéreos | Decidido (números por probar) |
| 9. Rangos y mejoras | Decidido (números por probar) |
| 10. Construcción y despliegue | Decidido (números por probar) |
| 11. Multijugador | Decidido (base) |
| 12. Arte, sonido e interfaz | Decidido (números por probar) |
| 13. Sistema de combate y parámetros | Decidido (números por probar) |
| 14. Mecánicas de cada unidad | Decidido (números por probar) |
| 15. Controles | Decidido (base) |
| 16. IA enemiga | Decidido (base) |
| 17. Desarrollo de una partida | Decidido (base) |
| 18. Tutorial | Decidido (base) |
| 19. Efectos, animaciones y fortificaciones | Decidido (números por probar) |
