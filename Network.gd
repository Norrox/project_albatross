extends Node

const SIGN_IN_WAIT_TIME  = 5.0

var MIN_PLAYERS = 1 #const
var MAX_PLAYERS = 4 #const

var signed_in = false
var signing_in_busy = false
var connected_peers = ''
var players = { }
var players_order = []
var self_data = { index = -1, name = '', animation = 'idle', position = Vector2(), rifle_rotation = 0, hp = 100, action = '' }
var master_ID = 'No_Master'
var master_participant_ID = 'No_participant_ID'
var chests = []

var gpgs = null
var game_started = false
var force_local = false
var room_ID = 'No_Room'

func _ready():
	print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ ready() Called!")
	get_tree().set_auto_accept_quit(false)
	
	if OS.get_name() == 'Windows':
		force_local = true
	
	init_chests()
	init_play_services()
	if !force_local:
		google_sign_in()
		
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST and !force_local:
		google_sign_out()
		google_clear_cache()
		get_tree().quit() # default behavior
	elif what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST and force_local:
		get_tree().quit()

func init_play_services():
	if Engine.has_singleton("GodotPlayGameServices"):
		gpgs = Engine.get_singleton("GodotPlayGameServices")
		print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS module singleton Added!")
		gpgs.init(get_instance_id(), true)
		print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS module singleton init() called!")
		gpgs.keepScreenOn(true)
		print('~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ Screen forced on!') 
		
func init_chests():
	chests.resize(100)
	for i in range(0, 100):
		chests[i] = false

func connected_init_match():
	print('connected init match')
	master_ID = get_current_player_ID()
	set_peers_list()
	self_data.name = get_current_player_display_name()
	players[master_participant_ID] = self_data
	players_order.append(self_data.name)
	google_send_reliable(self_data)
	while players.size() < get_IDs().size():
		yield(get_tree().create_timer(0.02), "timeout")
	set_index()
	game_started = true
	gpgs.rtmHideWaitingRoomUI()
	$'/root/Menu/'._load_game()		

func get_IDs():
	return get_all_participant_IDs().split(',')
	
func set_index():
	var index = 0
	players_order.sort()
	for player_name in players_order:
		players[get_ID_from_name(player_name)].index = index
		index += 1
		
func get_ID_from_name(player_name):
	for id in players.keys():
		if player_name == players[id].name:
			return id

func google_sign_in(silent=true):
	if !silent:
		gpgs.signInInteractive()
	else:
		gpgs.signInSilent()
	signing_in_busy = true
	var delta = 0.0
	while signed_in == false:
		yield(get_tree().create_timer(0.02),'timeout')
		delta += 0.02
		if delta > SIGN_IN_WAIT_TIME:
			print('failed to sign in.. signing out')
			google_sign_out()
			break
	signing_in_busy = false
	
func google_sign_out():
	gpgs.signOut()
	
func set_peers_list():
	print('setting peers master is ' + str(master_ID))
	for peer_id in get_IDs():
		if peer_id != master_participant_ID:
			connected_peers += peer_id + ','
	connected_peers = connected_peers.substr(0, connected_peers.length()-1)
	print('connected peers: ' + str(connected_peers))
	
func remove_from_connected(participant_ID):
	print('updating connected_peers')
	var id_start_pos = connected_peers.find(participant_ID)
	connected_peers.erase(id_start_pos, len(participant_ID))
	if connected_peers.ends_with(','):
		connected_peers = connected_peers.substr(0, connected_peers.length()-1)
	elif connected_peers.substr(0,1) == ',':
		connected_peers = connected_peers.substr(1, connected_peers.length())
	else:
		var left_over_comma_pos = connected_peers.find(',,')
		connected_peers.erase(left_over_comma_pos, 1)
		
	#kill player wit no respawn	
	print('killing deserter ' + participant_ID)
	$'/root/'.get_node(players[participant_ID].name)._die(false, false)
			
func update_player_info(sender_ID, data_var):
	players[sender_ID] = data_var
	if data_var.action != '':
		var func_to_call = funcref(self, data_var.action)
		func_to_call.call_func(sender_ID, data_var)
		update_action('')
	
	if  !game_started:
		players_order.append(players[sender_ID].name)
	
func create_slave_at_spawn(sender_ID, data_var):
	print('creating slave player')
	var new_player = load('res://player/Player.tscn').instance()
	new_player.name = data_var.name
	new_player.ID = sender_ID
	players[sender_ID].position = data_var.position
	$'/root/'.add_child(new_player)
	new_player.init(new_player.name, data_var.position, true)

func update_player_positions(sender_ID, data_var):
	players[sender_ID].position = data_var.position
	players[sender_ID].rifle_rotation = data_var.rotation
	
func update_player_animation(sender_ID, data_var):
	players[sender_ID].animation = data_var.anim
	
func update_player_health(sender_ID, data_var):
	print('updating health for ' + sender_ID)
	players[sender_ID].hp = data_var.hp
	$'/root/'.get_node(players[sender_ID].name)._update_health_bar(players[sender_ID].hp)
			
func update_player_death(sender_ID, data_var):
	print(data_var.name  + ' died')
	$'/root/'.get_node(players[sender_ID].name)._die()
	
func spawn_bullet(sender_ID, data_var):
	$'/root/'.get_node(players[sender_ID].name).get_node('Rifle')._shoot(data_var.p, data_var.r, data_var.d)
	
func update_chest_open(sender_ID, data_var):
	var chest = $'/root/Game/Chests/'.get_node('Chest' + str(data_var.chest_num))
	var player = $'/root/'.get_node(players[sender_ID].name)
	chest.open(player)
	
func is_online():
	return gpgs.isOnline()
	
func google_send_reliable(data):
	send_reliable_data(var2str(data), connected_peers)
			
func google_send_unreliable(data):
	send_unreliable_data(var2str(data), connected_peers)
	
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
	
func google_clear_cache():
	gpgs.clearCache()
	
### google callbacks ###	
func _on_play_game_services_sign_in_success(signInType, playerID):	
	print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS Sign In Succeeded!")
	signed_in = true
	
func _on_play_game_services_sign_in_failure(signInType):
	print('~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS Sign In Failed')
	
func _on_play_game_services_sign_out(success):
	print('~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS Player Signed Out')
	signed_in = false
		
func _on_play_game_services_rtm_room_all_participants_connected(success,roomID):
	print('~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ All participants connected in quick match')
	connected_init_match()
	
func _on_play_game_services_rtm_room_status_connected_to_room(roomID, myParticipantID):
	master_participant_ID = myParticipantID
	
func _on_play_game_services_rtm_room_status_peers_disconnected(participantIDs):
	for id in participantIDs.split(','):
		remove_from_connected(id)
		
func _on_play_game_services_rtm_room_client_created(success, roomID):
	print('~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ Auto quick room created')
	print('showing waiting room UI')
	gpgs.rtmShowWaitingRoomUI(MAX_PLAYERS)
	
func _on_play_game_services_rtm_message_received(sender_ID, data, is_reliable):
	var data_var = str2var(data)
	if is_reliable:
		if data_var.has('p'):
			spawn_bullet(sender_ID, data_var)
		elif data_var.has('chest_num'):
			update_chest_open(sender_ID, data_var)
		else:
			update_player_info(sender_ID, data_var) 
	else:
		if data_var.has('anim'):
			update_player_animation(sender_ID, data_var)
		else:
			update_player_positions(sender_ID, data_var)
### end google callbacks ###

### self_data update functions ###
func update_position(pos):
	players[master_participant_ID].position = pos

func update_name(player_name):
	players[master_participant_ID].name = player_name

func update_anim(animation):
	players[master_participant_ID].animation = animation
	
func update_gun_angle(rotation):
	players[master_participant_ID].rifle_rotation = rotation
	
func update_health(hp):
	players[master_participant_ID].hp = hp
	
func update_action(action):
	players[master_participant_ID].action = action
### end self_data update functions ###