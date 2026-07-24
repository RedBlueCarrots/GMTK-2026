extends Node

var time: float
var countdowns: Array[Countdown] = []

signal new_countdown(ref: Countdown)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	add_countdown(Countdown.Type.ALIENS)
	await get_tree().create_timer(15).timeout
	add_countdown(Countdown.Type.FARTS)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta

func add_countdown(type: Countdown.Type) -> Countdown:
	var new = Countdown.new()
	new.type = type
	add_child(new)
	new_countdown.emit(new)
	countdowns.append(new)
	return new

func get_countdown(type:Countdown.Type) -> Countdown:
	for child in countdowns:
		if child.type == type:
			return child
	return null

func change_countdown(type: Countdown.Type, delta: float):
	var obj = get_countdown(type)
	if obj is not Countdown:
		push_warning("Countdown of type %s is not available to change..." % Countdown.Type.keys()[type])
		return
	obj.time_left += delta
