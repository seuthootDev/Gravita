extends CharacterBody2D

@export var initial_velocity := Vector2.ZERO
@export var thrust_accel := 520.0
@export var max_speed := 820.0

@export var fuel_max := 5.0
@export var fuel_remaining := 5.0

@onready var booster_sprite: Sprite2D = $BoosterSprite

var accel_external := Vector2.ZERO

func _ready() -> void:
	add_to_group("player")
	velocity = initial_velocity
	rotation = 0.0

func add_external_accel(a: Vector2) -> void:
	accel_external += a

func set_booster_on(on: bool) -> void:
	booster_sprite.visible = on

func consume_fuel(delta: float) -> bool:
	if fuel_remaining <= 0.0:
		return false
	fuel_remaining = maxf(0.0, fuel_remaining - delta)
	return fuel_remaining > 0.0

func fuel_ratio() -> float:
	if fuel_max <= 0.0:
		return 0.0
	return clampf(fuel_remaining / fuel_max, 0.0, 1.0)

func _physics_process(delta: float) -> void:
	var thrusting := Input.is_key_pressed(KEY_SPACE) and fuel_remaining > 0.0
	if thrusting:
		consume_fuel(delta)

	set_booster_on(thrusting)

	var a := accel_external
	accel_external = Vector2.ZERO

	if thrusting:
		var forward := Vector2.RIGHT.rotated(rotation)
		a += forward * thrust_accel

	velocity += a * delta
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	# Avoid rotation snapping when velocity is ~0 (e.g. right after reload while holding Space).
	if velocity.length_squared() > 1.0:
		rotation = velocity.angle()
	move_and_slide()

