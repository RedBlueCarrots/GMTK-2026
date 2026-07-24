class_name Countdown extends Node

enum Type {ALIENS, FARTS}

var type: Type:
	set(new):
		type = new
		set_defaults()
var display_name: String = "Un-named Timer"
var time_max: float = 60. ## Maximum amount of time per clock - used primarily for angle display, doesn't cap actual time
var time_left: float = 10. ## Current amount of time
var active: bool = true

signal finished()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func set_defaults():
	match type:
		Type.ALIENS:
			display_name = "Alien Invasion"
			time_max = 10
			time_left = 10
		Type.FARTS:
			display_name = "Fart bomb or something idk"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !active: return
	time_left -= delta
	if time_left < 0:
		finish()
		
func finish():
	active = false
	print("%s has finished!" % display_name)
	finished.emit()
