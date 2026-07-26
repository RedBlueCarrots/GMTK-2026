extends Minigame

var dragging_red := false
var red_over_target := false
var red_connected := false

var dragging_blue := false
var blue_over_target := false
var blue_connected := false

var dragging_green := false
var green_over_target := false
var green_connected := false

var dragging_yellow := false
var yellow_over_target := false
var yellow_connected := false

func _process(_delta: float) -> void:
	if dragging_red:
		$Offset/WireLines/RedLine.clear_points()

		$Offset/WireLines/RedLine.add_point(
			$Offset/WireLines/RedLine.to_local(
				$Offset/WireStarts/RedStart/Wiretip.global_position
			)
		)

		$Offset/WireLines/RedLine.add_point(
			$Offset/WireLines/RedLine.get_local_mouse_position()
		)
	if dragging_blue:
		$Offset/WireLines/BlueLine.clear_points()

		$Offset/WireLines/BlueLine.add_point(
			$Offset/WireLines/BlueLine.to_local(
				$Offset/WireStarts/BlueStart/Wiretip.global_position
			)
		)

		$Offset/WireLines/BlueLine.add_point(
			$Offset/WireLines/BlueLine.get_local_mouse_position()
		)
	if dragging_green:
		$Offset/WireLines/GreenLine.clear_points()

		$Offset/WireLines/GreenLine.add_point(
			$Offset/WireLines/GreenLine.to_local(
				$Offset/WireStarts/GreenStart/Wiretip.global_position
			)
		)

		$Offset/WireLines/GreenLine.add_point(
			$Offset/WireLines/GreenLine.get_local_mouse_position()
		)
	if dragging_yellow:
		$Offset/WireLines/YellowLine.clear_points()

		$Offset/WireLines/YellowLine.add_point(
			$Offset/WireLines/YellowLine.to_local(
				$Offset/WireStarts/YellowStart/Wiretip.global_position
			)
		)

		$Offset/WireLines/YellowLine.add_point(
			$Offset/WireLines/YellowLine.get_local_mouse_position()
		)

func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and not event.pressed
	):
		if dragging_red:
			dragging_red = false

			if red_over_target:
				red_connected = true
				$Offset/WireLines/RedLine.clear_points()

				$Offset/WireLines/RedLine.add_point(
					$Offset/WireLines/RedLine.to_local(
						$Offset/WireStarts/RedStart/Wiretip.global_position
					)
				)

				$Offset/WireLines/RedLine.add_point(
					$Offset/WireLines/RedLine.to_local(
						$Offset/WireEnds/RedEnd/Wiretip.global_position
					)
				)
				
				check_completion()
			else:
				$Offset/WireLines/RedLine.visible = false
				$Offset/WireLines/RedLine.clear_points()


		elif dragging_blue:
			dragging_blue = false

			if blue_over_target:
				blue_connected = true
				$Offset/WireLines/BlueLine.clear_points()

				$Offset/WireLines/BlueLine.add_point(
					$Offset/WireLines/BlueLine.to_local(
						$Offset/WireStarts/BlueStart/Wiretip.global_position
					)
				)

				$Offset/WireLines/BlueLine.add_point(
					$Offset/WireLines/BlueLine.to_local(
						$Offset/WireEnds/BlueEnd/Wiretip.global_position
					)
				)
				
				check_completion()
			else:
				$Offset/WireLines/BlueLine.visible = false
				$Offset/WireLines/BlueLine.clear_points()
		elif dragging_green:
			dragging_green = false

			if green_over_target:
				green_connected = true
				$Offset/WireLines/GreenLine.clear_points()

				$Offset/WireLines/GreenLine.add_point(
					$Offset/WireLines/GreenLine.to_local(
						$Offset/WireStarts/GreenStart/Wiretip.global_position
					)
				)

				$Offset/WireLines/GreenLine.add_point(
					$Offset/WireLines/GreenLine.to_local(
						$Offset/WireEnds/GreenEnd/Wiretip.global_position
					)
				)
				
				check_completion()
			else:
				$Offset/WireLines/GreenLine.visible = false
				$Offset/WireLines/GreenLine.clear_points()
		elif dragging_yellow:
			dragging_yellow = false

			if yellow_over_target:
				yellow_connected = true
				$Offset/WireLines/YellowLine.clear_points()

				$Offset/WireLines/YellowLine.add_point(
					$Offset/WireLines/YellowLine.to_local(
						$Offset/WireStarts/YellowStart/Wiretip.global_position
					)
				)

				$Offset/WireLines/YellowLine.add_point(
					$Offset/WireLines/YellowLine.to_local(
						$Offset/WireEnds/YellowEnd/Wiretip.global_position
					)
				)
				
				check_completion()
			else:
				$Offset/WireLines/YellowLine.visible = false
				$Offset/WireLines/YellowLine.clear_points()

func _on_red_start_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if (
			event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
			and not red_connected
		):
			dragging_red = true
			$Offset/WireLines/RedLine.visible = true


func _on_red_end_mouse_entered() -> void:
	red_over_target = true


func _on_red_end_mouse_exited() -> void:
	red_over_target = false


func _on_blue_start_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if (
			event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
			and not blue_connected
		):
			dragging_blue = true
			$Offset/WireLines/BlueLine.visible = true


func _on_blue_end_mouse_entered() -> void:
	blue_over_target = true


func _on_blue_end_mouse_exited() -> void:
	blue_over_target = false


func _on_green_start_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if (
			event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
			and not green_connected
		):
			dragging_green = true
			$Offset/WireLines/GreenLine.visible = true


func _on_green_end_mouse_entered() -> void:
	green_over_target = true


func _on_green_end_mouse_exited() -> void:
	green_over_target = false


func _on_yellow_start_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if (
			event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
			and not yellow_connected
		):
			dragging_yellow = true
			$Offset/WireLines/YellowLine.visible = true


func _on_yellow_end_mouse_entered() -> void:
	yellow_over_target = true


func _on_yellow_end_mouse_exited() -> void:
	yellow_over_target = false

func check_completion() -> void:
	if (
		red_connected
		and blue_connected
		and green_connected
		and yellow_connected
	):
		finish()
