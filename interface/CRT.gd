extends Node

func _ready():
	if !Settings.enable_ultra_graphics:
		queue_free()
