extends Minigame

@onready var progress_bar: ProgressBar = $"Progress bar"
@onready var label: Label = $Percentage
@onready var crank: Node2D = $Crank

func _ready() -> void:
	progress_bar.value = 0.0
	label.text = "0.0 %"

func _process(delta: float) -> void:
	if crank.turning:
		progress_bar.value += progress_bar.step
	else :
		progress_bar.value -= progress_bar.step
	
	if progress_bar.value == 100.0:
		finish()

func _on_progress_bar_value_changed(value: float) -> void:
	label.text = str(value) + " %"

func _on_timer_timeout() -> void:
	fail()
