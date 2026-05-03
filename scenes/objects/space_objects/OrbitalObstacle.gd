extends Node2D

## 중력 없음. `orbit_target`(보통 행성) 주위를 등속 원운동.

@export var orbit_target: NodePath
@export var orbit_radius := 140.0
@export var orbit_speed := 0.9
@export var phase_rad := 0.0

var _angle := 0.0


func _ready() -> void:
	_angle = phase_rad


func _process(delta: float) -> void:
	var center_node := get_node_or_null(orbit_target) as Node2D
	if center_node == null:
		return
	_angle += orbit_speed * delta
	var center := center_node.global_position
	global_position = center + Vector2(cos(_angle), sin(_angle)) * orbit_radius
