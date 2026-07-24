extends Node2D

var old_pos : Vector2
@export var icon := ""
@export var minigame_scene := ""
var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	old_pos = position
	#$Icon/Sprite2D.texture = load("res://Assets/Art/Icons/" + icon)
	var new_scene : PackedScene = load("res://Scenes/"+minigame_scene+".tscn")
	var minigame : Minigame = new_scene.instantiate()
	$Panel/SubViewportContainer/SubViewport/SceneSlot.add_child(minigame)
	minigame.connect("finished", close)


func _on_icon_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#On click
	if event is InputEventMouseButton and event.pressed and not is_open:
		open()

func open():
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
