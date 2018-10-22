extends Node

var force_local = false
onready var sc_canvas = $CanvasLayer/L_debug

func _init():
	if OS.get_name() == 'Windows':
		force_local = true

func _ready():
	if !force_local:
		var new_player = preload('res://player/Player.tscn').instance()
		
		new_player.name = Network.get_current_player_display_name()
		new_player.is_master = true
		
		add_child(new_player)
		var info = Network.self_data
		new_player.init(info.name, Vector2(100,100), false)
		sc_canvas.debug_print('New Player: ' + info.name)
		
		Network.init_other_players()
	else:
		var new_player = preload('res://player/Player.tscn').instance()
		
		new_player.name = 'test'
		new_player.is_master = true
			
		add_child(new_player)
		new_player.init('test', Vector2(100,100), false)
		sc_canvas.debug_print('test player initialised')