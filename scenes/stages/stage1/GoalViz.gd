extends Node2D

@export var radius := 18.0
@export var fill := Color(1, 1, 1, 0.08)
@export var outline := Color(1, 1, 1, 0.9)
@export var width := 2.0

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, fill)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 72, outline, width, true)

