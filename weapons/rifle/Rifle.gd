extends Sprite

const Bullet = preload("res://weapons/bullet/Bullet.tscn")

func _process(delta):
	if is_network_master():
		if Input.is_action_pressed('shoot') and $Timer.is_stopped():
			rpc('_shoot', get_global_mouse_position())
			$Timer.start()

func _on_Timer_timeout():
	$Timer.stop()

sync func _shoot(mouse_pos):
	var	direction = (mouse_pos - global_position).normalized()
	var bullet = Bullet.instance()
	add_child(bullet)
	bullet.rotation = rotation
	bullet.global_position = global_position
	bullet.direction = direction