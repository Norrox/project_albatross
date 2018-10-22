extends Node

var MIN_PLAYERS = 1 #const
var MAX_PLAYERS = 4 #const

var connected_peers = ""
var players = { }
var self_data = { name = '', animation = 'idle', position = Vector2(), rifle_rotation = 0, hp = 100 }
var master_ID = "No_Master"

var gpgs = null
var game_started = false

func _ready():
	print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ ready() Called!")
	init_play_services()

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
	while players.size() < get_IDs().size():
		yield(get_tree().create_timer(0.02), "timeout")
	set_peers_list()
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

func google_send_reliable(data):
	send_reliable_data(var2str(data), connected_peers)
			
func google_send_unreliable(data):
	send_unreliable_data(var2str(data), connected_peers)
	
func set_peers_list():
	for peer_id in players.keys():
		if peer_id != master_ID:
			connected_peers += peer_id + ','
	connected_peers = connected_peers.substr(0, connected_peers.length()-1)
			
func update_player_info(sender_ID, data):
	players[sender_ID] = str2var(data)		
	
func update_player_animation(sender_ID, data):
	var data_var = str2var(data)
	players[sender_ID].animation = data_var.anim

func update_player_positions(sender_ID, data):
	var data_var = str2var(data)
	players[sender_ID].position = data_var.position
	players[sender_ID].rifle_rotation = data_var.rotation
	
func update_player_health(sender_ID, data):
	var data_var = str2var(data)
	for peer_id in players.keys():
		if peer_id != master_ID:
			$'/root/Game'.get_node(players[sender_ID].name)._update_health_bar(players[sender_ID].hp)
			
func update_player_death(sender_ID, data):
	var data_var = str2var(data)
	for peer_id in players.keys():
		if peer_id != master_ID:
			$'/root/Game'.get_node(players[sender_ID].name)._die()
	
func spawn_bullet(sender_ID, data):
	var data_var = str2var(data)
	for peer_id in players.keys():
		if peer_id != master_ID:
			$'/root/Game'.get_node(players[peer_id].name).get_node('Rifle')._shoot(data_var.bullet_pos, data_var.bullet_rot, data_var.bullet_dir)
		
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
		var data_var = str2var(data)
		if data_var.has('name'):
			update_player_info(sender_ID, data) 
		elif data_var.has('bullet_pos'):
			spawn_bullet(sender_ID, data)
		elif data_var.has('health'):
			update_player_health(sender_ID, data)
		elif data_var.has('die'):
			update_player_death(sender_ID, data)
		else:
			update_player_animation(sender_ID, data)
	else:
		update_player_positions(sender_ID, data)
### end google callbacks ###

func update_position(pos):
	players[master_ID].position = pos
	
func update_anim(animation):
	players[master_ID].animation = animation
	
func update_gun_angle(rotation):
	players[master_ID].rifle_rotation = rotation
	
func update_health(hp):
	players[master_ID].hp = hp
