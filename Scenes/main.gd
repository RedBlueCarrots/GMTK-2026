extends Node2D

@export var events : Dictionary[String, PackedScene]
@export var event_positions : Dictionary[String, Vector2]
@export var event_peristence : Array[String]

const new_event = preload("res://Scenes/event.tscn")

var all_events = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	all_events = events.keys()
	all_events.shuffle()
	make_new_event()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func make_new_event():
	if all_events:
		var new_event_name: String = all_events[0]
		var new_event_scene = new_event.instantiate()
		new_event_scene.new_scene = events[new_event_name]
		new_event_scene.persistent = new_event_name in event_peristence
		new_event_scene.old_pos = event_positions[new_event_name]
		$Events.add_child(new_event_scene)
		new_event_scene.position = event_positions[new_event_name]
		all_events.pop_front()
		$CanvasLayer/hud.show_warning(new_event_name.replace(" ", "   ").to_upper() + ":   DOOMSDAY   IMMINENT")


func _on_event_timer_timeout() -> void:
	make_new_event()
