class_name Countdown extends Node

@export var display_name: String = "Un-named Timer"
var time_max: float = 60. ## Maximum amount of time per clock
var time_left: float = 10.
var active: bool = true
signal finished()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !active: pass
	time_left -= delta
	if time_left < 0:
		finish()
		
func finish():
	active = false
	print("%s has finished!" % display_name)
	finished.emit()
