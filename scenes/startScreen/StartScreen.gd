extends Control

@onready var start_button: Button = %StartButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton
@onready var options_dialog: AcceptDialog = %OptionsDialog
@onready var planet_large_preview: Node2D = $PlanetLargePreview
@onready var ship_preview_off: Node2D = $ShipPreviewOff
@onready var ship_preview_on: Node2D = $ShipPreviewOn

const GAME_SCENE_PATH := "res://scenes/stages/stage2/Stage2.tscn"

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	start_button.grab_focus()
	_position_previews()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_position_previews()

func _process(_delta: float) -> void:
	# Subtle floating motion to keep the screen alive.
	if is_instance_valid(planet_large_preview):
		var base := _planet_base_position()
		planet_large_preview.global_position = base + Vector2(0.0, 10.0 * sin(Time.get_ticks_msec() * 0.0012))

	if is_instance_valid(ship_preview_off) and is_instance_valid(ship_preview_on):
		var ship_base := _ship_base_position()
		var t := Time.get_ticks_msec() * 0.001
		ship_preview_off.global_position = ship_base + Vector2(0.0, 8.0 * sin(t * 1.1))
		ship_preview_on.global_position = ship_preview_off.global_position

		# Blink booster on/off.
		var booster_on := int(floor(t * 3.2)) % 2 == 1
		ship_preview_on.visible = booster_on
		ship_preview_off.visible = not booster_on

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_start_pressed()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_options_pressed() -> void:
	options_dialog.dialog_text = "Options는 다음 단계에서 붙일게요.\n\n- 행성 중력 영향권 표시\n- 사운드/화면 설정\n- 튜토리얼"
	options_dialog.popup_centered_ratio(0.45)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _planet_base_position() -> Vector2:
	var size := get_viewport_rect().size
	# Matches the old shader planet roughly (0.82, 0.30 of screen).
	return Vector2(size.x * 0.82, size.y * 0.30)

func _ship_base_position() -> Vector2:
	var size := get_viewport_rect().size
	# Matches the old shader left planet roughly (0.18, 0.70 of screen).
	return Vector2(size.x * 0.18, size.y * 0.70)

func _position_previews() -> void:
	if is_instance_valid(planet_large_preview):
		planet_large_preview.global_position = _planet_base_position()
	if is_instance_valid(ship_preview_off):
		ship_preview_off.global_position = _ship_base_position()
	if is_instance_valid(ship_preview_on):
		ship_preview_on.global_position = _ship_base_position()
