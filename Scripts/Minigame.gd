class_name Minigame extends CanvasItem

signal finished
signal failed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func finish():
	emit_signal("finished")
func fail():
	emit_signal("failed")
