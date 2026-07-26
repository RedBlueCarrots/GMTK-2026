extends Node2D

@export var events : Dictionary[String, PackedScene]
@export var event_positions : Dictionary[String, Vector2]
@export var event_peristence : Array[String]

const new_event = preload("res://Scenes/event.tscn")
const new_rocket_event = preload("res://Scenes/rocket_event.tscn")
var all_events = []

const rocket_events = [preload("res://Scenes/rocket_draw.tscn"), preload("res://Scenes/cut_minigame.tscn"), preload("res://Scenes/connect_the_wires.tscn"), preload("res://Scenes/launch_codes_minigame.tscn")]
var rocket_events_completed := 0
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


func _on_rocket_timer_timeout() -> void:
	var new_event_scene = new_rocket_event.instantiate()
	new_event_scene.new_scene = rocket_events[rocket_events_completed]
	add_child(new_event_scene)
	new_event_scene.position = Vector2(-140, 140)
	new_event_scene.old_pos = Vector2(-140, 140)
	$CanvasLayer/hud.show_warning("ROCKET   STAGE   "+str(rocket_events_completed+1) + "   IS   READY")
	new_event_scene.connect("done", rocket_done)

func rocket_done():
	rocket_events_completed += 1
	$RocketTimer.start()
	if rocket_events_completed == 4:
		print("game finish")
