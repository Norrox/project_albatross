extends Node

func _ready():
	var new_player = preload('res://player/Player.tscn').instance()
	
	#new_player.name = Network.get_current_player_display_name()
	new_player.is_master = true
		
	add_child(new_player)
	var info = Network.self_data
	new_player.init(info.name, info.position, false)