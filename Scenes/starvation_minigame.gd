extends Minigame


var held_item : Area2D = null
var held_old_pos : Vector2
var free_pass := false
var click_buffer := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for a in $Fields.get_children():
		a.connect("input_event", field_input_event.bind(a))
	for a in $Tools.get_children():
		a.connect("input_event", tool_input_event.bind(a))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if held_item:
		held_item.global_position = get_global_mouse_position()
	if held_item and Input.is_action_just_pressed("click") and not free_pass:
		await get_tree().process_frame
		await get_tree().process_frame
		if click_buffer == 0:
			held_item.position = held_old_pos
			held_item.get_child(1).disabled = false
			held_item = null
		else:
			click_buffer -= 1
	free_pass = false
	if $Fields.get_child_count() == 0:
		finish()

func field_input_event(viewport, event: InputEvent, shape_idx, nod:Area2D):
	if held_item and event is InputEventMouseButton and event.pressed:
		if held_item:
			if held_item.name == "Seeds" and nod.get_child(2).frame == 0:
				nod.get_child(2).frame = 1
			if held_item.name == "Water":
				nod.get_child(0).animation = "Wet"
			click_buffer += 1
	elif !held_item and event is InputEventMouseButton and event.pressed:
		if nod.get_child(2).frame == 3:
			nod.queue_free()

func tool_input_event(viewport, event: InputEvent, shape_idx, nod:Area2D):
	if event is InputEventMouseButton and event.pressed:
		if held_item == null and nod.name != "Time":
			held_item = nod
			held_old_pos = nod.position
			free_pass = true
			held_item.get_child(1).disabled = true
		if held_item == null and nod.name == "Time":
			do_time()

func do_time():
	for f : Area2D in $Fields.get_children():
		if f.get_child(0).animation == "Wet" and f.get_child(2).frame > 0:
			f.get_child(2).frame = clamp(f.get_child(2).frame+1, 0, 3)
		f.get_child(0).animation = "Dry"
		
