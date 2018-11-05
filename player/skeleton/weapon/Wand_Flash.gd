extends StaticBody2D

func _ready():
	$AnimationPlayer.play('flash')
	yield($AnimationPlayer,'animation_finished')
	queue_free()

#func _physics_process(delta):
	#position += Vector2(1,0)