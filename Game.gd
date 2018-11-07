extends Node

onready var sc_canvas = $CanvasLayer/L_debug

func _ready():
	if !Network.force_local:
		var player_ID = Network.master_participant_ID
		var spawn_pos = $'/root/Game/Spawns'.get_node('Spawn' + str(Network.players[player_ID].index + 1)).global_position
		var play_name = Network.get_current_player_display_name()
		create_master_player(spawn_pos, play_name, player_ID)
		sc_canvas.debug_print('New Player: ' + play_name)
		
		Network.update_name(play_name)
		Network.update_position(spawn_pos)
		Network.update_player_type(Settings.player_type)
		Network.update_action('create_slave_at_spawn')
		Network.google_send_reliable(Network.self_data)		
	else:
		var new_player = null
		if Settings.player_type == Settings.PLAYER_TYPE.skeleton:
			new_player = preload('res://player/skeleton/Skeleton.tscn').instance()
		elif Settings.player_type == Settings.PLAYER_TYPE.human:
			new_player = preload('res://player/human/Player.tscn').instance()
		elif Settings.player_type == Settings.PLAYER_TYPE.bandit:
			new_player = preload('res://player/bandit/Bandit.tscn').instance()
				
		var spawn_pos = $'/root/Game/Spawns'.get_node('Spawn1').global_position
		
		new_player.name = 'test'
		new_player.is_master = true
		Network.master_ID = 'test'
		Network.self_data.name = 'test'
		Network.players[Network.master_ID] = Network.self_data
			
		$'/root/'.add_child(new_player)
		new_player.init('test', spawn_pos, false)

		sc_canvas.debug_print('test player initialised')
		
func create_master_player(spawn_pos, play_name, player_ID):
	sc_canvas.debug_print('creating master player')
	var new_player = null
	if Settings.player_type == Settings.PLAYER_TYPE.skeleton:
		new_player = preload('res://player/skeleton/Skeleton.tscn').instance()
	elif Settings.player_type == Settings.PLAYER_TYPE.human:
		new_player = preload('res://player/human/Player.tscn').instance()
	elif Settings.player_type == Settings.PLAYER_TYPE.bandit:
		new_player = preload('res://player/bandit/Bandit.tscn').instance()
				
	new_player.name = play_name
	new_player.ID = player_ID
	new_player.is_master = true
	$'/root/'.add_child(new_player)
	new_player.init(play_name, spawn_pos, false)
