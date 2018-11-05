extends Node2D

const MAX_XY_MOVE = 1.5

var orig_pos = Vector2()
var i = 0

func _ready():
	orig_pos = global_position
	
func _process(delta):
	i += 1
	if i == 48:
		i = 0
	if i % 2 == 0:
		return
	var random_x = randi()%2+1
	var random_y = randi()%2+1
	var dir_vector = Vector2(random_x, random_y)
	position += dir_vector * delta
	if orig_pos.distance_to(position) > MAX_XY_MOVE:
		position = orig_pos