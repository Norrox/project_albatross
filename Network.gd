extends Node

const MIN_PLAYERS = 1
const MAX_PLAYERS = 3

var players = { }
var self_data = { name = '', direction = Vector2(), animation = 'idle', position = Vector2(), rifle_rotation = 0.0 }
var master_ID = "No_Master"

var gpgs = null
var game_started = false

func _ready():
	print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ ready() Called!")
	init_play_services()
	#get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')

func init_play_services():
	if Engine.has_singleton("GodotPlayGameServices"):
		gpgs = Engine.get_singleton("GodotPlayGameServices")
		print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS module singleton Added!")
		gpgs.init(get_instance_id(), true)
		print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS module singleton init() called!")
		gpgs.keepScreenOn(true)
		print('~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ Screen forced on!') 

func connected_init_match():
	master_ID = get_current_player_ID()
	self_data.name = get_current_player_display_name()
	players[master_ID] = self_data
	google_send_player_info()
	$'/root/Menu/'._load_game()		

func get_IDs():
	return get_all_participant_IDs().split(',')

func google_sign_in():
	gpgs.signInInteractive()
	
func google_sign_out():
	gpgs.signOut()
	
func google_send_player_info():
	for peer_id in get_IDs():
		if peer_id != master_ID:
			send_reliable_data(var2str(self_data), peer_id)
			
func google_send_unreliable(position):
	for peer_id in get_IDs():
		if peer_id != master_ID:
			send_unreliable_data(var2str(position), peer_id)
			
func update_player_info(sender_ID, info):
	players[sender_ID] = str2var(info)		

func update_player_position(sender_ID, info):
	players[sender_ID].position = str2var(info)
		
func init_other_players():
	print('~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ Creating player and loading game')
	for peer_id in players.keys():
		if peer_id != master_ID:
			var new_player = load('res://player/Player.tscn').instance()
			new_player.name = players[peer_id].name
			new_player.ID = peer_id
			print('New Player Name ' + new_player.name)
			$'/root/Game/'.add_child(new_player)
			new_player.init(new_player.name, Vector2(200,200), true)
			print('New Player: ' + new_player.name + ' Initialized.')
	
func is_online():
	return gpgs.isOnline()
	
func get_current_player_ID():
	return gpgs.getCurrentPlayerID()
	
func get_current_player_display_name():
	return gpgs.getCurrentPlayerDisplayName()
	
func start_quick_game(minPlayers, maxPlayers, role_bitmask):
	gpgs.rtmStartQuickGame(minPlayers, maxPlayers, role_bitmask)
	
func get_all_participant_IDs():
	return gpgs.rtmGetAllParticipantIDs()
	
func send_reliable_data(data, participantIDs):
	gpgs.rtmSendReliableData(data, participantIDs)
	
func send_reliable_data_to_all(data):
	gpgs.rtmSendReliableDataToAll(data)
	
func send_unreliable_data(data, participantIDs):
	gpgs.rtmSendUnreliableData(data, participantIDs)
	
func send_unreliable_data_to_all(data):
	gpgs.rtmSendUnreliableDataToAll(data)
	
### google callbacks ###	
func _on_play_game_services_sign_in_success(signInType, playerID):	
	print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS Sign In Succeeded!")
	start_quick_game(MIN_PLAYERS, MAX_PLAYERS, 0)
	
func _on_play_game_services_sign_in_failure(signInType):
	print('~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS Sign In Failed')
	
func _on_play_game_services_sign_out(success):
	print('~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS Player Signed Out')
	
func _on_play_game_services_rtm_room_client_created(success,roomID):
	print('~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ Auto quick room created')
	
func _on_play_game_services_rtm_room_all_participants_connected(success,roomID):
	print('~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ All participants connected in quick match')
	connected_init_match()
	
#func _on_play_game_services_rtm_reliable_message_sent(recipientId,tokenID):
	#print('~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ message sent to ' + recipientId)
	
#func _on_play_game_services_rtm_reliable_message_confirmed(recipientId,tokenID):
	#print('~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ message confirmed from ' + recipientId)
	
func _on_play_game_services_rtm_message_received(sender_ID, data, is_reliable):
	if is_reliable:
		update_player_info(sender_ID, data) 
	else:
		update_player_position(sender_ID, data)
### end google callbacks ###

func update_dir(direction):
	players[master_ID].direction = direction
	
func update_position(pos):
	players[master_ID].position = pos
	
func update_anim(animation):
	players[master_ID].animation = animation
	
func update_gun_angle():
	pass
