extends Node2D

@onready var ship: CharacterBody2D = $Ship
@onready var planet: Area2D = $Planet
@onready var goal: Area2D = $Goal
@onready var fuel_bar: ProgressBar = $UI/FuelBar
@onready var gravity_viz: Node2D = $Planet/GravityViz

@export var bounds_margin := 160.0

# World space bounds for "map out" (in pixels).
# If you make the map wider, increase `world_bounds.size.x`.
@export var world_bounds := Rect2(0, 0, 2304, 648)

@export var planet_bob_amp := 10.0
@export var planet_bob_speed := 0.9

var _gravity_radius := 260.0
var _planet_base := Vector2.ZERO

func _ready() -> void:
	add_to_group("stage")
	planet.body_entered.connect(_on_planet_body_entered)
	goal.body_entered.connect(_on_goal_body_entered)
	_planet_base = planet.position

	if planet.has_method("get_gravity_radius"):
		_gravity_radius = planet.call("get_gravity_radius")
	else:
		var shape := planet.get_node_or_null("GravityField/GravityShape") as CollisionShape2D
		if shape and shape.shape is CircleShape2D:
			_gravity_radius = (shape.shape as CircleShape2D).radius

	if gravity_viz:
		gravity_viz.radius = _gravity_radius
		gravity_viz.queue_redraw()

	_setup_camera_limits()

func _setup_camera_limits() -> void:
	var cam := ship.get_node_or_null("Camera2D") as Camera2D
	if not cam:
		return
	cam.limit_left = int(world_bounds.position.x)
	cam.limit_top = int(world_bounds.position.y)
	cam.limit_right = int(world_bounds.position.x + world_bounds.size.x)
	cam.limit_bottom = int(world_bounds.position.y + world_bounds.size.y)

func _process(_delta: float) -> void:
	var t := Time.get_ticks_msec() * 0.001
	planet.position = _planet_base + Vector2(0.0, planet_bob_amp * sin(t * planet_bob_speed))

func _physics_process(_delta: float) -> void:
	_update_fuel_ui()
	_check_bounds()
	_apply_gravity()

func _update_fuel_ui() -> void:
	if ship.has_method("fuel_ratio"):
		fuel_bar.value = ship.call("fuel_ratio") * 100.0

func _apply_gravity() -> void:
	for node in get_tree().get_nodes_in_group("black_hole"):
		if node.has_method("apply_gravity_acceleration"):
			node.call("apply_gravity_acceleration", ship)

	for node in get_tree().get_nodes_in_group("moon_gravity"):
		if node.has_method("apply_gravity_acceleration"):
			node.call("apply_gravity_acceleration", ship)

	if not _is_ship_in_gravity():
		return

	var ship_pos := ship.global_position
	var planet_pos := planet.global_position
	var delta := planet_pos - ship_pos
	var min_dist := 60.0
	var strength := 9_600_000.0
	if planet.has_method("get_gravity_min_dist"):
		min_dist = planet.call("get_gravity_min_dist")
	if planet.has_method("get_gravity_strength"):
		strength = planet.call("get_gravity_strength")
	var dist := maxf(delta.length(), min_dist)
	var dir := delta / dist

	# Simple tuned gravity: inverse-square with clamp.
	var a := dir * (strength / (dist * dist))

	if ship.has_method("add_external_accel"):
		ship.call("add_external_accel", a)
	else:
		ship.velocity += a * get_physics_process_delta_time()

func _is_ship_in_gravity() -> bool:
	return ship.global_position.distance_to(planet.global_position) <= _gravity_radius

func _check_bounds() -> void:
	var p := ship.global_position
	var expanded := world_bounds.grow(bounds_margin)
	if not expanded.has_point(p):
		game_over("MAP_OUT")

func game_over(_reason: String) -> void:
	get_tree().reload_current_scene()

func win() -> void:
	get_tree().reload_current_scene()

func _on_planet_body_entered(body: Node) -> void:
	if body == ship:
		game_over("PLANET_COLLISION")

func _on_goal_body_entered(body: Node) -> void:
	if body == ship:
		win()
