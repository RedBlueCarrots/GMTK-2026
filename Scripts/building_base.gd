class_name Building extends Area2D

## Is this building selected?
var hovered:bool = false:
	set(new):
		hovered = new
		set_highlight()

## A tween for building selection
var tween: Tween

func on_click():
	Gamestate.change_countdown(Countdown.Type.ALIENS, 1)
	pass

## sets the building to be highlighted or not dependent on current hovered state
func set_highlight() -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE * (1.2 if hovered else 1.), 1.)

func mouse_entered() -> void:
	hovered = true

func mouse_exited() -> void:
	hovered = false


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_click()
