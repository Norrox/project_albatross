extends Area2D

export(float) var SPEED = 750
export(float) var DAMAGE = 5

var direction = 0

func _ready():
	connect("body_entered", self, "_on_body_entered")
	set_as_toplevel(true)
	$AudioStreamPlayer2D.play()

func _process(delta):
	position += direction * SPEED * delta

func _on_body_entered(body):
	if body.is_a_parent_of(self):
		return
	elif body.is_in_group('players') and !body.rolling:	
		body.damage(DAMAGE)
		queue_free()
	hide()
	yield($AudioStreamPlayer2D,"finished")
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	# causing damage to not update when freeing here
	pass
