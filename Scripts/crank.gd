extends Node2D

@onready var crank: Node2D = $Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D

var is_dragging: bool = false
var mouse_clicking: bool = false
var turning: bool = false
var turned_amount := 0.0

var dec_rate := 0.0

func _ready():
	dec_rate = randf()*10+5

#checks if the mouse is clicking the handle
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				is_dragging = true
			else:
				is_dragging = false
				mouse_clicking = false
				sprite_2d.reparent(crank)
	var pre_rot = area_2d.rotation
	if is_dragging and mouse_clicking:
		area_2d.look_at(get_global_mouse_position())
		sprite_2d.reparent(area_2d)
		turning = true
		turned_amount += max(0.0, area_2d.rotation-pre_rot)
	else:
		turning = false

func _process(delta: float) -> void:
	if turned_amount < 100:
		turned_amount = clamp(turned_amount-delta*dec_rate, 0.0, 100.0)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				mouse_clicking = true
