class_name Minigame extends CanvasItem

signal finished
signal failed
signal closed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func finish():
	emit_signal("finished")
func fail():
	emit_signal("failed")

func _process(delta: float) -> void:
	#dont look at this
	if get_tree().current_scene != self:
		if Input.is_action_just_pressed("click") and get_parent().get_parent().get_parent().get_parent().offset_transform_scale.x > 0.5:
			var pos  := get_local_mouse_position()
			if pos.x < 0 or pos.x > 192 or pos.y < 0 or pos.y > 192:
				emit_signal("closed")
