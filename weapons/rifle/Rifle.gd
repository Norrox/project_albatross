extends Sprite

const Bullet = preload("res://weapons/bullet/Bullet.tscn")
var shoot = false
var analog = null

func _ready():
	analog = get_node("../../CanvasLayer")

func _process(delta):
	if shoot and $Timer.is_stopped():
		var bullet_direction = analog.stick2_vector
		var bullet_position = global_position
		var bullet_rotation = rotation
		if !$'/root/Game'.force_local:
			Network.google_send_reliable({ bullet_pos = bullet_position, bullet_rot = bullet_rotation, bullet_dir = bullet_direction })
		_shoot(bullet_position, bullet_rotation, bullet_direction)
		$Timer.start()

func _on_Timer_timeout():
	$Timer.stop()

func _shoot(bullet_pos, bullet_rot, bullet_dir):
	var bullet = Bullet.instance()
	add_child(bullet)
	bullet.rotation = bullet_rot
	bullet.global_position = bullet_pos
	bullet.direction = bullet_dir