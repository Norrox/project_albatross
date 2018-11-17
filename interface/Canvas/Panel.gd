extends KinematicBody2D

const ORIG_POS = Vector2(576,-282)
const TARGET_POS = Vector2(576, 282)
const MOVE_SPEED = 3

var move_up = false
var hold = true

func _ready():
	hide()

func _physics_process(delta):
	if !Network.victorious and !Network.out_of_lives:
		return
	if hold:
		if $DELAY.is_stopped():
			$DELAY.start()
		return
	if Network.out_of_lives:
		$VictoryLabel.text = 'DEFEAT!'
	if !visible:
		show()
		
	if !move_up:	
		if global_position.distance_to(TARGET_POS) > 1:
			move_and_slide((TARGET_POS - global_position) * MOVE_SPEED)
	else:
		if global_position.distance_to(ORIG_POS) > 1:
			move_and_slide((ORIG_POS - global_position) * MOVE_SPEED)
		else:
			for child in get_tree().root.get_children():
				if child.is_in_group('players'):
					child.queue_free()
					yield(child, 'tree_exited')
			Network.cleanup_up_after_game()
			Global.goto_scene('res://interface/Menu.tscn')

func _on_PanelButton_pressed():
	move_up = true


func _on_DELAY_timeout():
	hold = false
