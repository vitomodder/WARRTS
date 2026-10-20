class_name GameData
## Datos de balance del juego. Cambia los números aquí para ajustar el juego
## sin tocar la lógica.

## Dinero con el que empieza cada facción.
const START_MONEY := 3000
## Parte del coste de una unidad enemiga que se cobra al destruirla (0.5 = 50%).
const KILL_REWARD := 0.5
## Distancia máxima al cuartel general para poder construir.
const BUILD_RADIUS := 32.0
## Unidades máximas en la cola de producción de cada edificio.
const MAX_QUEUE := 5

const FACTIONS := [
	{"name": "Coalición", "color": Color(0.25, 0.45, 0.85)},
	{"name": "Federación", "color": Color(0.8, 0.22, 0.2)},
	{"name": "Insurgencia", "color": Color(0.85, 0.68, 0.22)},
]

## armor: tipo de blindaje que recibe el daño. dmg_type: tipo de daño que hace.
const UNITS := {
	"infantry": {
		"name": "Infantería", "cost": 100, "hp": 60.0, "speed": 4.2,
		"range": 14.0, "damage": 9.0, "rate": 0.8,
		"armor": "light", "dmg_type": "bullet", "radius": 0.6,
		"producer": "hq", "time": 2.5,
	},
	"at": {
		"name": "Antitanque", "cost": 200, "hp": 60.0, "speed": 3.8,
		"range": 18.0, "damage": 55.0, "rate": 2.6,
		"armor": "light", "dmg_type": "rocket", "radius": 0.6,
		"producer": "hq", "time": 4.0,
	},
	"jeep": {
		"name": "Vehículo ligero", "cost": 350, "hp": 200.0, "speed": 9.0,
		"range": 16.0, "damage": 11.0, "rate": 0.3,
		"armor": "medium", "dmg_type": "bullet", "radius": 1.6,
		"producer": "factory", "time": 5.0,
	},
	"tank": {
		"name": "Tanque", "cost": 800, "hp": 650.0, "speed": 5.0,
		"range": 22.0, "damage": 95.0, "rate": 2.4,
		"armor": "heavy", "dmg_type": "shell", "radius": 2.2,
		"producer": "factory", "time": 9.0,
	},
}

const BUILDINGS := {
	"hq": {
		"name": "Cuartel general", "cost": 0, "hp": 3000.0, "reward": 1500,
		"size": Vector3(7, 3.2, 7), "produces": ["infantry", "at"],
	},
	"factory": {
		"name": "Fábrica de vehículos", "cost": 600, "hp": 1500.0, "reward": 400,
		"size": Vector3(8, 4.0, 6), "produces": ["jeep", "tank"],
	},
}

## Multiplicador de daño según tipo de daño (fila) y blindaje (columna).
const DAMAGE_MULT := {
	"bullet": {"light": 1.0, "medium": 0.45, "heavy": 0.08, "building": 0.15},
	"rocket": {"light": 0.4, "medium": 1.4, "heavy": 1.25, "building": 1.0},
	"shell": {"light": 0.7, "medium": 1.2, "heavy": 1.0, "building": 1.5},
}


static func make_material(color: Color, roughness: float = 0.8) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
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


static func cylinder(radius: float, height: float) -> CylinderMesh:
	var m := CylinderMesh.new()
	m.top_radius = radius
	m.bottom_radius = radius
	m.height = height
	m.radial_segments = 12
	return m
