extends Area2D

const HEALTH = 10

func _ready():
	$AnimationPlayer.play('idle')
	connect('body_entered', self, '_on_body_entered')

func _on_body_entered(body):
	if body.is_in_group('players'):
		if body.is_master:
			if body.health_points + HEALTH >= 100:
				body.health_points = 100
			else:
				body.health_points += HEALTH
			body.update_reliable('update_player_health')
			body._update_health_bar(body.health_points)
		$CoinSound.play()
		$AnimationPlayer.play('pickup')
		yield($AnimationPlayer, "animation_finished")
		queue_free()
