extends Minigame

@export var code_length = 5
@export var codes_remaining = 3
@export var max_tries = 1

var tries = 0
var code = ""

const characters = "abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()[]|\\></?`~\'\".,+=-"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%input.max_length = code_length
	%input.call_deferred("grab_focus")
	update_remaining()
	reset_code()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_input_text_changed(new_text: String) -> void:
	%code.visible = new_text==""
	if len(%input.text) >= code_length:
		if %input.text == code:
			codes_remaining -= 1
			$AudioStreamPlayer.play()
			update_remaining()
			if codes_remaining < 1:
				finish()
			else:
				reset_code()
		else:
			tries += 1
			update_errors()
			if max_tries <= tries:
				finish()
			else:
				reset_code()

func reset_code():
	%input.text = ""
	code = _generate_code()
	%code.text = code
	%code.show()

func update_remaining():
	%remaining.text = "Codes: " + str(codes_remaining)

func update_errors():
	tries = min(max_tries, tries)
	%errors.text = "X".repeat(tries)

func _generate_code():
	var new_code = ""
	
	for i in range(code_length):
		new_code += characters[randi() % characters.length()]
	
	return new_code


func _on_timer_timeout() -> void:
	#%code.hide()
	pass
