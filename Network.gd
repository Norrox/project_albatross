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

func google_sign_in():
	gpgs.signInInteractive()
	print("GPGS Sign In Succeeded!")

func create_server(player_nickname):
	self_data.name = player_nickname
	players[1] = self_data
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS Server Created!")
	get_tree().set_network_peer(peer)

func connect_to_server(player_nickname):
	self_data.name = player_nickname
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS Server Connected!")
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS Client Created!")
	get_tree().set_network_peer(peer)

func _connected_to_server():
	players[get_tree().get_network_unique_id()] = self_data
	rpc('_send_player_info', get_tree().get_network_unique_id(), self_data)

func _on_player_disconnected(id):
	print("~~~~~~~~~~MY_DEBUG_MESSAGE~~~~~~~~~~ GPGS Player Disconnected!")
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