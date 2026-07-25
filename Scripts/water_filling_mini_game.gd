extends Minigame

# Nodes to call in the script
@export var z_key: Node2D
@export var x_key: Node2D
@export var waterlevel: Sprite2D

## @DESIGNERS SEE THESE
const SECONDS_PER_CORRECT: float = 5 ## Seconds of water added per correct key pressed
const SECONDS_PER_INCORRECT: float = 0 ## Seconds of water deducted per incorrect (but possible) key pressed
var seconds_max = 60. ## Maximum seconds of water possible in tank
var seconds_left = 30.0 ## Amount of seconds of water left in tank

# List for the keys mashing
var keys_to_press = ["PressZ", "PressX"]

# Variable to hold which key to press
var press_key

signal correct
signal incorrect

# Function to call the random key selection
func prepare_next_key():
	press_key = randi_range(0, keys_to_press.size() - 1)
	z_key.visible = press_key == 0
	x_key.visible = press_key == 1

func _ready() -> void:
	prepare_next_key()
	correct.connect(correct_keypress)
	incorrect.connect(incorrect_keypress)

func _process(delta: float) -> void:
	# Visual indicators
	var target_position = 59 * (1 - seconds_left/seconds_max)
	waterlevel.position.y = lerp(waterlevel.position.y, target_position, delta * 10)
	seconds_left -= delta
	# Close out if failed/succeeded
	if seconds_left >= seconds_max:
		finish()
	elif seconds_left <= 0:
		fail()
		
func _unhandled_input(event: InputEvent) -> void:
	# Don't process if key is held down
	if event.is_echo(): return
	# Cycle through keys we care about
	for i in keys_to_press.size():
		var success_key = false
		if i == press_key:
			success_key = true
		if event.is_action_pressed(keys_to_press[i]):
			if success_key:
				correct.emit()
			else:
				incorrect.emit()

func correct_keypress():
	prepare_next_key()
	seconds_left = min(seconds_left + SECONDS_PER_CORRECT, seconds_max)

func incorrect_keypress():
	prepare_next_key()
	seconds_left -= SECONDS_PER_INCORRECT
