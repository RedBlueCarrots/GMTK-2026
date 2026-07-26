extends Area2D
class_name PipePiece

signal piece_rotated

enum PipeShape {STRAIGHT, BEND, T_JUNCTION, CROSS, END}
enum PipeType {SOURCE, CONNECTOR, SINK}

@export var shape: PipeShape = PipeShape.STRAIGHT
@export var type: PipeType = PipeType.CONNECTOR:
	set(new_value):
		type = new_value
		rotateable = (type == PipeType.CONNECTOR)
		if type == PipeType.SOURCE or type == PipeType.SINK:
			connected = (type == PipeType.SOURCE)

@onready var main_sprite: Sprite2D = $PipeSprite
@onready var fill_sprite: Sprite2D = $FillSprite

# states
var base_connections: Array[Vector2] = []
var current_connections: Array[Vector2] = []
@export var rotateable: bool = true
var connected: bool = false:
	set(new_value):
		connected = new_value
		_update_sprite()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_pipe()
	update_connections()

	# Sources are always considered connected and cannot be rotated
	if type == PipeType.SOURCE or type == PipeType.SINK:
		connected = true if type == PipeType.SOURCE else false
		rotateable = false

	fill_sprite.visible = type == PipeType.SOURCE

# Pipe initialization
func setup_pipe() -> void:
	if not main_sprite:
		return

	match shape:
		PipeShape.STRAIGHT:
			base_connections = [Vector2.UP, Vector2.DOWN]
			main_sprite.texture = preload("res://Assets/Art/Suffocation/pipe-straight.png")
			fill_sprite.texture = preload("res://Assets/Art/Suffocation/pipe_fill-straight.png")

		PipeShape.BEND:
			base_connections = [Vector2.UP, Vector2.RIGHT]
			main_sprite.texture = preload("res://Assets/Art/Suffocation/pipe-bend.png")
			fill_sprite.texture = preload("res://Assets/Art/Suffocation/pipe_fill-bend.png")
			
		PipeShape.T_JUNCTION:
			base_connections = [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
			main_sprite.texture = preload("res://Assets/Art/Suffocation/pipe-t_junction.png")
			fill_sprite.texture = preload("res://Assets/Art/Suffocation/pipe_fill-t_junction.png")

		PipeShape.CROSS:
			base_connections = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
		
		PipeShape.END:
			base_connections = [Vector2.DOWN]
			main_sprite.texture = preload("res://Assets/Art/Suffocation/pipe-end.png")
			fill_sprite.texture = preload("res://Assets/Art/Suffocation/pipe_fill-end.png")

	update_connections()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			rotate_piece()


func rotate_piece() -> void:
	if not rotateable:
		return

	rotation_degrees += 90
	
	# Wrap to prevent overflow
	if rotation_degrees >= 360:
		rotation_degrees -= 360

	update_connections()
	piece_rotated.emit()


func update_connections() -> void:
	current_connections.clear()

	for vector in base_connections:
		var rotated_vec: Vector2 = vector.rotated(rotation)

		# Handle floating point drift with snapped
		var clean_vec: Vector2 = rotated_vec.snapped(Vector2(1, 1))
		
		current_connections.append(clean_vec)


# Check if this pipe has a connection in a specific direction
func has_connection(direction: Vector2) -> bool:
	return direction in current_connections


func _update_sprite() -> void:
	if not fill_sprite:
		return

	if connected:
		fill_sprite.visible=true
	else:
		fill_sprite.visible=false
