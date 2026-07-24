extends Node2D

signal minigame_completed

@export var grid_size: Vector2i = Vector2i(5,5)
@export var sink_count: int = 5

@onready var board: Node2D = $Board

var cell_size: int = 128
var grid: Array = []
var source_position: Vector2i = Vector2i(-1, -1)
var sink_positions: Array[Vector2i] = []
var _game_won: bool = false

const DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT,
]

const PIPE_PIECE_SCENE : PackedScene = preload("res://Scenes/pipe_piece.tscn")


func _ready() -> void:
	generate_board()


func generate_board() -> void:
	_clear_board()
	_game_won = false
	sink_positions.clear()

	for x in range(grid_size.x):
		var column: Array = []
		for y in range(grid_size.y):
			column.append(null)
		grid.append(column)

	# Pick a random source cell
	source_position = _random_cell()

	# Pick sink cells: reachable, not the source, not adjacent to source, prefer far from source
	var candidate_sinks : Array[Vector2i] = _shuffle_cells()
	for cell in candidate_sinks:
		if sink_positions.size() >= sink_count:
			break
		if cell == source_position:
			continue
		# must not be orthogonally adjacent to the source, preventing insta-wins
		if cell.distance_to(source_position) <= 1:
			continue
		# spread them out: require a minimum distance from other sinks and source
		@warning_ignore("integer_division")
		var min_dist : int = grid_size.x / 2
		var far_enough : bool = true
		for placed_sink in sink_positions:
			if cell.distance_to(placed_sink) < min_dist:
				far_enough = false
				break
		if not far_enough:
			continue
		sink_positions.append(cell)

	# Fallback if we didn't get enough sinks (still respecting adjacency rule)
	while sink_positions.size() < sink_count:
		var fallback : Vector2i = _random_cell()
		if fallback == source_position:
			continue
		if fallback.distance_to(source_position) <= 1:
			continue
		if fallback not in sink_positions:
			sink_positions.append(fallback)

	# Build guaranteed solution paths from source to each sink, all sharing the same source-facing direction.
	# occupied_directions[x][y] = set of Vector2i directions used in a solution path
	var occupied_directions: Dictionary = {}
	# desired_facing[x][y] = Vector2i direction the source or sink END should point toward (only relevant for SOURCE/SINK cells)
	var desired_facing: Dictionary = {}
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			occupied_directions[Vector2i(x, y)] = {}

	var first_dir: Vector2i = _pick_shared_source_direction()
	if first_dir == Vector2i.ZERO:
		# Should be impossible on a 5x5 grid, but handle gracefully
		push_warning("No valid shared source direction found")
		return

	desired_facing[source_position] = first_dir
	occupied_directions[source_position][first_dir] = true
	var first_cell: Vector2i = source_position + first_dir
	occupied_directions[first_cell][-first_dir] = true

	# Build paths from the first shared cell to each sink, then prepend the source step.
	# Paths may not pass through other sinks (those are END pieces with a single connection).
	var final_sink_positions: Array[Vector2i] = []
	var sink_paths: Dictionary = {}
	for sink in sink_positions:
		if sink == source_position or sink.distance_to(source_position) <= 1:
			continue
		var blocked: Array[Vector2i] = [source_position]
		for other_sink in sink_positions:
			if other_sink != sink:
				blocked.append(other_sink)
		var path: Array[Vector2i] = _find_path(first_cell, sink, blocked)
		if path.is_empty():
			continue
		# Prepend the source tile so direction reservations match the original shape logic
		var full_path: Array[Vector2i] = [source_position]
		full_path.append_array(path)
		sink_paths[sink] = full_path
		final_sink_positions.append(sink)

	# Refill sinks in case some were unreachable through the shared direction
	while final_sink_positions.size() < sink_count:
		var fallback: Vector2i = _random_cell()
		if fallback == source_position or fallback.distance_to(source_position) <= 1:
			continue
		if fallback in final_sink_positions:
			continue
		var blocked_for_fallback: Array[Vector2i] = [source_position]
		blocked_for_fallback.append_array(final_sink_positions)
		var fallback_path: Array[Vector2i] = _find_path(first_cell, fallback, blocked_for_fallback)
		if fallback_path.is_empty():
			continue
		var full_fallback_path: Array[Vector2i] = [source_position]
		full_fallback_path.append_array(fallback_path)
		sink_paths[fallback] = full_fallback_path
		final_sink_positions.append(fallback)

	sink_positions = final_sink_positions

	for sink in sink_paths:
		var path: Array[Vector2i] = sink_paths[sink]
		if path.size() < 2:
			continue
		for i in range(path.size() - 1):
			var from: Vector2i = path[i]
			var to: Vector2i = path[i + 1]
			var dir: Vector2i = to - from

			if i == path.size() - 2:
				desired_facing[to] = -dir

			occupied_directions[from][dir] = true
			occupied_directions[to][-dir] = true

	# Spawn all pieces
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var cell : Vector2i = Vector2i(x, y)
			var piece: PipePiece = PIPE_PIECE_SCENE.instantiate()
			piece.position = _cell_to_pixel(cell)
			grid[x][y] = piece
			board.add_child(piece)

			piece.piece_rotated.connect(_on_piece_rotated)

			if cell == source_position:
				piece.type = PipePiece.PipeType.SOURCE
				piece.shape = PipePiece.PipeShape.END
				if cell in desired_facing:
					piece.rotation_degrees = _direction_to_degrees(desired_facing[cell])
			elif cell in sink_positions:
				piece.type = PipePiece.PipeType.SINK
				piece.shape = PipePiece.PipeShape.END
				if cell in desired_facing:
					piece.rotation_degrees = _direction_to_degrees(desired_facing[cell])
			else:
				piece.type = PipePiece.PipeType.CONNECTOR
				# Pick a random shape, but if this cell carries solution traffic, prefer one that includes all required dirs
				var required_dirs = occupied_directions[cell].keys()
				piece.shape = _pick_shape_for_directions(required_dirs)
				# Disabled end shapes for connectors by default because they're dead-ends; re-roll if it happens
				while piece.shape == PipePiece.PipeShape.END:
					piece.shape = _pick_shape_for_directions(required_dirs)

			piece.setup_pipe()
			piece.update_connections()
			_scramble_piece(piece)

	# Ensure the pipe directly connected to the source does not start already connected,
	# unless it is a cross (which always connects in all directions by design).
	if source_position in desired_facing:
		var source_dir: Vector2i = desired_facing[source_position]
		var first_step : Vector2i = source_position + source_dir
		if _in_bounds(first_step):
			var first_piece: PipePiece = grid[first_step.x][first_step.y]
			if first_piece.shape != PipePiece.PipeShape.CROSS:
				var reciprocal: Vector2 = Vector2(-source_dir.x, -source_dir.y)
				var safety: int = 0
				while first_piece.has_connection(reciprocal) and safety < 100:
					first_piece.rotation_degrees += 90
					first_piece.update_connections()
					safety += 1

	_update_flow()


func _clear_board() -> void:
	for child in board.get_children():
		child.queue_free()
	grid.clear()


func _random_cell() -> Vector2i:
	return Vector2i(randi() % grid_size.x, randi() % grid_size.y)


func _shuffle_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			cells.append(Vector2i(x, y))
	cells.shuffle()
	return cells


func _cell_to_pixel(cell: Vector2i) -> Vector2:
	var board_width : int = (grid_size.x - 1) * cell_size
	var board_height : int = (grid_size.y - 1) * cell_size
	var offset : Vector2 = Vector2(-board_width / 2.0, -board_height / 2.0)
	return offset + Vector2(cell.x * cell_size, cell.y * cell_size)


func _pick_shared_source_direction() -> Vector2i:
	# Try each cardinal direction from the source and return the first one that
	# can reach all currently selected sinks, without paths crossing other sinks.
	# If none can, return the direction that reaches the most sinks.
	var best_dir: Vector2i = Vector2i.ZERO
	var best_count: int = -1

	var candidate_dirs: Array[Vector2i] = DIRECTIONS.duplicate()
	candidate_dirs.shuffle()

	for dir in candidate_dirs:
		var first_cell: Vector2i = source_position + dir
		if not _in_bounds(first_cell):
			continue
		var reachable_count: int = 0
		for sink in sink_positions:
			if sink == source_position or sink.distance_to(source_position) <= 1:
				continue
			var blocked: Array[Vector2i] = [source_position]
			for other_sink in sink_positions:
				if other_sink != sink:
					blocked.append(other_sink)
			var path: Array[Vector2i] = _find_path(first_cell, sink, blocked)
			if not path.is_empty():
				reachable_count += 1
		if reachable_count == sink_positions.size():
			return dir
		if reachable_count > best_count:
			best_count = reachable_count
			best_dir = dir

	return best_dir


func _find_path(from: Vector2i, to: Vector2i, blocked: Array[Vector2i] = []) -> Array[Vector2i]:
	# Standard BFS to find shortest grid path, never passing through a blocked cell
	var frontier: Array[Vector2i] = [from]
	var blocked_set: Dictionary = {}
	for cell in blocked:
		blocked_set[cell] = true
	var came_from: Dictionary = {}
	var sentinel: Vector2i = Vector2i(-1, -1)
	came_from[from] = sentinel

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		if current == to:
			break
		for dir: Vector2i in DIRECTIONS:
			var next_cell : Vector2i = current + dir
			if not _in_bounds(next_cell):
				continue
			if next_cell in came_from:
				continue
			if next_cell in blocked_set:
				continue
			frontier.append(next_cell)
			came_from[next_cell] = current

	if not (to in came_from):
		return []

	var path: Array[Vector2i] = []
	var cursor: Vector2i = to
	while cursor != sentinel:
		path.append(cursor)
		cursor = came_from[cursor]
	path.reverse()
	return path


func _direction_to_degrees(dir: Vector2i) -> float:
	# END shape's base connection is Vector2.DOWN. Return rotation needed to make it point along dir.
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


func _in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < grid_size.x and cell.y >= 0 and cell.y < grid_size.y


func _pick_shape_for_directions(directions: Array) -> PipePiece.PipeShape:
	var count : int = directions.size()
	match count:
		0:
			# No constraints: random shape, but avoid END for connectors
			var shapes := [
				PipePiece.PipeShape.STRAIGHT,
				PipePiece.PipeShape.BEND,
				PipePiece.PipeShape.T_JUNCTION,
				PipePiece.PipeShape.CROSS,
			]
			return shapes[randi() % shapes.size()]
		1:
			# One required direction: END is the only shape with a single connection
			return PipePiece.PipeShape.END
		2:
			# Two required directions: STRAIGHT and BEND
			if directions[0] == -directions[1]:
				return PipePiece.PipeShape.STRAIGHT
			else:
				return PipePiece.PipeShape.BEND
		3:
			return PipePiece.PipeShape.T_JUNCTION
		4:
			return PipePiece.PipeShape.CROSS
		_:
			return PipePiece.PipeShape.CROSS


func _scramble_piece(piece: PipePiece) -> void:
	if not piece.rotateable:
		return
	var turns := randi() % 4
	for i in range(turns):
		piece.rotation_degrees += 90
		piece.update_connections()


func _on_piece_rotated() -> void:
	if _game_won:
		return
	_update_flow()


func _update_flow() -> void:
	var source_piece: PipePiece = grid[source_position.x][source_position.y]
	var visited: Dictionary = {}
	var frontier: Array[PipePiece] = [source_piece]
	visited[source_piece] = true

	while not frontier.is_empty():
		var current: PipePiece = frontier.pop_front()
		var cell : Vector2i = _pixel_to_cell(current.position)

		for dir_int: Vector2i in DIRECTIONS:
			# Check if the current piece has a connection in this direction
			var world_dir : Vector2 = Vector2(dir_int.x, dir_int.y)
			if not current.has_connection(world_dir):
				continue

			var neighbor_cell : Vector2i = cell + dir_int
			if not _in_bounds(neighbor_cell):
				continue

			var neighbor: PipePiece = grid[neighbor_cell.x][neighbor_cell.y]
			if neighbor in visited:
				continue

			var reciprocal : Vector2 = Vector2(-dir_int.x, -dir_int.y)
			if neighbor.has_connection(reciprocal):
				visited[neighbor] = true
				frontier.append(neighbor)

	# Update visual connected state
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var piece: PipePiece = grid[x][y]
			piece.connected = piece in visited

	# Check for win
	var all_sinks_connected : bool = true
	for sink_cell in sink_positions:
		var sink_piece: PipePiece = grid[sink_cell.x][sink_cell.y]
		if not (sink_piece in visited):
			all_sinks_connected = false
			break

	if all_sinks_connected and not _game_won:
		_game_won = true
		_lock_all_pieces()
		minigame_completed.emit()


func _lock_all_pieces() -> void:
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var piece: PipePiece = grid[x][y]
			if piece:
				piece.rotateable = false


func _pixel_to_cell(pixel: Vector2) -> Vector2i:
	# Board size relative by center of the cells
	var board_width : int = (grid_size.x - 1) * cell_size
	var board_height : int = (grid_size.y - 1) * cell_size

	# Offset: (0,0) grid position
	var offset : Vector2 = Vector2(-board_width / 2.0, -board_height / 2.0)
	var relative : Vector2 = pixel - offset
	return Vector2i(round(relative.x / cell_size), round(relative.y / cell_size))
