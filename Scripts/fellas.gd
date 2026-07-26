extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scale.x = move_toward(scale.x, 2, 2 * delta)
	scale.y = move_toward(scale.y, 2, 2 * delta)

func _on_button_pressed() -> void:
	scale = Vector2(2, 1.3)


func _on_texture_button_pressed() -> void:
	scale = Vector2(2, 1.3)
