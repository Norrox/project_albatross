extends StaticBody2D

var rifle = null

func _ready():
	rifle = get_parent()

func _physics_process(delta):
	position += Vector2(1,0)

func _on_Lifetime_timeout():
	queue_free()
