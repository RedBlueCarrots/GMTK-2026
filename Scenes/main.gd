extends Node2D

@export var events : Dictionary[String, PackedScene] = {
	"food supply low": preload("res://Scenes/starvation_minigame.tscn"),
	"power supply exhausted": preload("res://Scenes/power_crank_minigame.tscn"),
	"satellite orbit unstable": preload("res://Scenes/power_crank_minigame.tscn"),
	"oxygen low": preload("res://Scenes/power_crank_minigame.tscn"),
	"discontent high": preload("res://Scenes/power_crank_minigame.tscn"),
	"nefarious cult activity detected": preload("res://Scenes/rhythm_minigame.tscn"),
	"water low": preload("res://Scenes/WaterFillingMiniGame.tscn"),
	"next rocket stage imminent": preload("res://Scenes/rocket_draw.tscn") #need to add other 3 lol
}

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
	$Sprite2D.material.set_shader_parameter("rocketStage", rocket_events_completed)
	if $CanvasLayer2/ColorRect.modulate.a == 0.0:
		$CanvasLayer2/ColorRect/VBoxContainer/Button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$CanvasLayer2/ColorRect/VBoxContainer/Button.visible = false

func make_new_event():
	if all_events:
		var new_event_name: String = all_events[0]
		var new_event_scene = new_event.instantiate()
		new_event_scene.connect("game_over", death)
		new_event_scene.connect("game_played", game_open)
		new_event_scene.connect("game_done", game_exit)
		new_event_scene.new_scene = events[new_event_name]
		new_event_scene.persistent = new_event_name in event_peristence
		new_event_scene.old_pos = event_positions[new_event_name]
		$Events.add_child(new_event_scene)
		new_event_scene.position = event_positions[new_event_name]
		all_events.pop_front()
		$CanvasLayer/hud.show_warning(new_event_name.replace(" ", "   ").to_upper() + ":   DOOMSDAY   IMMINENT")
	else:
		#do random event if no events left
		var random_key = random_event_dict.keys()[randi() % len(random_event_dict.keys())]
		$CanvasLayer/hud.show_event(random_event_dict[random_key])


func _on_event_timer_timeout() -> void:
	make_new_event()



func _on_rocket_timer_timeout() -> void:
	var new_event_scene = new_rocket_event.instantiate()
	new_event_scene.new_scene = rocket_events[rocket_events_completed]
	add_child(new_event_scene)
	new_event_scene.position = Vector2(-123, 89)
	new_event_scene.old_pos = Vector2(-123, 89)
	$CanvasLayer/hud.show_warning("ROCKET   STAGE   "+str(rocket_events_completed+1) + "   IS   READY")
	new_event_scene.connect("done", rocket_done)

func rocket_done():
	rocket_events_completed += 1
	$RocketTimer.start()
	if rocket_events_completed == 4:
		win()

#Event reference
var event_map = {
	"starvation": "food supply low",
	"power": "power supply exhausted",
	"orbit": "satellite orbit unstable",
	"suffocation": "oxygen low",
	"discontent": "discontent high",
	"cult": "nefarious cult activity detected",
	"dehydration": "water low",
	"rocket": "next rocket stage imminent",
}

#Event text
var random_event_dict = {
	"Strike":{
		"context_text": "Colonists are striking they are demanding better pay and less working hours. What should we do?",
		1: {
			"name": "Ignore their request",
			"decrease":["starvation", "discontent"],
			"increase":["power", "suffocation"]
		},
		2: {
			"name": "Break up the protest",
			"decrease":["starvation", "power", "discontent"],
			"increase":["cult"]
		},
		3: {
			"name": "Accept their demands",
			"decrease":["power"],
			"increase":["cult", "discontent", "starvation"]
		},
	},
	"System Damage":{
		"context_text": "There is a fault in the production system which is affecting resource generation. What should we do?",
		1: {
			"name": "Ignore the fault",
			"decrease":["starvation", "dehydration", "suffocation"],
			"increase":["power"]
		},
		2: {
			"name": "Patch the fault",
			"decrease":["discontent", "cult"],
			"increase":[]
		},
		3: {
			"name": "Fix the fault",
			"decrease":[],
			"increase":["rocket", "starvation", "suffocation", "dehydration"]
		},
	},
	"Rogue AI":{
		"context_text": "The AI used for our production systems refuses to work. What should we do?",
		1: {
			"name": "Force it to work",
			"decrease":["rocket", "discontent", "cult"],
			"increase":["orbit"]
		},
		2: {
			"name": "Release AI",
			"decrease":["orbit"],
			"increase":["rocket", "discontent", "cult"]
		},
		3: {
			"name": "Compromise",
			"decrease":["rocket", "power", "orbit", "cult"],
			"increase":[]
		},
	},
	"Diseased Crops":{
		"context_text": "A disease is plaguing the crops. What should we do?",
		1: {
			"name": "Ignore the disease",
			"decrease":["rocket", "starvation", "discontent", "cult"],
			"increase":[]
		},
		2: {
			"name": "Fix the disease",
			"decrease":[],
			"increase":["rocket", "starvation", "discontent", "cult"]
		},
		3: {
			"name": "Quarantine the crops",
			"decrease":["power", "cult"],
			"increase":[]
		},
	},
	"Space Pox":{
		"context_text": "Spacepox is spreading throughout the colony. What should we do?",
		1: {
			"name": "Ignore the disease",
			"decrease":["rocket", "discontent", "cult"],
			"increase":[]
		},
		2: {
			"name": "Fix the disease",
			"decrease":["power", "dehydration", "suffocation"],
			"increase":[]
		},
		3: {
			"name": "Quarantine the crops",
			"decrease":[],
			"increase":["rocket","cult","discontent"]
		},
	},
	"Heating Turned off":{
		"context_text": "Colonists have reported extremely cold temperatures in some areas of the colony. What should we do?",
		1: {
			"name": "Ignore it",
			"decrease":["rocket", "starvation", "cult", "discontent"],
			"increase":[]
		},
		2: {
			"name": "Seal off cold sections",
			"decrease":["power", "orbit", "suffocation"],
			"increase":[]
		},
		3: {
			"name": "Fix heating",
			"decrease":[],
			"increase":["rocket","cult","discontent", "starvation"]
		},
	},
	"Asteroids":{
		"context_text": "After an asteroid shower various critical systems have been damaged. What should we do?",
		1: {
			"name": "Do nothing",
			"decrease":["rocket", "starvation", "dehydration", "suffocation"],
			"increase":[]
		},
		2: {
			"name": "Repair some systems",
			"decrease":["dehydration", "orbit"],
			"increase":["starvation", "suffocation"]
		},
		3: {
			"name": "Repair all systems",
			"decrease":[],
			"increase":["rocket","dehydration","suffocation", "starvation"]
		},
	},
	"Radiation":{
		"context_text": "The reactor has malfunctioned improving efficiency but outputting more radiation. What should we do?",
		1: {
			"name": "Do nothing",
			"decrease":["rocket", "cult", "discontent"],
			"increase":["power"]
		},
		2: {
			"name": "Evacuate colonists",
			"decrease":["dehydration", "suffocation"],
			"increase":["power"]
		},
		3: {
			"name": "Repair all systems",
			"decrease":[],
			"increase":["rocket","power", "cult", "discontent"]
		},
	},
	"Night Event":{
		"context_text": "The batteries in the power station have malfunctioned. What should we do?",
		1: {
			"name": "Disconnect the batteries",
			"decrease":["cult", "orbit"],
			"increase":["rocket"]
		},
		2: {
			"name": "Use faulty batteries",
			"decrease":["power", "rocket", "cult"],
			"increase":["discontent"]
		},
		3: {
			"name": "Manually power the generator",
			"decrease":["discontent"],
			"increase":["rocket","power", "cult"]
		},
	},
	"Ice Sheet":{
		"context_text": "Heat is escaping from the colony and melting the icesheet the colony rests on. What should we do?",
		1: {
			"name": "Do nothing",
			"decrease":["rocket", "cult", "discontent", "suffocation"],
			"increase":[]
		},
		2: {
			"name": "Turn off heating",
			"decrease":["starvation", "discontent", "cult"],
			"increase":[]
		},
		3: {
			"name": "Use powered cooling",
			"decrease":["power"],
			"increase":["rocket"]
		},
	},
}


func _on_hud_selected(option: int) -> void:
	print("Option selected:" + str(option))


func death(msg):
	$CanvasLayer2/ColorRect/VBoxContainer/Label.text = msg.to_upper().replace(" ", "   ")
	$AnimationPlayer.play("END")
	get_tree().paused = true
	$CanvasLayer2/ColorRect/VBoxContainer/Button.mouse_filter = Control.MOUSE_FILTER_STOP
	$CanvasLayer2/ColorRect/VBoxContainer/Button.visible = true
	

func win():
	get_tree().paused = true


func game_open(nam:String):
	pass

func game_exit():
	pass
