extends AudioStreamPlayer

@export var bpm: int
@export var noteType: int = 1

# Tracking the beat and song position
var songPosition = 0.0
var songPositionBeats = 1
var songPositionRaw: float
var beatDuration: float
var lastBeat = 0
var anacrusis = 0
var measure = 1

signal Beat(Pos)
signal EndLevel()

func _ready():
	beatDuration = 60.0 / bpm / noteType
	play()
	
func _process(delta):
		songPosition = get_playback_position() + AudioServer.get_time_since_last_mix()
		#Compensate for output latency.
		songPosition -= AudioServer.get_output_latency()
		#print("Time is: ", songPosition)
		songPositionBeats = int(floor(songPosition / beatDuration))
		songPositionRaw = (songPosition / beatDuration)

		if songPositionBeats != lastBeat:
			emit_signal("Beat", songPositionBeats)
			lastBeat = songPositionBeats
			
func get_beat():
	return songPositionRaw
	
func get_beat_int():
	return songPositionBeats
	
func get_beat_duration():
	return beatDuration
	
func _on_finished() -> void:
	print("end!!!")
	emit_signal("EndLevel")
	
