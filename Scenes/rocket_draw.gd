extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$mouse.global_position = get_global_mouse_position()
	if Input.is_action_pressed("click"):
		for a in $mouse.get_overlapping_areas():
			var pos = $Draw.local_to_map(a.position)
			$Draw.set_cell(pos, 0, Vector2i(15, 5))
			a.queue_free()
		get_score()

func get_score():
	var score = 0
	for a in $Draw.get_used_cells_by_id(0):
		if $Target.get_cell_atlas_coords(a) == Vector2i(14, 9):
			score += 5
		else:
			score -= 1
	if score > 400:
		print("done")
	print(score)
