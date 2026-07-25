extends Node2D
const JUDGEMENT_LINE = 176
const SPEED = 150
const SPAWN_Y = 700
const TARGET_SIZE = 1

var conductor
@export var beat: float
var buffer = 3.0
var start_scale = 3.0
var end_scale = 1.7

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(87,70)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if conductor.get_beat() > beat + 0.3:
		get_parent().active_notes.pop_front()
		queue_free()
		
	var current_beat = conductor.get_beat()
	var spawn = beat - buffer

	var progress = inverse_lerp(spawn, beat, current_beat)

	progress = clamp(progress, 0.0, 1.0)

	var current_scale = lerp(start_scale, end_scale, progress)
	scale = Vector2.ONE * current_scale

func hit():
	queue_free()
	
func miss():
	queue_free()


func _on_timer_timeout() -> void:
	queue_free()
