extends Node

#Default IP should be the one which creates the server?
#I use a DLink router and my phone has this IP (Check IP address in WiFi Settings>WiFi Info)
#const DEFAULT_IP = '192.168.0.102'
const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 5

var players = { }
var self_data = { name = '', position = Vector2(360, 180), rifle_rotation = 0.0 }

var gpgs = null

#signal player_disconnected
#signal server_disconnected

func _ready():
	print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ ready() Called!")
	init_play_services()
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')

func init_play_services():
	if Engine.has_singleton("GodotPlayGameServices"):
		gpgs = Engine.get_singleton("GodotPlayGameServices")
		print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS module singleton Added!")
		gpgs.init(get_instance_id(), true)
		print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS module singleton init() called!")

func connected_init_match():
	return
	var player_IDs = get_IDs()
	
	self_data.name = get_current_player_display_name()

func get_IDs():
	return get_all_participant_IDs().split(',')

func google_sign_in():
	gpgs.signInInteractive()
	
func google_sign_out():
	gpgs.signOut()
	
func is_online():
	return gpgs.isOnline()
	
func get_current_player_ID():
	return gpgs.getCurrentPlayerID()
	
func get_current_player_display_name():
	return gpgs.getCurrentPlayerDisplayName()
	
func get_current_player_id():
	return gpgs.getCurrentPlayerID()
	
func start_quick_game(minPlayers, maxPlayers, role_bitmask):
	print('Starting auto quick match')
	gpgs.rtmStartQuickGame(minPlayers, maxPlayers, role_bitmask)
	
func get_all_participant_IDs():
	return gpgs.rtmGetAllParticipantIDs()
	
### google callbacks ###	
func _on_play_game_services_sign_in_success(signInType, playerID):	
	print("GPGS Sign In Succeeded!")
	start_quick_game(2, 2, 0)
	
func _on_play_game_services_sign_in_failure(signInType):
	print('GPGS Sign In Failed')
	
func _on_play_game_services_sign_out(success):
	print('GPGS Player Signed Out')
	
func _on_play_game_services_rtm_room_client_created(success,roomID):
	print('Auto quick room created')
	
func _on_play_game_services_rtm_room_all_participants_connected(success,roomID):
	print('All participants connected in quick match')
	connected_init_match()
### end google callbacks ###

func create_server(player_nickname):
	self_data.name = player_nickname
	players[1] = self_data
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ Local Server Created!")
	get_tree().set_network_peer(peer)

func connect_to_server(player_nickname):
	self_data.name = player_nickname
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ Local Server Connected!")
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ Local Client Created!")
	get_tree().set_network_peer(peer)

func _connected_to_server():
	players[get_tree().get_network_unique_id()] = self_data
	rpc('_send_player_info', get_tree().get_network_unique_id(), self_data)

func _on_player_disconnected(id):
	print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ Local Player Disconnected!")
	players.erase(id)

remote func _send_player_info(id, info):
	if get_tree().is_network_server():
		for peer_id in players:
			rpc_id(id, '_send_player_info', peer_id, players[peer_id])
	players[id] = info
	
	var new_player = load('res://player/Player.tscn').instance()
	new_player.name = str(id)
	new_player.set_network_master(id)
	$'/root/Game/'.add_child(new_player)
	new_player.init(info.name, info.position, true)

func update_position(id, position):
	players[id].position = position
	
func update_rotation(id, rotation):
	players[id].rifle_rotation = rotation