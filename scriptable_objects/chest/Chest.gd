extends StaticBody2D

var opening = false
var item_res = null

func _ready():
	$AnimationPlayer.play('idle')
	var item = get_item()
	item_res = load("res://scriptable_objects/powerups/" + item + ".tscn")
	
func open(player):
	if opening or check_net_is_claimed():
		return
	send_net_chest_num(player)
	opening = true
	$AnimationPlayer.play('open')
	check_player_master_and_anim_item(player)
		
	yield($AnimationPlayer,'animation_finished')
	opening = false
	
func check_player_master_and_anim_item(player):
	if player.is_master:
		animate_item(player)
	else:
		animate_item()
		
func send_net_chest_num(player):
	if Network.force_local and player.is_master:
		Network.google_send_reliable( { chest_num = get_chest_number() } )
	Network.chests[get_chest_number() - 1] = true
	
func check_net_is_claimed():
	return Network.chests[get_chest_number()-1]
	
func animate_item(player=null):
	var item_spawn = item_res.instance()
	add_child(item_spawn)
	item_spawn.spawned = true
	item_spawn.intended_player = player
	
func get_chest_number():
	var chest_name = self.name
	var length = len(chest_name)
	return int(chest_name.substr(length-1, length))
	
func get_item():
	#only one item now use random later
	return 'Health'