extends Node2D
const JUDGEMENT_LINE = 176
const SPEED = 150
const SPAWN_Y = 700
const TARGET_SIZE = 1

var conductor
var manager
@export var beat: float
var buffer = 3.0
var start_scale = 3.0
var end_scale = 0.85

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(95,81)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if conductor.get_beat() > beat + 0.3:
		manager.active_notes.pop_front()
		manager.play_miss_sound()
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
