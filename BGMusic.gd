extends AudioStreamPlayer

func _ready():
	#yield(get_parent().get_node('ReadyOneShot'),'finished')
	play()