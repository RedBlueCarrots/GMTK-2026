extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scale.x = move_toward(scale.x, 2, 0.5 * delta)
	scale.y = move_toward(scale.y, 2, 0.5 * delta)

func _on_conductor_beat(Pos: Variant) -> void:
	scale = Vector2(2, 1.5)
