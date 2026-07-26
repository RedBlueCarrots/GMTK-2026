extends Minigame

@onready var progress_bar: TextureProgressBar = $"Progress bar"
@onready var label: Label = $Percentage
@onready var crank: Node2D = $Crank

var death_message = "Your power completely ran out..."

func _ready() -> void:
	progress_bar.value = 0.0
	label.text = "0.0 %"

func _process(delta: float) -> void:
	super(delta)
	progress_bar.value = get_parent().get_parent().get_node("Timer").time_left
	
	if progress_bar.value == 60.0:
		finish()

func _on_progress_bar_value_changed(value: float) -> void:
	label.text = str(value) + " %"

func _on_timer_timeout() -> void:
	fail()

func turn(amount):
	get_parent().get_parent().get_node("Timer").wait_time = clamp(get_parent().get_parent().get_node("Timer").time_left + amount/2, 0.0, 60.0)
	get_parent().get_parent().get_node("Timer").start()
