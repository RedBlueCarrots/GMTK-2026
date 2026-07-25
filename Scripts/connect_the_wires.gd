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
		$WireLines/RedLine.clear_points()

		$WireLines/RedLine.add_point(
			$WireLines/RedLine.to_local(
				$WireStarts/RedStart/Wiretip.global_position
			)
		)

		$WireLines/RedLine.add_point(
			$WireLines/RedLine.get_local_mouse_position()
		)
	if dragging_blue:
		$WireLines/BlueLine.clear_points()

		$WireLines/BlueLine.add_point(
			$WireLines/BlueLine.to_local(
				$WireStarts/BlueStart/Wiretip.global_position
			)
		)

		$WireLines/BlueLine.add_point(
			$WireLines/BlueLine.get_local_mouse_position()
		)
	if dragging_green:
		$WireLines/GreenLine.clear_points()

		$WireLines/GreenLine.add_point(
			$WireLines/GreenLine.to_local(
				$WireStarts/GreenStart/Wiretip.global_position
			)
		)

		$WireLines/GreenLine.add_point(
			$WireLines/GreenLine.get_local_mouse_position()
		)
	if dragging_yellow:
		$WireLines/YellowLine.clear_points()

		$WireLines/YellowLine.add_point(
			$WireLines/YellowLine.to_local(
				$WireStarts/YellowStart/Wiretip.global_position
			)
		)

		$WireLines/YellowLine.add_point(
			$WireLines/YellowLine.get_local_mouse_position()
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
				$WireLines/RedLine.clear_points()

				$WireLines/RedLine.add_point(
					$WireLines/RedLine.to_local(
						$WireStarts/RedStart/Wiretip.global_position
					)
				)

				$WireLines/RedLine.add_point(
					$WireLines/RedLine.to_local(
						$WireEnds/RedEnd/Wiretip.global_position
					)
				)
				
				check_completion()
			else:
				$WireLines/RedLine.visible = false
				$WireLines/RedLine.clear_points()


		elif dragging_blue:
			dragging_blue = false

			if blue_over_target:
				blue_connected = true
				$WireLines/BlueLine.clear_points()

				$WireLines/BlueLine.add_point(
					$WireLines/BlueLine.to_local(
						$WireStarts/BlueStart/Wiretip.global_position
					)
				)

				$WireLines/BlueLine.add_point(
					$WireLines/BlueLine.to_local(
						$WireEnds/BlueEnd/Wiretip.global_position
					)
				)
				
				check_completion()
			else:
				$WireLines/BlueLine.visible = false
				$WireLines/BlueLine.clear_points()
		elif dragging_green:
			dragging_green = false

			if green_over_target:
				green_connected = true
				$WireLines/GreenLine.clear_points()

				$WireLines/GreenLine.add_point(
					$WireLines/GreenLine.to_local(
						$WireStarts/GreenStart/Wiretip.global_position
					)
				)

				$WireLines/GreenLine.add_point(
					$WireLines/GreenLine.to_local(
						$WireEnds/GreenEnd/Wiretip.global_position
					)
				)
				
				check_completion()
			else:
				$WireLines/GreenLine.visible = false
				$WireLines/GreenLine.clear_points()
		elif dragging_yellow:
			dragging_yellow = false

			if yellow_over_target:
				yellow_connected = true
				$WireLines/YellowLine.clear_points()

				$WireLines/YellowLine.add_point(
					$WireLines/YellowLine.to_local(
						$WireStarts/YellowStart/Wiretip.global_position
					)
				)

				$WireLines/YellowLine.add_point(
					$WireLines/YellowLine.to_local(
						$WireEnds/YellowEnd/Wiretip.global_position
					)
				)
				
				check_completion()
			else:
				$WireLines/YellowLine.visible = false
				$WireLines/YellowLine.clear_points()

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
			$WireLines/RedLine.visible = true


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
			$WireLines/BlueLine.visible = true


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
			$WireLines/GreenLine.visible = true


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
			$WireLines/YellowLine.visible = true


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
