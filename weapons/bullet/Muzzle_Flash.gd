extends StaticBody2D

func _ready():
	yield(get_tree().create_timer(0.05),"timeout")
	queue_free()
