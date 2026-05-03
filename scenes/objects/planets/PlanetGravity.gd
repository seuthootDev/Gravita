extends Area2D

## `StageBase`가 행성 중력 계산에 사용합니다. 블랙홀과 같이 프리팹에서 조정하세요.

@export var gravity_strength := 9_600_000.0
@export var gravity_min_dist := 60.0
## `GravityField/GravityShape` 원 반경에 곱합니다 (물리·시각 일치).
@export var gravity_radius_scale := 1.0


func get_gravity_strength() -> float:
	return gravity_strength


func get_gravity_min_dist() -> float:
	return gravity_min_dist


func get_gravity_radius() -> float:
	var shape := get_node_or_null("GravityField/GravityShape") as CollisionShape2D
	if shape and shape.shape is CircleShape2D:
		return (shape.shape as CircleShape2D).radius * gravity_radius_scale
	return 260.0 * gravity_radius_scale
