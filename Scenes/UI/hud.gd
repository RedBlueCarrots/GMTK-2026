extends Control

signal selected(option:int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func show_warning(txt:String):
	$Panel/Label.text = txt
	$Panel/Label.position.x = 640
	var tw = get_tree().create_tween()
	tw.tween_property($Panel/Label, "position:x", -$Panel/Label.size.x, ($Panel/Label.size.x+640)/80)
	tw.play()

# mutator for random events
func show_event(event: Dictionary):
	%eventText.text = event["context_text"]
	%Option1.text = event[1]["name"]
	%Option1.tooltip_text = tooltip_gen(event[1])
	%Option2.text = event[2]["name"]
	%Option2.tooltip_text = tooltip_gen(event[2])
	%Option3.text = event[3]["name"]
	%Option3.tooltip_text = tooltip_gen(event[3])
	
	%RandomEvent.show()

func tooltip_gen(option: Dictionary):
	var tip: String = ""
	if len(option["increase"]) > 0:
		tip += "Increases:\n"
		
		for effect in option["increase"]:
			tip += "- " + effect
			tip += "\n"
		
	if len(option["decrease"]) > 0:
		tip += "Decreases:\n"
		
		for effect in option["decrease"]:
			tip += "- " + effect
			tip += "\n"
	
	return tip

# signals for main to register changes.
func _on_option_1_pressed() -> void:
	selected.emit(1)
	%RandomEvent.hide()


func _on_option_2_pressed() -> void:
	selected.emit(2)
	%RandomEvent.hide()


func _on_option_3_pressed() -> void:
	selected.emit(3)
	%RandomEvent.hide()
