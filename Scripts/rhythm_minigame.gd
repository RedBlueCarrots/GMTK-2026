extends Minigame
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#load chart
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $NoteManager.score > 4:
		finish()

func _on_button_pressed() -> void:
	$AudioStreamPlayer.play()	

func _on_conductor_beat(Pos: Variant) -> void:
	pass # Replace with function body.
