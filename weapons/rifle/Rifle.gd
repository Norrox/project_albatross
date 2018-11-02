extends Sprite

const Bullet = preload("res://weapons/bullet/Bullet.tscn")
var shoot = false
var analog = null

func _ready():
	analog = get_node("/root/Game/CanvasLayer")

func _process(delta):
	if shoot and $Timer.is_stopped():
		var bd = analog.stick2_vector
		var bp = global_position
		var br = rotation
		if !Network.force_local:
			Network.google_send_reliable({ p = bp, r = br, d = bd })
		_shoot(bp, br, bd)
		$Timer.start()

func _on_Timer_timeout():
	$Timer.stop()

func _shoot(bullet_pos, bullet_rot, bullet_dir):
	$'../Camera2D'.shake(0.2,15, 5)
	var bullet = Bullet.instance()
	add_child(bullet)
	bullet.rotation = bullet_rot
	bullet.global_position = bullet_pos
	bullet.direction = bullet_dir