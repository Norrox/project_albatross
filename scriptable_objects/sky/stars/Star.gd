extends Sprite

var is_in_process = false

func _process(delta):
	if !is_in_process:
		wait_then_twinkle()
	
func wait_then_twinkle():
	is_in_process = true
	randomize()
	var random = randi()%6+1
	yield(get_tree().create_timer(random),'timeout')
	$AnimationPlayer.play('twinkle')
	is_in_process = false
	