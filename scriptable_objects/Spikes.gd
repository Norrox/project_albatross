extends Node2D

func _ready():
	pass
	
func _process(delta):
	if $Timer.is_stopped():
		update_all_spikes()

func _on_Timer_timeout():
	$Timer.stop()
	
func update_all_spikes():
	for child in get_children():
		if child.name != 'Timer':
			child.get_node("AnimationPlayer").play('up')
	$Timer.start()