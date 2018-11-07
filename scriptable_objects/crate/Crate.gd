extends StaticBody2D

var hit = 0

func hit():
	hit += 1
	get_node('AnimationPlayer').play('hit' + str(hit))
	if hit == 2:
		yield(get_node('AnimationPlayer'), 'animation_finished')
		queue_free()