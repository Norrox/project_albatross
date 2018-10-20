extends Camera2D

func _ready():
	if !get_parent().is_master:
		current = false