extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_warning("SATELLITE   ORBIT   UNSTABLE:   DOOMSDAY   IMMINENT")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func show_warning(txt:String):
	$Panel/Label.text = txt
	$Panel/Label.position.x = 640
	var tw = get_tree().create_tween()
	tw.tween_property($Panel/Label, "position:x", -$Panel/Label.size.x, ($Panel/Label.size.x+640)/80)
	tw.play()
