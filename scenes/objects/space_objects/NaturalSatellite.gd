extends Node2D

## 천연 위성: 행성 주위 궤도 + 행성보다 약하고 좁은 자체 중력.

@export var orbit_target: NodePath
@export var orbit_radius := 165.0
@export var orbit_speed := 0.55
@export var phase_rad := 0.0

@export var gravity_strength := 1_200_000.0
@export var gravity_radius := 118.0
@export var gravity_min_dist := 40.0

@onready var _gravity_viz: Node2D = $GravityViz

var _angle := 0.0


func _ready() -> void:
	_angle = phase_rad
	add_to_group("moon_gravity")
	if is_instance_valid(_gravity_viz):
		_gravity_viz.set("radius", gravity_radius)
		_gravity_viz.queue_redraw()


func _process(delta: float) -> void:
	var center_node := get_node_or_null(orbit_target) as Node2D
	if center_node == null:
		return
	_angle += orbit_speed * delta
	var center := center_node.global_position
	global_position = center + Vector2(cos(_angle), sin(_angle)) * orbit_radius


func apply_gravity_acceleration(player_ship: CharacterBody2D) -> void:
	if not is_instance_valid(player_ship):
		return
	var ship_pos := player_ship.global_position
	var delta_v := global_position - ship_pos
	var dist := maxf(delta_v.length(), gravity_min_dist)
	if dist > gravity_radius:
		return
	var dir := delta_v / dist
	var a := dir * (gravity_strength / (dist * dist))
	if player_ship.has_method("add_external_accel"):
		player_ship.call("add_external_accel", a)
	else:
		player_ship.velocity += a * get_physics_process_delta_time()
