extends Node

var NOTE_QUEUE: Array[float] = []
var active_notes = []
var bar_count = 0
var note_scene = preload("res://Scenes/rhythm_circle.tscn")
@export var score = 0
signal Success()
signal Miss()
var count = 0


const pattern1: Array[Array] = [
	[0,0, 0,0, 0,0, 1,0],
	[0,0, 0,0, 1,0, 1,0],
	[0,0, 0,0, 0,0, 1,0],
	[0,0, 0,0, 0,0, 1,1]
	]
	
const pattern2: Array[Array] = [
	[0,0, 0,0, 1,0, 1,0],
	[0,0, 0,0, 0,0, 1,0],
	[0,0, 0,0, 1,0, 1,0],
	[0,0, 0,0, 0,0, 1,0]
	]
const pattern3: Array[Array] = [
	[0,0, 0,0, 0,0, 1,0],
	[0,0, 0,0, 0,0, 1,1],
	[0,0, 0,0, 0,0, 1,0],
	[0,0, 0,0, 0,0, 1,1]
	]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	extend_chart(pattern1, bar_count)
	bar_count = pattern1.size()
	
func extend_chart(chart_data, start_bar):
	for barIndex in range(chart_data.size()):
		var bar: Array = chart_data[barIndex]
		var subdivision := 1.0 / bar.size() * 4
		for noteIndex: int in range(bar.size()):
			if bar[noteIndex] != 0:
				var beat = start_bar * 4 + barIndex * 4 + noteIndex * subdivision
				NOTE_QUEUE.append(beat)

const SPAWN_BUFFER = 3.0
var note_index = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(NOTE_QUEUE)
	#print(active_notes)
	var current_beat = %Conductor.get_beat_int()
	while note_index < NOTE_QUEUE.size():
		var note_beat = NOTE_QUEUE[note_index]
		if %Conductor.get_beat() >= note_beat - SPAWN_BUFFER:
			spawn_note(NOTE_QUEUE[note_index])
			count += 1
			print(count)
			note_index += 1
		else:
			break
			
var hit_tolerance = 0.3
func hit_detect():
	var current_beat = %Conductor.get_beat()
	
	if active_notes.is_empty():
		return
		
	var note = active_notes[0]
	var offset = current_beat - note.beat
	
	if abs(offset) <= hit_tolerance:
		active_notes.pop_front()
		note.hit()
		print("hit")
		$"../Hit".play()
		emit_signal("Success")
	else:
		print("Miss")
		$"../Miss".play()
		score -= 1
	
func spawn_note(beat):
	print("spawned note")
	var note = note_scene.instantiate()
	note.conductor = %Conductor
	note.manager = self
	note.beat = beat
	active_notes.append(note)
	get_parent().add_child(note)
		
func _on_conductor_beat(Pos: Variant) -> void:
	if %Conductor.get_beat_int() % 4 == 0: #add next sequence to chart
		var rand = randi_range(1,3)
		if rand == 1:
			extend_chart(pattern1, bar_count)
		elif rand == 2:	
			extend_chart(pattern2, bar_count)
		elif rand == 3:	
			extend_chart(pattern3, bar_count)
		bar_count += pattern1.size()

func play_miss_sound():
	$"../Miss".play()

func _on_texture_button_pressed() -> void:
	hit_detect()
