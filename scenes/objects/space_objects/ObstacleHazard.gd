extends Area2D

## 플레이어 충돌 시 스테이지 game_over를 호출하는 장애물 트리거.

@export var death_reason := "HAZARD"


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	var stage := get_tree().get_first_node_in_group("stage")
	if stage and stage.has_method("game_over"):
		stage.call("game_over", death_reason)
