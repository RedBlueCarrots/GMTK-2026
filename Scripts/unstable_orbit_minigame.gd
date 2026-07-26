extends Minigame

var angle = 0.0
var speed = 50
var type = "orbit"

var death_message = "Your satellites crashed into your base..."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HSlider.value = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	angle += $HSlider.value * delta
	$Orbit.rotation += delta /3
	$Planet.rotation += delta  /3
	$Satellite.rotation = angle
	$Satellite.position.y -= speed * delta * sin(angle)
	if abs($Satellite.position.y-54) < 10:
		$Orbit.modulate = Color.GREEN
		if $Timer.paused == true or $Timer.is_stopped():
			$Timer.start()
	else:
		$Orbit.modulate = Color.RED
		$Timer.stop()
	if $Satellite.position.y > 95 or $Satellite.position.y < -12:
		fail()


func _on_timer_timeout() -> void:
	finish()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	angle = (randf()-0.5)*0.8
	if abs(angle) < 0.2:
		_on_animation_player_animation_finished(anim_name)
