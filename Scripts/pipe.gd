extends Area2D
class_name PipePiece

enum PipeShape {STRAIGHT, BEND, T_JUNCTION, CROSS, END}
enum PipeType {SOURCE, CONNECTOR, SINK}

@export var current_shape: PipeShape = PipeShape.STRAIGHT
@export var current_type: PipeType = PipeType.CONNECTOR

@onready var main_sprite: Sprite2D = $PipeSprite
@onready var highlight_sprite: Sprite2D = $HighlightSprite
@onready var source_badge: Sprite2D = $SourceBadgeSprite

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
	if current_type == PipeType.SOURCE or current_type == PipeType.SINK:
		connected = true if current_type == PipeType.SOURCE else false
		rotateable = false

	highlight_sprite.visible = false
	source_badge.visible = true if current_type == PipeType.SOURCE else false


func _on_mouse_entered() -> void:
	if highlight_sprite:
		highlight_sprite.visible = true


func _on_mouse_exited() -> void:
	if highlight_sprite:
		highlight_sprite.visible = false


# Pipe initialization
func setup_pipe() -> void:
	match current_shape:
		PipeShape.STRAIGHT:
			base_connections = [Vector2.UP, Vector2.DOWN]
			main_sprite.texture = preload("res://Assets/Art/pipe-straight.svg")

		PipeShape.BEND:
			base_connections = [Vector2.UP, Vector2.RIGHT]
			main_sprite.texture = preload("res://Assets/Art/pipe-bend.svg")
			
		PipeShape.T_JUNCTION:
			base_connections = [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
			main_sprite.texture = preload("res://Assets/Art/pipe-t_junction.svg")

		PipeShape.CROSS:
			base_connections = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
			main_sprite.texture = preload("res://Assets/Art/pipe-cross.svg")
		
		PipeShape.END:
			base_connections = [Vector2.DOWN]
			main_sprite.texture = preload("res://Assets/Art/pipe-end.svg")


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

	# will emit a custom signal for the board to check the board state


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
	if not main_sprite:
		return

	if connected:
		main_sprite.modulate = Color.LIGHT_BLUE
	else:
		main_sprite.modulate = Color.WHITE
