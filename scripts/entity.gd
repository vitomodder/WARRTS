class_name Entity
extends Node3D
## Base común de unidades y edificios: facción, vida, daño, selección y barra de vida.

## Giro de la cámara; las barras de vida se orientan igual para verse de frente.
const CAMERA_YAW_DEG := 45.0

var game: Node
var faction: int = 0
var type_id: String = ""
var max_hp: float = 100.0
var hp: float = 100.0
var armor: String = "light"
var radius: float = 1.0
var selected: bool = false
var is_dead: bool = false
var last_attacker_faction: int = -1

var _ring: MeshInstance3D
var _hp_root: Node3D
var _hp_fg: MeshInstance3D
var _hp_width: float = 1.5


func get_reward() -> int:
	return 0


func is_enemy_of(other: Entity) -> bool:
	return other.faction != faction


func set_selected(value: bool) -> void:
	selected = value
	if _ring:
		_ring.visible = value
	_update_hp_bar()


func take_damage(amount: float, dmg_type: String, attacker_faction: int) -> void:
	if is_dead:
		return
	var mult: float = GameData.DAMAGE_MULT.get(dmg_type, {}).get(armor, 1.0)
	hp -= amount * mult
	last_attacker_faction = attacker_faction
	_update_hp_bar()
	if hp <= 0.0:
		die(true)


## give_reward = false cuando la facción entera es eliminada (no cuenta como baja).
func die(give_reward: bool) -> void:
	if is_dead:
		return
	is_dead = true
	hp = 0.0
	if game:
		game.on_entity_died(self, last_attacker_faction if give_reward else -1)
	queue_free()


func _build_common_visuals(bar_height: float) -> void:
	_ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = radius * 0.95
	torus.outer_radius = radius * 1.1
	_ring.mesh = torus
	var ring_mat := StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.3, 1.0, 0.4)
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ring.material_override = ring_mat
	_ring.position.y = 0.05
	_ring.scale.y = 0.2
	_ring.visible = false
	add_child(_ring)

	_hp_width = clampf(radius * 1.8, 1.2, 6.0)
	_hp_root = Node3D.new()
	_hp_root.position.y = bar_height
	_hp_root.rotation.y = deg_to_rad(CAMERA_YAW_DEG)
	add_child(_hp_root)
	var bg_mat := StandardMaterial3D.new()
	bg_mat.albedo_color = Color(0.1, 0.1, 0.1)
	bg_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	GameData.add_mesh(_hp_root, GameData.box(Vector3(_hp_width + 0.1, 0.22, 0.05)), bg_mat, Vector3.ZERO)
	var fg_mat := StandardMaterial3D.new()
	fg_mat.albedo_color = Color(0.3, 0.95, 0.35)
	fg_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_hp_fg = GameData.add_mesh(_hp_root, GameData.box(Vector3(_hp_width, 0.15, 0.06)), fg_mat, Vector3(0, 0, 0.01))
	_update_hp_bar()


func _update_hp_bar() -> void:
	if _hp_root == null:
		return
	var ratio := clampf(hp / max_hp, 0.0, 1.0)
	_hp_root.visible = selected or ratio < 0.999
	_hp_fg.scale.x = maxf(ratio, 0.001)
	_hp_fg.position.x = -_hp_width * (1.0 - ratio) * 0.5
	var mat := _hp_fg.material_override as StandardMaterial3D
	mat.albedo_color = Color(0.95, 0.25, 0.2).lerp(Color(0.3, 0.95, 0.35), ratio)
