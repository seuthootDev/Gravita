extends Node2D

## 소행성/잔해: `use_orbit`이면 행성 궤도, 아니면 `drift_velocity`로 표류.

@export var orbit_target: NodePath
@export var use_orbit := false
@export var orbit_radius := 180.0
@export var orbit_speed := 0.7
@export var phase_rad := 0.0
@export var drift_velocity := Vector2(30.0, 12.0)

var _angle := 0.0


func _ready() -> void:
	_angle = phase_rad


func _process(delta: float) -> void:
	if use_orbit:
		var center_node := get_node_or_null(orbit_target) as Node2D
		if center_node == null:
			return
		_angle += orbit_speed * delta
		var center := center_node.global_position
		global_position = center + Vector2(cos(_angle), sin(_angle)) * orbit_radius
	else:
		global_position += drift_velocity * delta
