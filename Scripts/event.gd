extends Node2D

var old_pos : Vector2
@export var icon := ""
@export var new_scene : PackedScene
@export var persistent := false
var is_open = false
var death_message = ""
signal game_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#old_pos = position
	#$Icon/Sprite2D.texture = load("res://Assets/Art/Icons/" + icon)
	pass
	$Panel/SubViewportContainer/SubViewport/Timer.start(2)
	create_minigame()
	death_message = $Panel/SubViewportContainer/SubViewport/SceneSlot.get_child(0).death_message
	reset()

func create_minigame():
	var minigame : Minigame = new_scene.instantiate()
	$Panel/SubViewportContainer/SubViewport/SceneSlot.add_child(minigame)
	minigame.connect("finished", finish_success)
	minigame.connect("failed", close_remove)
	minigame.connect("closed", close)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	persistent = true
	$Icon/Label.text = str(int(ceil($Panel/SubViewportContainer/SubViewport/Timer.time_left)))


func _on_icon_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#On click
	if event is InputEventMouseButton and event.pressed and not is_open:
		open()

func open():
	if $Panel/SubViewportContainer/SubViewport/SceneSlot.get_child_count() ==0:
		create_minigame()
	is_open = true
	$AnimationPlayer.play("FadeIn")
	var tx = clamp(position.x, -320+96, 320-96)
	var ty = clamp(position.y, -180+96, 180-96)
	var tw = get_tree().create_tween()
	tw.tween_property(self, "position", Vector2(tx, ty), 0.3)
	tw.play()

func close():
	is_open = false
	$AnimationPlayer.play("FadeOut")
	var tw = get_tree().create_tween()
	tw.tween_property(self, "position", old_pos, 0.3)
	tw.play()
	if !persistent:
		reset()

func finish_success():
	if is_open:
		close()
	reset()
	turn(99)

func close_remove():
	if is_open:
		close()
	reset()
func reset():
	$Panel/SubViewportContainer/SubViewport/SceneSlot.get_child(0).queue_free()

func fail_close():
	close()

# Mutator methods to be called by random events.
func increase_time():
	turn(10)

func decrease_time():
	turn(-10)

func turn(amount):
	%Timer.wait_time = clamp(%Timer.time_left + amount/2, 0.1, 99.0)
	%Timer.start()


func _on_timer_timeout() -> void:
	emit_signal("game_over", death_message)
