extends Minigame
var death_message = "The space cult overthrew you..."
var score = 0
var type = "cult"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#load chart
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if score >= 6:
		finish()
	if !%Conductor.playing:
		fail()

func _on_conductor_beat(Pos: Variant) -> void:
	pass # Replace with function body.

func _on_note_manager_success() -> void:
	score += 1

func _on_note_manager_miss() -> void:
	score -= 1

func _on_texture_button_pressed() -> void:
	$SFX.play()	
