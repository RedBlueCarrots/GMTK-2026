extends Minigame


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$mouse.global_position = get_global_mouse_position()
	if Input.is_action_pressed("click"):
		for a in $mouse.get_overlapping_areas():
			var pos = $Draw.local_to_map(a.position)
			$Draw.set_cell(pos, 0, Vector2i(49, 60))
			a.queue_free()
		get_score()
		if $AudioStreamPlayer.playing == false:
			$AudioStreamPlayer.play()
	else:
		$AudioStreamPlayer.stop()

func get_score():
	var score = 0
	var target_count = 0
	for a in $Draw.get_used_cells_by_id(0):
		if $Target.get_cell_atlas_coords(a) == Vector2i(49, 60):
			score += 5
			target_count += 1
		else:
			score -= 1
	printt(score, target_count*1.0/$Target.get_used_cells().size())
	if score > 1150 and target_count*1.0/$Target.get_used_cells().size() > 0.89:
		finish()
