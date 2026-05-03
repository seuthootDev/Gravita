extends Area2D

## 짝 `partner_path` 쪽으로 워프(양방향). “인/아웃”이 아니라 서로 짝이 되는 포털 끝.

@export var partner_path: NodePath
@export var arrival_offset := Vector2(48.0, 0.0)
@export var warp_cooldown := 0.65
@export var portal_tint := Color(0.35, 0.8, 1.0, 1.0)

var _cooldown := 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitorable = false
	body_entered.connect(_on_body_entered)
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.modulate = portal_tint


func _physics_process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)


func set_warp_cooldown(seconds: float) -> void:
	_cooldown = maxf(_cooldown, seconds)


func _on_body_entered(body: Node) -> void:
	if _cooldown > 0.0:
		return
	if not body.is_in_group("player") or not body is Node2D:
		return
	var partner := get_node_or_null(partner_path) as Node2D
	if partner == null:
		push_warning("Wormhole: partner_path 비어 있거나 잘못됨: %s" % str(partner_path))
		return
	if partner.has_method("set_warp_cooldown"):
		partner.call("set_warp_cooldown", warp_cooldown)
	(body as Node2D).global_position = partner.global_position + arrival_offset
