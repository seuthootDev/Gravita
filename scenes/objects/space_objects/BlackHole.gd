extends Node2D

## 강한 역제곱 중력. `StageBase`가 `black_hole` 그룹을 통해 `apply_gravity_acceleration` 호출.
## 충돌 사망은 자식 `KillZone`(Area2D + ObstacleHazard)에서 처리.

@export var gravity_strength := 48_000_000.0
@export var gravity_radius := 200.0
@export var gravity_min_dist := 40.0

@onready var _gravity_viz: Node2D = $GravityViz


func _ready() -> void:
	add_to_group("black_hole")
	if is_instance_valid(_gravity_viz):
		_gravity_viz.set("radius", gravity_radius)
		_gravity_viz.queue_redraw()


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
