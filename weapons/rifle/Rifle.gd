extends Sprite

const Bullet = preload("res://weapons/bullet/Bullet.tscn")
var shoot = false
var analog = null

func _ready():
	analog = get_node("../../CanvasLayer")

func _process(delta):
	if is_network_master():
		var analog_direction = analog.stick2_vector
		if shoot and $Timer.is_stopped():
			rpc('_shoot', analog_direction)
			$Timer.start()

func _on_Timer_timeout():
	$Timer.stop()

sync func _shoot(stick_dir):
	var	direction = stick_dir
	var bullet = Bullet.instance()
	add_child(bullet)
	bullet.rotation = rotation
	bullet.global_position = global_position
	bullet.direction = direction