class_name GameData
## Datos de balance del juego (ver el GDD). Cambia los números aquí para ajustar
## el juego sin tocar la lógica. Las 3 facciones usan exactamente los mismos datos;
## solo cambia su aspecto.

## Dinero con el que empieza cada equipo.
const START_MONEY := 1000000
## Parte del coste de una unidad enemiga que se cobra al destruirla.
const KILL_REWARD := 0.5
## Recompensa si la baja ocurre dentro de la hot zone.
const KILL_REWARD_HOT := 0.75
## Por debajo de este dinero el equipo puede pedir un pelotón gratis.
const FREE_SQUAD_THRESHOLD := 20000
const FREE_SQUAD_COOLDOWN := 90.0
const FREE_SQUAD := ["assault", "assault", "assault", "assault"]
## Unidades máximas en el campo por equipo (rendimiento; a ajustar).
const POP_CAP := 70

## Puntuación (medida de guerra)
const SCORE_TO_WIN := 100
const SCORE_INTERVAL := 6.0
const HOT_ZONE_MULT := 2.0
const WAR_ZONE_RADIUS := 110.0
const HOT_ZONE_RADIUS := 30.0
const HOT_ZONE_MOVE_TIME := 180.0
const HOT_ZONE_WARNING := 30.0

const FOB_COST := 50000
const FOB_BUILD_TIME := 12.0
const FOB_MAX := 3
## Distancia a la que debe estar un ingeniero para construir.
const BUILD_RANGE := 12.0

const FACTIONS := [
	{"name": "Coalición Atlántica", "color": Color(0.25, 0.45, 0.85), "camo": Color(0.62, 0.56, 0.42)},
	{"name": "Ejército del Este", "color": Color(0.8, 0.22, 0.2), "camo": Color(0.3, 0.34, 0.22)},
	{"name": "Guardia del Desierto", "color": Color(0.9, 0.72, 0.25), "camo": Color(0.72, 0.64, 0.48)},
]

## Orden en el que aparecen en la interfaz.
const INFANTRY := ["driver", "pilot", "assault", "medic", "engineer", "support", "sniper"]
const VEHICLES := ["light", "drone", "apc", "heli_transport", "artillery", "tank", "heli_attack"]

## weapon: nombre del arma. deploy: segundos que tarda en aparecer tras comprarla.
## crew: "ground"/"air" = tipo de vehículo que puede manejar (infantería) o que necesita (vehículo).
## seats: pasajeros que puede llevar. mg: medida de guerra. air_ok: puede disparar a aeronaves.
const UNITS := {
	# ---------------- Infantería
	"driver": {
		"name": "Conductor", "weapon": "Subfusil", "deploy": 3.0, "cost": 4000, "mg": 1, "hp": 50.0, "speed": 4.2,
		"range": 12.0, "damage": 5.0, "rate": 0.9, "dmg_type": "bullet", "air_ok": true,
		"armor": "light", "radius": 0.6, "crew": "ground",
	},
	"pilot": {
		"name": "Piloto", "weapon": "Subfusil", "deploy": 3.0, "cost": 6000, "mg": 1, "hp": 50.0, "speed": 4.2,
		"range": 12.0, "damage": 5.0, "rate": 0.9, "dmg_type": "bullet", "air_ok": true,
		"armor": "light", "radius": 0.6, "crew": "air",
	},
	"assault": {
		"name": "Asalto", "weapon": "Fusil de asalto", "deploy": 4.0, "cost": 5000, "mg": 2, "hp": 70.0, "speed": 4.3,
		"range": 15.0, "damage": 9.0, "rate": 0.7, "dmg_type": "bullet", "air_ok": true,
		"armor": "light", "radius": 0.6,
	},
	"medic": {
		"name": "Médico", "weapon": "Carabina", "deploy": 5.0, "cost": 8000, "mg": 1, "hp": 60.0, "speed": 4.3,
		"range": 13.0, "damage": 6.0, "rate": 0.9, "dmg_type": "bullet", "air_ok": true,
		"armor": "light", "radius": 0.6, "heal": 6.0,
	},
	"engineer": {
		"name": "Ingeniero", "weapon": "Lanzacohetes", "deploy": 5.0, "cost": 8000, "mg": 1, "hp": 60.0, "speed": 4.0,
		"range": 18.0, "damage": 50.0, "rate": 3.2, "dmg_type": "rocket", "air_ok": true,
		"armor": "light", "radius": 0.6, "repair": 20.0, "builder": true,
	},
	"support": {
		"name": "Apoyo", "weapon": "Ametralladora", "deploy": 6.0, "cost": 10000, "mg": 2, "hp": 85.0, "speed": 3.6,
		"range": 17.0, "damage": 7.0, "rate": 0.22, "dmg_type": "bullet", "air_ok": true,
		"armor": "light", "radius": 0.6,
	},
	"sniper": {
		"name": "Francotirador", "weapon": "Rifle de precisión", "deploy": 8.0, "cost": 15000, "mg": 2, "hp": 50.0, "speed": 4.0,
		"range": 32.0, "damage": 48.0, "rate": 3.0, "dmg_type": "bullet", "air_ok": false,
		"armor": "light", "radius": 0.6,
	},
	# ---------------- Vehículos (se compran vacíos)
	"light": {
		"name": "Vehículo ligero", "weapon": "Ametralladora pesada", "deploy": 10.0, "cost": 40000, "mg": 4, "hp": 320.0, "speed": 11.0,
		"range": 18.0, "damage": 10.0, "rate": 0.2, "dmg_type": "bullet", "air_ok": true,
		"armor": "medium", "radius": 1.7, "crew": "ground", "seats": 3, "vehicle": true,
	},
	"drone": {
		"name": "Dron de ataque", "weapon": "Misiles ligeros", "deploy": 12.0, "cost": 60000, "mg": 3, "hp": 140.0, "speed": 14.0,
		"range": 16.0, "damage": 45.0, "rate": 3.0, "dmg_type": "rocket", "air_ok": false,
		"armor": "medium", "radius": 1.2, "crew": "air", "seats": 0, "vehicle": true, "fly": 9.0,
	},
	"apc": {
		"name": "Transporte blindado", "weapon": "Cañón automático", "deploy": 15.0, "cost": 90000, "mg": 6, "hp": 650.0, "speed": 9.0,
		"range": 18.0, "damage": 14.0, "rate": 0.25, "dmg_type": "bullet", "air_ok": true,
		"armor": "medium", "radius": 2.1, "crew": "ground", "seats": 8, "vehicle": true,
	},
	"heli_transport": {
		"name": "Helicóptero de transporte", "weapon": "Ametralladora lateral", "deploy": 20.0, "cost": 120000, "mg": 5, "hp": 500.0, "speed": 18.0,
		"range": 14.0, "damage": 7.0, "rate": 0.3, "dmg_type": "bullet", "air_ok": true,
		"armor": "medium", "radius": 3.0, "crew": "air", "seats": 8, "vehicle": true, "fly": 14.0,
	},
	"artillery": {
		"name": "Artillería", "weapon": "Obús", "deploy": 20.0, "cost": 150000, "mg": 6, "hp": 360.0, "speed": 6.0,
		"range": 70.0, "min_range": 15.0, "damage": 120.0, "rate": 6.0, "dmg_type": "shell", "splash": 5.0,
		"air_ok": false, "armor": "medium", "radius": 2.3, "crew": "ground", "seats": 0, "vehicle": true,
	},
	"tank": {
		"name": "Tanque", "weapon": "Cañón principal", "deploy": 25.0, "cost": 200000, "mg": 10, "hp": 1200.0, "speed": 6.5,
		"range": 24.0, "damage": 140.0, "rate": 3.0, "dmg_type": "shell", "splash": 2.0,
		"air_ok": false, "armor": "heavy", "radius": 2.5, "crew": "ground", "seats": 0, "vehicle": true,
	},
	"heli_attack": {
		"name": "Helicóptero de ataque", "weapon": "Cohetes", "deploy": 30.0, "cost": 250000, "mg": 10, "hp": 700.0, "speed": 16.0,
		"range": 28.0, "damage": 60.0, "rate": 1.5, "dmg_type": "rocket", "air_ok": true,
		"armor": "medium", "radius": 3.0, "crew": "air", "seats": 0, "vehicle": true, "fly": 13.0,
	},
}

## Multiplicador de daño según tipo de daño (fila) y blindaje (columna).
const DAMAGE_MULT := {
	"bullet": {"light": 1.0, "medium": 0.35, "heavy": 0.06, "building": 0.1},
	"rocket": {"light": 0.5, "medium": 1.4, "heavy": 1.2, "building": 1.0},
	"shell": {"light": 0.8, "medium": 1.2, "heavy": 1.0, "building": 1.5},
}


static func is_vehicle(unit_type: String) -> bool:
	return UNITS[unit_type].get("vehicle", false)


static func is_air(unit_type: String) -> bool:
	return UNITS[unit_type].has("fly")


## Conductor o piloto que necesita un vehículo.
static func crew_type_for(unit_type: String) -> String:
	return "pilot" if UNITS[unit_type].get("crew", "") == "air" else "driver"


static func format_money(amount: int) -> String:
	var s := str(absi(amount))
	var out := ""
	while s.length() > 3:
		out = "." + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if amount < 0 else "") + s + out + " $"


static func make_material(color: Color, roughness: float = 0.8) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	return mat


static func unshaded(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if color.a < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat


static func add_mesh(parent: Node3D, mesh: Mesh, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	parent.add_child(mi)
	return mi


static func box(size: Vector3) -> BoxMesh:
	var m := BoxMesh.new()
	m.size = size
	return m


static func cylinder(radius: float, height: float, top_radius: float = -1.0) -> CylinderMesh:
	var m := CylinderMesh.new()
	m.top_radius = radius if top_radius < 0.0 else top_radius
	m.bottom_radius = radius
	m.height = height
	m.radial_segments = 12
	return m


static func ring(radius: float, width: float) -> TorusMesh:
	var m := TorusMesh.new()
	m.inner_radius = radius - width * 0.5
	m.outer_radius = radius + width * 0.5
	m.rings = 64
	m.ring_segments = 8
	return m


const ARMOR_NAMES := {"light": "ligero", "medium": "medio", "heavy": "pesado", "building": "edificio"}
const DMG_NAMES := {"bullet": "bala", "rocket": "cohete", "shell": "proyectil"}


## Daño por segundo contra un tipo de blindaje.
static func dps(unit_type: String, armor_type: String) -> float:
	var d: Dictionary = UNITS[unit_type]
	return d.damage / d.rate * DAMAGE_MULT[d.dmg_type][armor_type]


## Texto de ayuda con la ficha completa de una unidad.
static func describe(unit_type: String) -> String:
	var d: Dictionary = UNITS[unit_type]
	var lines: Array = [
		"%s — %s · MG %d · aparece en %d s" % [d.name, format_money(d.cost), d.mg, int(d.deploy)],
		"Vida %d · blindaje %s · velocidad %.1f m/s" % [d.hp, ARMOR_NAMES[d.armor], d.speed],
		"%s: %d de daño (%s) cada %.2f s · alcance %d m%s" % [
			d.weapon, d.damage, DMG_NAMES[d.dmg_type], d.rate, d.range,
			" (mínimo %d m)" % d.min_range if d.has("min_range") else ""],
		"Daño/seg: ligero %.0f · medio %.0f · pesado %.0f · edificio %.0f" % [
			dps(unit_type, "light"), dps(unit_type, "medium"), dps(unit_type, "heavy"), dps(unit_type, "building")],
	]
	if not d.air_ok:
		lines.append("No puede disparar a aeronaves")
	if d.has("splash"):
		lines.append("Daño en área: %d m" % d.splash)
	if d.has("heal"):
		lines.append("Cura %d de vida/seg a la infantería cercana" % d.heal)
	if d.has("repair"):
		lines.append("Repara %d de vida/seg a vehículos y edificios; construye zonas de despliegue" % d.repair)
	if d.get("vehicle", false):
		lines.append("Necesita %s · %d pasajeros" % ["piloto" if d.crew == "air" else "conductor", d.get("seats", 0)])
	elif d.has("crew"):
		lines.append("Puede manejar %s" % ("aeronaves" if d.crew == "air" else "vehículos de tierra"))
	return "\n".join(lines)
