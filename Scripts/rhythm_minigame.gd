extends Minigame
	
var score = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#load chart
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(score)
	if score > 12:
		finish()

func _on_button_pressed() -> void:
	$AudioStreamPlayer.play()	

func _on_conductor_beat(Pos: Variant) -> void:
	pass # Replace with function body.


func _on_note_manager_success() -> void:
	score += 1


func _on_note_manager_miss() -> void:
	score -= 1
