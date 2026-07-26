extends AudioStreamPlayer
var audio_stream = self.stream as AudioStreamSynchronized

# Change volume of track 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_game_open(nam: Variant) -> void:
	if nam == "starvation":
		print("food")
		audio_stream.set_sync_stream_volume(0, 0)
		audio_stream.set_sync_stream_volume(1, -60)
		audio_stream.set_sync_stream_volume(2, 0)
		audio_stream.set_sync_stream_volume(3, -60)
		audio_stream.set_sync_stream_volume(4, -60)
		audio_stream.set_sync_stream_volume(5, -60)
		audio_stream.set_sync_stream_volume(6, -60)
		audio_stream.set_sync_stream_volume(7, -60)
	elif nam == "orbit":
		print("orbit")
		audio_stream.set_sync_stream_volume(0, 0)
		audio_stream.set_sync_stream_volume(1, -60)
		audio_stream.set_sync_stream_volume(2, -60)
		audio_stream.set_sync_stream_volume(3, 0)
		audio_stream.set_sync_stream_volume(4, -60)
		audio_stream.set_sync_stream_volume(5, -60)
		audio_stream.set_sync_stream_volume(6, -60)
		audio_stream.set_sync_stream_volume(7, -60)
	elif nam == "discontent":
		print("typing")
		audio_stream.set_sync_stream_volume(0, 0)
		audio_stream.set_sync_stream_volume(1, -60)
		audio_stream.set_sync_stream_volume(2, -60)
		audio_stream.set_sync_stream_volume(3, -60)
		audio_stream.set_sync_stream_volume(4, 0)
		audio_stream.set_sync_stream_volume(5, -60)
		audio_stream.set_sync_stream_volume(6, -60)
		audio_stream.set_sync_stream_volume(7, -60)
	elif nam == "water":
		print("water")
		audio_stream.set_sync_stream_volume(0, 0)
		audio_stream.set_sync_stream_volume(1, -60)
		audio_stream.set_sync_stream_volume(2, -60)
		audio_stream.set_sync_stream_volume(3, -60)
		audio_stream.set_sync_stream_volume(4, -60)
		audio_stream.set_sync_stream_volume(5, 0)
		audio_stream.set_sync_stream_volume(6, -60)
		audio_stream.set_sync_stream_volume(7, -60)
	elif nam == "pipe":
		print("pipe")
		audio_stream.set_sync_stream_volume(0, 0)
		audio_stream.set_sync_stream_volume(1, -60)
		audio_stream.set_sync_stream_volume(2, -60)
		audio_stream.set_sync_stream_volume(3, -60)
		audio_stream.set_sync_stream_volume(4, -60)
		audio_stream.set_sync_stream_volume(5, -60)
		audio_stream.set_sync_stream_volume(6, 0)
		audio_stream.set_sync_stream_volume(7, -60)
	elif nam == "power":
		print("power")
		audio_stream.set_sync_stream_volume(0, 0)
		audio_stream.set_sync_stream_volume(1, -60)
		audio_stream.set_sync_stream_volume(2, -60)
		audio_stream.set_sync_stream_volume(3, -60)
		audio_stream.set_sync_stream_volume(4, -60)
		audio_stream.set_sync_stream_volume(5, -60)
		audio_stream.set_sync_stream_volume(6, -60)
		audio_stream.set_sync_stream_volume(7, 0)
	elif nam == "cult":
		audio_stream.set_sync_stream_volume(0, 0)
		audio_stream.set_sync_stream_volume(1, 0)
		audio_stream.set_sync_stream_volume(2, -60)
		audio_stream.set_sync_stream_volume(3, -60)
		audio_stream.set_sync_stream_volume(4, -60)
		audio_stream.set_sync_stream_volume(5, -60)
		audio_stream.set_sync_stream_volume(6, -60)
		audio_stream.set_sync_stream_volume(7, -60)
