extends Node2D

signal minigame_completed

@export var grid_size: Vector2i = Vector2i(5, 5)
@export var sink_count: int = 5
@export_file("*.json") var level_data: String = ""

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

const PIPE_PIECE_SCENE: PackedScene = preload("res://Scenes/pipe_piece.tscn")


func _ready() -> void:
	start_minigame()


func start_minigame() -> void:
	var config: Dictionary = _load_config()
	if config.is_empty():
		config = _generate_random_config()
	_build_board_from_config(config)


func _load_config() -> Dictionary:
	if level_data.is_empty():
		return {}

	var file: FileAccess = FileAccess.open(level_data, FileAccess.READ)
	if not file:
		push_warning("Could not open level data: %s" % level_data)
		return {}

	var json: JSON = JSON.new()
	var parse_err: Error = json.parse(file.get_as_text())
	if parse_err != OK:
		push_warning("Failed to parse level data JSON: %s at line %d" % [json.get_error_message(), json.get_error_line()])
		return {}

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("Level data must be a JSON object")
		return {}

	if not _validate_config(data):
		return {}

	return data


func _validate_config(config: Dictionary) -> bool:
	var grid_array: Array = config.get("grid_size", [2, 2])
	if grid_array.size() < 2:
		push_warning("grid_size must be an array of two integers")
		return false
	var gx: int = int(grid_array[0])
	var gy: int = int(grid_array[1])
	if gx < 2 or gy < 2:
		push_warning("grid_size must be at least 2x2")
		return false

	var source_array: Array = config.get("source", [-1, -1])
	if source_array.size() < 2:
		push_warning("source must be an array of two integers")
		return false
	var sx: int = int(source_array[0])
	var sy: int = int(source_array[1])
	if sx < 0 or sx >= gx or sy < 0 or sy >= gy:
		push_warning("source position is out of bounds")
		return false

	var sinks_array: Array = config.get("sinks", [])
	if sinks_array.is_empty():
		push_warning("At least one sink is required")
		return false
	for sink in sinks_array:
		var s: Array = sink as Array
		if s.size() < 2:
			push_warning("Each sink must be an array of two integers")
			return false
		var x: int = int(s[0])
		var y: int = int(s[1])
		if x < 0 or x >= gx or y < 0 or y >= gy:
			push_warning("sink position is out of bounds")
			return false
		if x == sx and y == sy:
			push_warning("sink cannot be the same as source")
			return false

	var pieces_array: Array = config.get("pieces", [])
	for piece in pieces_array:
		var p: Dictionary = piece as Dictionary
		if not p.has_all(["x", "y", "type", "shape"]):
			push_warning("Each piece must have 'x', 'y', 'type', and 'shape' keys")
			return false
		var px: int = int(p["x"])
		var py: int = int(p["y"])
		if px < 0 or px >= gx or py < 0 or py >= gy:
			push_warning("piece position out of bounds: %s" % str(p))
			return false

	return true


func _generate_random_config() -> Dictionary:
	var config: Dictionary = {
		"grid_size": [grid_size.x, grid_size.y],
		"source": [-1, -1],
		"sinks": [],
		"pieces": [],
	}

	var candidate_sinks: Array[Vector2i] = _shuffle_cells()
	var chosen_source: Vector2i = _random_cell()
	config["source"] = [chosen_source.x, chosen_source.y]

	# Pick sink cells: not the source, not adjacent to source, prefer far apart
	var chosen_sinks: Array[Vector2i] = []
	for cell in candidate_sinks:
		if chosen_sinks.size() >= sink_count:
			break
		if cell == chosen_source:
			continue
		if cell.distance_to(chosen_source) <= 1:
			continue
		@warning_ignore("integer_division")
		var min_dist: int = grid_size.x / 2
		var far_enough: bool = true
		for placed in chosen_sinks:
			if cell.distance_to(placed) < min_dist:
				far_enough = false
				break
		if not far_enough:
			continue
		chosen_sinks.append(cell)

	while chosen_sinks.size() < sink_count:
		var fallback: Vector2i = _random_cell()
		if fallback == chosen_source or fallback.distance_to(chosen_source) <= 1:
			continue
		if fallback not in chosen_sinks:
			chosen_sinks.append(fallback)

	for sink in chosen_sinks:
		config["sinks"].append([sink.x, sink.y])

	# Ensure guaranteed solution paths
	var first_dir: Vector2i = _pick_shared_source_direction(chosen_source, chosen_sinks)
	if first_dir == Vector2i.ZERO:
		push_warning("No valid shared source direction found")
		return config

	var occupied_directions: Dictionary = {}
	var desired_facing: Dictionary = {}
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			occupied_directions[Vector2i(x, y)] = {}

	desired_facing[chosen_source] = first_dir
	occupied_directions[chosen_source][first_dir] = true
	var first_cell: Vector2i = chosen_source + first_dir
	occupied_directions[first_cell][-first_dir] = true

	var final_sinks: Array[Vector2i] = []
	var sink_paths: Dictionary = {}
	for sink in chosen_sinks:
		if sink == chosen_source or sink.distance_to(chosen_source) <= 1:
			continue
		var blocked: Array[Vector2i] = [chosen_source]
		for other_sink in chosen_sinks:
			if other_sink != sink:
				blocked.append(other_sink)
		var path: Array[Vector2i] = _find_path(first_cell, sink, blocked)
		if path.is_empty():
			continue
		var full_path: Array[Vector2i] = [chosen_source]
		full_path.append_array(path)
		sink_paths[sink] = full_path
		final_sinks.append(sink)

	while final_sinks.size() < sink_count:
		var fallback: Vector2i = _random_cell()
		if fallback == chosen_source or fallback.distance_to(chosen_source) <= 1:
			continue
		if fallback in final_sinks:
			continue
		var blocked: Array[Vector2i] = [chosen_source]
		blocked.append_array(final_sinks)
		var path: Array[Vector2i] = _find_path(first_cell, fallback, blocked)
		if path.is_empty():
			continue
		var full_path: Array[Vector2i] = [chosen_source]
		full_path.append_array(path)
		sink_paths[fallback] = full_path
		final_sinks.append(fallback)

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

	# Build piece list
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var cell: Vector2i = Vector2i(x, y)
			var piece_data: Dictionary = {"x": x, "y": y, "rotation": 0}
			if cell == chosen_source:
				piece_data["type"] = "source"
				piece_data["shape"] = "end"
				if cell in desired_facing:
					piece_data["rotation"] = int(_direction_to_degrees(desired_facing[cell]))
			elif cell in final_sinks:
				piece_data["type"] = "sink"
				piece_data["shape"] = "end"
				if cell in desired_facing:
					piece_data["rotation"] = int(_direction_to_degrees(desired_facing[cell]))
			else:
				piece_data["type"] = "connector"
				var required_dirs = occupied_directions[cell].keys()
				piece_data["shape"] = _shape_name_from_enum(_pick_shape_for_directions(required_dirs))
				# Re-roll if we accidentally got an end shape on a connector
				while piece_data["shape"] == "end":
					piece_data["shape"] = _shape_name_from_enum(_pick_shape_for_directions(required_dirs))
			config["pieces"].append(piece_data)

	return config


func _build_board_from_config(config: Dictionary) -> void:
	_clear_board()
	_game_won = false
	sink_positions.clear()

	var grid_array: Array = config["grid_size"]
	grid_size = Vector2i(int(grid_array[0]), int(grid_array[1]))

	var source_array: Array = config["source"]
	source_position = Vector2i(int(source_array[0]), int(source_array[1]))

	for sink in config["sinks"]:
		var s: Array = sink as Array
		sink_positions.append(Vector2i(int(s[0]), int(s[1])))

	for x in range(grid_size.x):
		var column: Array = []
		column.resize(grid_size.y)
		column.fill(null)
		grid.append(column)

	var pieces_by_cell: Dictionary = {}
	var pieces_array: Array = config.get("pieces", [])
	for piece_data in pieces_array:
		var p: Dictionary = piece_data as Dictionary
		var cell: Vector2i = Vector2i(int(p["x"]), int(p["y"]))
		var piece: PipePiece = PIPE_PIECE_SCENE.instantiate()
		piece.position = _cell_to_pixel(cell)
		piece.piece_rotated.connect(_on_piece_rotated)

		piece.type = _parse_type(p["type"])
		piece.shape = _parse_shape(p["shape"])
		piece.rotation_degrees = float(p.get("rotation", 0))

		piece.setup_pipe()
		piece.update_connections()

		grid[cell.x][cell.y] = piece
		board.add_child(piece)
		pieces_by_cell[cell] = piece

	# For random mode, scramble connector pieces
	if level_data.is_empty():
		for x in range(grid_size.x):
			for y in range(grid_size.y):
				var piece: PipePiece = grid[x][y]
				if piece.type == PipePiece.PipeType.CONNECTOR:
					_scramble_piece(piece)

	# Ensure the pipe directly connected to the source does not start already connected,
	# unless it is a cross (which always connects in all directions by design).
	# In authored JSON mode we trust the data, so only apply in random mode.
	if level_data.is_empty() and source_position in pieces_by_cell:
		var source_piece: PipePiece = pieces_by_cell[source_position]
		for dir: Vector2i in DIRECTIONS:
			if source_piece.has_connection(Vector2(dir.x, dir.y)):
				var first_step: Vector2i = source_position + dir
				if _in_bounds(first_step):
					var first_piece: PipePiece = grid[first_step.x][first_step.y]
					if first_piece.shape != PipePiece.PipeShape.CROSS:
						var reciprocal: Vector2 = Vector2(-dir.x, -dir.y)
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
	var board_width: int = (grid_size.x - 1) * cell_size
	var board_height: int = (grid_size.y - 1) * cell_size
	var offset: Vector2 = Vector2(-board_width / 2.0, -board_height / 2.0)
	return offset + Vector2(cell.x * cell_size, cell.y * cell_size)


func _pick_shared_source_direction(from_source: Vector2i, sinks: Array[Vector2i]) -> Vector2i:
	var best_dir: Vector2i = Vector2i.ZERO
	var best_count: int = -1

	var candidate_dirs: Array[Vector2i] = DIRECTIONS.duplicate()
	candidate_dirs.shuffle()

	for dir in candidate_dirs:
		var first_cell: Vector2i = from_source + dir
		if not _in_bounds(first_cell):
			continue
		var reachable_count: int = 0
		for sink in sinks:
			if sink == from_source or sink.distance_to(from_source) <= 1:
				continue
			var blocked: Array[Vector2i] = [from_source]
			for other_sink in sinks:
				if other_sink != sink:
					blocked.append(other_sink)
			var path: Array[Vector2i] = _find_path(first_cell, sink, blocked)
			if not path.is_empty():
				reachable_count += 1
		if reachable_count == sinks.size():
			return dir
		if reachable_count > best_count:
			best_count = reachable_count
			best_dir = dir

	return best_dir


func _find_path(from: Vector2i, to: Vector2i, blocked: Array[Vector2i] = []) -> Array[Vector2i]:
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
			var next_cell: Vector2i = current + dir
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


func _shape_name_from_enum(shape: PipePiece.PipeShape) -> String:
	match shape:
		PipePiece.PipeShape.STRAIGHT:
			return "straight"
		PipePiece.PipeShape.BEND:
			return "bend"
		PipePiece.PipeShape.T_JUNCTION:
			return "t_junction"
		PipePiece.PipeShape.CROSS:
			return "cross"
		PipePiece.PipeShape.END:
			return "end"
		_:
			return "straight"


func _parse_shape(shape: String) -> PipePiece.PipeShape:
	match shape.to_lower():
		"straight":
			return PipePiece.PipeShape.STRAIGHT
		"bend":
			return PipePiece.PipeShape.BEND
		"t_junction":
			return PipePiece.PipeShape.T_JUNCTION
		"cross":
			return PipePiece.PipeShape.CROSS
		"end":
			return PipePiece.PipeShape.END
		_:
			push_warning("Unknown pipe shape: %s" % name)
			return PipePiece.PipeShape.STRAIGHT


func _parse_type(type: String) -> PipePiece.PipeType:
	match type.to_lower():
		"source":
			return PipePiece.PipeType.SOURCE
		"sink":
			return PipePiece.PipeType.SINK
		"connector":
			return PipePiece.PipeType.CONNECTOR
		_:
			push_warning("Unknown pipe type: %s" % name)
			return PipePiece.PipeType.CONNECTOR


func _pick_shape_for_directions(directions: Array) -> PipePiece.PipeShape:
	var count: int = directions.size()
	match count:
		0:
			var shapes := [
				PipePiece.PipeShape.STRAIGHT,
				PipePiece.PipeShape.BEND,
				PipePiece.PipeShape.T_JUNCTION,
				PipePiece.PipeShape.CROSS,
			]
			return shapes[randi() % shapes.size()]
		1:
			return PipePiece.PipeShape.END
		2:
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
	var turns: int = randi() % 4
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
		var cell: Vector2i = _pixel_to_cell(current.position)

		for dir_int: Vector2i in DIRECTIONS:
			var world_dir: Vector2 = Vector2(dir_int.x, dir_int.y)
			if not current.has_connection(world_dir):
				continue

			var neighbor_cell: Vector2i = cell + dir_int
			if not _in_bounds(neighbor_cell):
				continue

			var neighbor: PipePiece = grid[neighbor_cell.x][neighbor_cell.y]
			if neighbor in visited:
				continue

			var reciprocal: Vector2 = Vector2(-dir_int.x, -dir_int.y)
			if neighbor.has_connection(reciprocal):
				visited[neighbor] = true
				frontier.append(neighbor)

	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var piece: PipePiece = grid[x][y]
			piece.connected = piece in visited

	var all_sinks_connected: bool = true
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
	var board_width: int = (grid_size.x - 1) * cell_size
	var board_height: int = (grid_size.y - 1) * cell_size
	var offset: Vector2 = Vector2(-board_width / 2.0, -board_height / 2.0)
	var relative: Vector2 = pixel - offset
	return Vector2i(round(relative.x / cell_size), round(relative.y / cell_size))
