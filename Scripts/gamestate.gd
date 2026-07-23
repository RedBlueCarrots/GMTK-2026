extends Node

var time: float
var countdowns: Array[Countdown] = []

signal new_countdown(ref: Countdown)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta

func add_countdown() -> Countdown:
	var new = Countdown.new()
	add_child(new)
	new_countdown.emit(new)
	return new
