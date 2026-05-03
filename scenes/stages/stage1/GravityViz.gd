extends Node2D

@export var radius := 260.0
@export var dash_color := Color(1, 1, 1, 0.85)
@export var dash_len := 12.0
@export var gap_len := 10.0
@export var width := 2.0

func _draw() -> void:
	if radius <= 1.0:
		return

	var step := (dash_len + gap_len) / radius
	var a := 0.0
	while a < TAU:
		var a2 := minf(a + (dash_len / radius), TAU)
		draw_arc(Vector2.ZERO, radius, a, a2, 12, dash_color, width, true)
		a += step
