extends Node

var force_local = false
onready var sc_canvas = $CanvasLayer/L_debug

func _init():
	if OS.get_name() == 'Windows':
		force_local = true

func _ready():
	if !force_local:
		var player_ID = Network.master_participant_ID
		var spawn_pos = $'/root/Game/Spawns'.get_node('Spawn' + str(Network.players[player_ID].index + 1)).global_position
		var play_name = Network.get_current_player_display_name()
		create_master_player(spawn_pos, play_name, player_ID)
		sc_canvas.debug_print('New Player: ' + play_name)
		
		Network.google_send_reliable({ pos = spawn_pos, player_name = play_name })		
	else:
		var new_player = preload('res://player/Player.tscn').instance()
		var spawn_pos = $'/root/Game/Spawns'.get_node('Spawn1').global_position
		
		new_player.name = 'test'
		new_player.is_master = true
			
		$'/root/'.add_child(new_player)
		new_player.init('test', spawn_pos, false)

		sc_canvas.debug_print('test player initialised')
		
func create_master_player(spawn_pos, play_name, player_ID):
	sc_canvas.debug_print('creating master player')
	var new_player = load('res://player/Player.tscn').instance()
	new_player.name = play_name
	new_player.ID = player_ID
	new_player.is_master = true
	new_player.init(play_name, spawn_pos, false)
	$'/root/'.add_child(new_player)