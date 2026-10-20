class_name MapBuilder
extends Node3D
## Genera el mapa (por ahora el "mixto"): suelo, caminos, obstáculos que bloquean el
## paso y la malla de navegación para que las unidades de tierra los rodeen.

const MAP_HALF := 400.0
const BASE_DISTANCE := 330.0
## Tamaño de celda de la navegación (metros).
const NAV_CELL := 1.0

var base_positions: Array = []
var nav_map: RID
var _rng := RandomNumberGenerator.new()
var _obstacles: Node3D
var _rock_mat: StandardMaterial3D
var _ruin_mat: StandardMaterial3D
var _trunk_mat: StandardMaterial3D
var _leaf_mat: StandardMaterial3D


func build(map_seed: int) -> void:
	_rng.seed = map_seed
	for i in 3:
		var angle := -PI / 2.0 + i * TAU / 3.0
		base_positions.append(Vector3(cos(angle), 0, sin(angle)) * BASE_DISTANCE)
	_rock_mat = GameData.make_material(Color(0.42, 0.41, 0.39))
	_ruin_mat = GameData.make_material(Color(0.58, 0.54, 0.46))
	_trunk_mat = GameData.make_material(Color(0.3, 0.22, 0.15))
	_leaf_mat = GameData.make_material(Color(0.2, 0.28, 0.15))

	_obstacles = Node3D.new()
	_obstacles.name = "Obstacles"
	add_child(_obstacles)
	_build_ground()
	_build_roads()
	_scatter_rocks(140)
	_scatter_forests(28)
	_scatter_ruins(40)
	_bake_navigation()


func _build_ground() -> void:
	var noise := FastNoiseLite.new()
	noise.frequency = 0.015
	noise.fractal_octaves = 4
	var tex := NoiseTexture2D.new()
	tex.noise = noise
	tex.seamless = true
	tex.width = 1024
	tex.height = 1024
	var grad := Gradient.new()
	grad.set_color(0, Color(0.22, 0.25, 0.16))
	grad.set_color(1, Color(0.42, 0.38, 0.27))
	tex.color_ramp = grad
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = tex
	mat.uv1_scale = Vector3(12, 12, 1)
	mat.roughness = 1.0
	var plane := PlaneMesh.new()
	plane.size = Vector2(MAP_HALF * 2.3, MAP_HALF * 2.3)
	GameData.add_mesh(self, plane, mat, Vector3.ZERO)

	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(MAP_HALF * 2.1, 1.0, MAP_HALF * 2.1)
	shape.shape = box
	shape.position.y = -0.5
	body.add_child(shape)
	_obstacles.add_child(body)


## Caminos de tierra desde cada base hasta la zona de guerra (solo visuales).
func _build_roads() -> void:
	var road_mat := GameData.make_material(Color(0.45, 0.4, 0.3))
	for p in base_positions:
		var length: float = p.length()
		var road := GameData.add_mesh(self, GameData.box(Vector3(8, 0.04, length)), road_mat, p * 0.5 + Vector3(0, 0.02, 0))
		road.look_at(Vector3(0, 0.02, 0), Vector3.UP)


func _is_clear(pos: Vector3, margin: float) -> bool:
	if absf(pos.x) > MAP_HALF - 5.0 or absf(pos.z) > MAP_HALF - 5.0:
		return false
	for p in base_positions:
		if pos.distance_to(p) < 45.0 + margin:
			return false
		# Deja libres los caminos principales.
		var closest := Geometry3D.get_closest_point_to_segment(pos, p, Vector3.ZERO)
		if pos.distance_to(closest) < 7.0 + margin:
			return false
	return true


func _random_pos() -> Vector3:
	return Vector3(_rng.randf_range(-MAP_HALF, MAP_HALF), 0, _rng.randf_range(-MAP_HALF, MAP_HALF))


func _add_cylinder_obstacle(pos: Vector3, r: float, h: float) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	var shape := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = r
	cyl.height = h
	shape.shape = cyl
	shape.position.y = h * 0.5
	body.add_child(shape)
	_obstacles.add_child(body)


func _scatter_rocks(count: int) -> void:
	for i in count:
		var pos := _random_pos()
		var s := _rng.randf_range(1.5, 5.0)
		if not _is_clear(pos, s):
			continue
		var rock := SphereMesh.new()
		rock.radius = s
		rock.height = s * _rng.randf_range(0.9, 1.4)
		var mi := GameData.add_mesh(self, rock, _rock_mat, pos + Vector3(0, s * 0.25, 0), Vector3(0, _rng.randf() * TAU, 0))
		mi.scale = Vector3(1.0, 1.0, _rng.randf_range(0.7, 1.3))
		_add_cylinder_obstacle(pos, s * 0.95, s)


func _scatter_forests(count: int) -> void:
	for i in count:
		var center := _random_pos()
		if center.length() < GameData.WAR_ZONE_RADIUS + 20.0:
			continue
		for t in 12:
			var pos := center + Vector3(_rng.randf_range(-14, 14), 0, _rng.randf_range(-14, 14))
			if not _is_clear(pos, 1.0):
				continue
			var h := _rng.randf_range(5.0, 9.0)
			GameData.add_mesh(self, GameData.cylinder(0.25, h * 0.4), _trunk_mat, pos + Vector3(0, h * 0.2, 0))
			GameData.add_mesh(self, GameData.cylinder(h * 0.28, h * 0.8, 0.0), _leaf_mat, pos + Vector3(0, h * 0.75, 0))
			_add_cylinder_obstacle(pos, 0.6, h)


## Muros en ruinas: dan cobertura en la zona de guerra.
func _scatter_ruins(count: int) -> void:
	for i in count:
		var angle := _rng.randf() * TAU
		var dist := sqrt(_rng.randf()) * (GameData.WAR_ZONE_RADIUS + 30.0)
		var pos := Vector3(cos(angle), 0, sin(angle)) * dist
		var length := _rng.randf_range(5.0, 12.0)
		if not _is_clear(pos, length * 0.5):
			continue
		var height := _rng.randf_range(2.0, 4.0)
		var rot := _rng.randf() * PI
		var body := StaticBody3D.new()
		body.position = pos
		body.rotation.y = rot
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(length, height, 1.0)
		shape.shape = box
		shape.position.y = height * 0.5
		body.add_child(shape)
		_obstacles.add_child(body)
		GameData.add_mesh(body, GameData.box(box.size), _ruin_mat, shape.position)
		# Algunos muros forman esquinas.
		if _rng.randf() < 0.5:
			var side := GameData.box(Vector3(1.0, height * 0.8, length * 0.6))
			GameData.add_mesh(body, side, _ruin_mat, Vector3(length * 0.5, height * 0.4, length * 0.3))
			var side_shape := CollisionShape3D.new()
			var side_box := BoxShape3D.new()
			side_box.size = side.size
			side_shape.shape = side_box
			side_shape.position = Vector3(length * 0.5, height * 0.4, length * 0.3)
			body.add_child(side_shape)


func _bake_navigation() -> void:
	nav_map = get_world_3d().navigation_map
	NavigationServer3D.map_set_cell_size(nav_map, NAV_CELL)
	var navmesh := NavigationMesh.new()
	navmesh.cell_size = NAV_CELL
	navmesh.cell_height = 0.25
	navmesh.agent_radius = 1.0
	navmesh.agent_height = 2.0
	navmesh.agent_max_climb = 0.5
	navmesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	navmesh.filter_baking_aabb = AABB(Vector3(-MAP_HALF, -2, -MAP_HALF), Vector3(MAP_HALF * 2, 12, MAP_HALF * 2))
	var source := NavigationMeshSourceGeometryData3D.new()
	NavigationServer3D.parse_source_geometry_data(navmesh, source, _obstacles)
	NavigationServer3D.bake_from_source_geometry_data(navmesh, source)
	var region := NavigationRegion3D.new()
	region.navigation_mesh = navmesh
	add_child(region)


func find_path(from: Vector3, to: Vector3) -> PackedVector3Array:
	return NavigationServer3D.map_get_path(nav_map, from, to, true)
