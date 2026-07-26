extends Node2D

var old_pos : Vector2
@export var icon := ""
@export var new_scene : PackedScene
@export var persistent := false
var is_open = false

signal done



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#old_pos = position
	#$Icon/Sprite2D.texture = load("res://Assets/Art/Icons/" + icon)
	pass

func create_minigame():
	var minigame : Minigame = new_scene.instantiate()
	$Panel/SubViewportContainer/SubViewport/SceneSlot.add_child(minigame)
	minigame.connect("finished", finish_success)
	minigame.connect("failed", close_remove)
	minigame.connect("closed", close)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	persistent = true


func _on_icon_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#On click
	if event is InputEventMouseButton and event.pressed and not is_open:
		open()

func open():
	if $Panel/SubViewportContainer/SubViewport/SceneSlot.get_child_count() ==0:
		create_minigame()
	is_open = true
	$AnimationPlayer.play("FadeIn")
	var tx = 0
	var ty = 0
	var tw = get_tree().create_tween()
	tw.tween_property(self, "global_position", Vector2(tx, ty), 0.3)
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
	emit_signal("done")
	queue_free()

func close_remove():
	if is_open:
		close()
	reset()
func reset():
	$Panel/SubViewportContainer/SubViewport/SceneSlot.get_child(0).queue_free()

func fail_close():
	close()


func _on_reset_pressed() -> void:
	$AudioStreamPlayer.play()
	reset()
	create_minigame()


func _on_abandon_pressed() -> void:
	close()
	$AudioStreamPlayer.play()
