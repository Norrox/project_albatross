extends KinematicBody2D

const TARGET_POS = Vector2(576, 280)
const MOVE_SPEED = 3

func _ready():
	hide()

func _physics_process(delta):
	if !Network.victorious and !get_tree().current_scene.name == 'Menu':
		return
	if !visible:
		show()
	if global_position != TARGET_POS:
		move_and_slide((TARGET_POS - global_position) * MOVE_SPEED)
