extends Minigame

@onready var cutter: Area2D = $Cutter
@onready var cut_zone: Area2D = $CutZone
@onready var cutter_target: Sprite2D = $Cutter/CutterTarget
@onready var cutter_slash_animation: AnimatedSprite2D = $Cutter/CutterSlashAnimation
@onready var cutter_miss_sprite: Sprite2D = $Cutter/CutterMissSprite
@onready var minigame_outline: Sprite2D = $MinigameOutline

@export var speed: float = 80.0
@export var min_x: float = 180
@export var max_x: float = 430

var direction: float = 1.0
var is_slashing: bool = false
var game_won: bool = false



func _ready() -> void:
	if cutter and minigame_outline:
		#min_x = cutter.position.x
		#max_x = minigame_outline.texture.get_size().x - min_x
		pass

	cutter_slash_animation.visible = false
	cutter_miss_sprite.visible = false
	cutter_slash_animation.stop()


func _process(delta: float) -> void:
	if is_slashing or game_won:
		return

	var new_x: float = cutter.position.x + speed * delta * direction
	if new_x >= max_x:
		new_x = max_x
		direction = -1.0
	elif new_x <= min_x:
		new_x = min_x
		direction = 1.0
	cutter.position.x = new_x


func _input(event: InputEvent) -> void:
	if is_slashing or game_won:
		return

	var slash_pressed := false

	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed:
			slash_pressed = true
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			slash_pressed = true

	if slash_pressed:
		_start_slash()


func _start_slash() -> void:
	is_slashing = true
	cutter_target.visible = false
	cutter_slash_animation.visible = true
	cutter_slash_animation.play("slash")

	if not _is_overlapping_cut_zone():
		cutter_miss_sprite.visible = true


func _is_overlapping_cut_zone() -> bool:
	for area in cutter.get_overlapping_areas():
		if area == cut_zone:
			return true
	return false


func _on_cutter_slash_animation_animation_finished() -> void:
	cutter_slash_animation.visible = false
	cutter_slash_animation.stop()
	if _is_overlapping_cut_zone():
		game_won = true
		finish()
	else:
		cutter_miss_sprite.visible = false
		cutter_target.visible = true
		is_slashing = false
