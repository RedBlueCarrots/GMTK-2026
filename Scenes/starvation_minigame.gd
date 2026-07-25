extends Minigame


var held_item : Area2D = null
var held_old_pos : Vector2
var free_pass := false
var click_buffer := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for a in $Fields.get_children():
		a.connect("input_event", field_input_event.bind(a))
		a.get_node("Timer").connect("timeout", do_time.bind(a))
	for a in $Tools.get_children():
		a.connect("input_event", tool_input_event.bind(a))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
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
			if held_item.name == "Water" and nod.get_child(0).modulate.a == 0.0:
				nod.get_child(0).modulate.a = 0.2
			if nod.get_child(2).frame == 1 and nod.get_child(0).modulate.a != 0.0:
				if !nod.get_node("Timer").paused:
					nod.get_node("Timer").start()
			click_buffer += 1
	elif !held_item and event is InputEventMouseButton and event.pressed:
		if nod.get_child(2).frame == 3:
			nod.queue_free()

func tool_input_event(viewport, event: InputEvent, shape_idx, nod:Area2D):
	if event is InputEventMouseButton and event.pressed:
		if held_item == null:
			held_item = nod
			held_old_pos = nod.position
			free_pass = true
			held_item.get_child(1).disabled = true

func do_time(nod:Area2D):
	if nod.get_child(0).modulate.a != 0.0 and nod.get_child(2).frame > 0:
		nod.get_child(2).frame = clamp(nod.get_child(2).frame+1, 0, 3)
		
