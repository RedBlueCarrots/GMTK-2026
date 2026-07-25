extends Minigame

# Constants
const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
const PIPE_PIECE_SCENE: PackedScene = preload("res://Scenes/pipe_piece.tscn")
const board_size: Vector2i = Vector2i(11, 11) # also includes cell for source and sink
var board_range: Array = range(1, board_size.x-1)

# exports and onready
@export var t_juction_spawn_rate: float = 0.25

@onready var board: Node2D = $Board

# configs
var cell_size: float = 38.4
var source_position: Vector2i = Vector2i(0, ceil((board_size.y as float)/2))
var source_direction: Vector2i = Vector2i.RIGHT
var sink_position: Vector2i = Vector2i(board_size.x-1, ceil((board_size.y as float)/2))
var sink_direction: Vector2i = Vector2i.LEFT

# states
var grid:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_board()

# generate board function
'''
1. reset board: clean board/grid, game_won false
2. grid initialization: resize columns with nulls
3. random_walk path generation
4. instantiate pipes: also set positions, cell to pixel
5. randomize pipe rotation with no connection on first pipe
6. first pipe disconnection
7. update flow
'''
func generate_board() -> void:
	grid.clear()

	for row in range(board_size.x):
		var column: Array = []
		column.resize(board_size.y)
		column.fill(null)
		grid.append(column)
		
	var path: Array[Vector2i] = _random_walk(source_position, sink_position)

	for x in board_range:
		for y in board_range:
			var cell: Vector2i = Vector2i(x,y)
			var piece: PipePiece = PIPE_PIECE_SCENE.instantiate()
			board.add_child(piece)
			piece.position = _cell_to_pixel(cell)
			piece.piece_rotated.connect(_update_flow)
			piece.type = PipePiece.PipeType.CONNECTOR
			if cell in path:
				piece.shape = _generate_shape(true, _is_straight(cell, path))
			else:
				piece.shape = _generate_shape()
			piece.rotation_degrees = [0, 90, 180, 270].pick_random()
			piece.setup_pipe()
			grid[x][y] = piece

	var source_piece: PipePiece = PIPE_PIECE_SCENE.instantiate()
	board.add_child(source_piece)
	source_piece.position = _cell_to_pixel(source_position)
	source_piece.type = PipePiece.PipeType.SOURCE
	source_piece.shape = PipePiece.PipeShape.END
	source_piece.rotation_degrees = _end_direction_to_degrees(source_direction)
	source_piece.setup_pipe()
	grid[source_position.x][source_position.y] = source_piece

	var sink_piece: PipePiece = PIPE_PIECE_SCENE.instantiate()
	board.add_child(sink_piece)
	sink_piece.position = _cell_to_pixel(sink_position)
	sink_piece.type = PipePiece.PipeType.SINK
	sink_piece.shape = PipePiece.PipeShape.END
	sink_piece.rotation_degrees = _end_direction_to_degrees(source_direction)
	sink_piece.setup_pipe()
	grid[sink_position.x][sink_position.y] = sink_piece

	for dir: Vector2i in DIRECTIONS:
		if source_piece.has_connection(Vector2(dir.x, dir.y)):
			var first_step: Vector2i = source_position + dir
			if _in_bounds(first_step):
				var first_piece: PipePiece = grid[first_step.x][first_step.y]
				var reciprocal: Vector2 = Vector2(-dir.x, -dir.y)
				for i in range(4):
					if not first_piece.has_connection(reciprocal):
						break
					first_piece.rotation_degrees += 90
					first_piece.update_connections()

	_update_flow()


# Random walk (technically randomized DFS)
'''
input source, sink
output path (includes source and sink)
dfs but with random next child
'''
func _random_walk(source: Vector2i, sink: Vector2i) -> Array[Vector2i]:
	var stack: Array[Vector2i] = [source]
	var visited: Dictionary = {}
	var path: Array[Vector2i] = []

	while stack:
		var current: Vector2i = stack.pop_back()
		var shuffled_dirs: Array[Vector2i] = DIRECTIONS.duplicate()
		shuffled_dirs.shuffle()

		for direction in shuffled_dirs:
			var next: Vector2i = current + direction
			if _in_bounds(next) and next not in visited:
				stack.append(next)
				visited[next] = true
				
			elif next == sink:
				stack.append(next)
				break
		
		path.append(current)

		if current == sink:
			return path

	return []


func _in_bounds(coor: Vector2i) -> bool:
	return 1 <= coor.x and coor.x < board_size.x-1 and 1 <= coor.y and coor.y < board_size.y-1


func _cell_to_pixel(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * cell_size, cell.y * cell_size)


func _generate_shape(connection: bool = false, straight: bool = true) -> PipePiece.PipeShape:
	var rng = RandomNumberGenerator.new()
	if connection:
		var rolled_index: int = rng.rand_weighted(PackedFloat32Array([1-t_juction_spawn_rate, t_juction_spawn_rate]))
		if straight:
			return [PipePiece.PipeShape.STRAIGHT, PipePiece.PipeShape.T_JUNCTION][rolled_index]
		else:
			return [PipePiece.PipeShape.BEND, PipePiece.PipeShape.T_JUNCTION][rolled_index]
	else:
		var rolled_index: int = rng.rand_weighted(PackedFloat32Array([1-t_juction_spawn_rate/2, 1-t_juction_spawn_rate/2, t_juction_spawn_rate]))
		return [PipePiece.PipeShape.STRAIGHT, PipePiece.PipeShape.BEND, PipePiece.PipeShape.T_JUNCTION][rolled_index]


func _is_straight(cell: Vector2i, path: Array) -> bool:
	var idx = path.find(cell)
	
	if idx == -1: return false

	return path[idx-1].x == path[idx+1].x or path[idx-1].y == path[idx+1].y


# End shaped base direction points down
func _end_direction_to_degrees(dir: Vector2i) -> float:
	match dir:
		Vector2i.DOWN:
			return 0.0
		Vector2i.LEFT:
			return 90.0
		Vector2i.UP:
			return 180.0
		Vector2i.RIGHT:
			return 270.0
		_:
			return 0.0


# update flow
'''
bfs/dfs while updating connected
if sink connected:
	lock all rotation
	game ends
'''
func _update_flow() -> void:
	var source: PipePiece = grid[source_position.x][source_position.y]
	var stack: Array = [source]
	var visited: Dictionary = {}

	while stack:
		var current: PipePiece = stack.pop_back()
		var cell: Vector2i = _pixel_to_cell(current.position)

		for dir_int in DIRECTIONS:
			var dir: Vector2 = Vector2(dir_int.x, dir_int.y)
			if not current.has_connection(dir):
				continue
			
			var next_cell: Vector2i = cell + dir_int
			if not _in_bounds(next_cell) or next_cell != sink_position:
				continue
			
			var next: PipePiece = grid[next_cell.x][next_cell.y]
			if next in visited:
				continue
			
			var reciprocal: Vector2 = Vector2(-dir_int.x, -dir_int.y)
			if next.has_connection(reciprocal):
				stack.append(next)
				visited[next_cell] = true

	for x in board_range:
		for y in board_range:
			grid[x][y].connected = Vector2i(x, y) in visited

	var sink = grid[sink_position.x][sink_position.y]

	if sink.connected == true:
		_lock_all_pipes()
		finish()


func _pixel_to_cell(pixel: Vector2) -> Vector2i:
	return Vector2i(round(pixel.x / cell_size), round(pixel.y / cell_size))

func _lock_all_pipes() -> void:
	for x in board_range:
		for y in board_range:
			grid[x][y].rotateable = false
