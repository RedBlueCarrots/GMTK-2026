extends Node2D

var old_pos : Vector2
@export var icon := ""
@export var minigame_scene := ""
@export var persistent := false
var is_open = false
@onready var new_scene : PackedScene = load("res://Scenes/"+minigame_scene+".tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	old_pos = position
	$Icon/Sprite2D.texture = load("res://Assets/Art/Icons/" + icon)
	

func create_minigame():
	var minigame : Minigame = new_scene.instantiate()
	$Panel/SubViewportContainer/SubViewport/SceneSlot.add_child(minigame)
	minigame.connect("finished", close_remove)
	minigame.connect("failed", close_remove)
	minigame.connect("closed", close)


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
	print("close")
	is_open = false
	$AnimationPlayer.play("FadeOut")
	var tw = get_tree().create_tween()
	tw.tween_property(self, "position", old_pos, 0.3)
	tw.play()
	if !persistent:
		reset()

func close_remove():
	close()
	reset()
func reset():
	$Panel/SubViewportContainer/SubViewport/SceneSlot.get_child(0).queue_free()

func fail_close():
	close()
