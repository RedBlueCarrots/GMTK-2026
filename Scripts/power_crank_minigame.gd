extends Minigame

@onready var progress_bar: TextureProgressBar = $"Progress bar"
@onready var label: Label = $Percentage
@onready var crank: Node2D = $Crank

func _ready() -> void:
	progress_bar.value = 0.0
	label.text = "0.0 %"

func _process(delta: float) -> void:
	progress_bar.value = crank.turned_amount
	
	if progress_bar.value == 100.0:
		finish()

func _on_progress_bar_value_changed(value: float) -> void:
	label.text = str(value) + " %"

func _on_timer_timeout() -> void:
	fail()
