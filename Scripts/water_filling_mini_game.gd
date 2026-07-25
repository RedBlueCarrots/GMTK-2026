extends Node2D

# Nodes to call in the script
@onready var water_node = get_node("Game/Water")
@onready var water_fill = get_node("Game/WaterFill")
@onready var key_node = get_node("Game/Key To Press")

# List for the keys mashing
var keys_to_press = ["PressZ", "PressX"]

# Highest point of the water
var water_max = 200

# Variable to hold which key to press
var press_key
var not_press_key

var seconds_left = 30.0

# Function to call the random key selection
func random_key_press():
	press_key = randi_range(0, 1)
	
	if press_key == 1:
		not_press_key = 0
	elif press_key == 0:
		not_press_key = 1

	key_node.text = keys_to_press[press_key][-1]

func _ready() -> void:
	random_key_press()

func _process(delta: float) -> void:
	water_fill.text = str(snapped(seconds_left, 1)) + " Seconds"
	
	seconds_left -= delta
	
	water_node.size.y = seconds_left * 6
	
	if Input.is_action_just_pressed(keys_to_press[press_key]): # Function restarts when key is pressed
		random_key_press()
		
		seconds_left += 4 * 25 * 1.1 * delta
	
	elif Input.is_action_just_pressed(keys_to_press[not_press_key]):
		seconds_left -= 5 * 15 * 1 * delta
	
	if seconds_left >= 60:
		finish()
	elif seconds_left <= 0:
		failed()
