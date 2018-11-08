extends StaticBody2D

var item_res = null

func _ready():
	$AnimationPlayer.play('idle')
	var item = get_item()
	item_res = load("res://scriptable_objects/powerups/" + item + ".tscn")
	
func open(player):
	if check_net_is_claimed():
		return
	set_network_chest_open()	
	send_net_chest_num(player)
	
	$AnimationPlayer.play('open')
	check_player_master_and_anim_item(player)
	yield(get_tree().create_timer(0.5),"timeout")
	$ChestOpen.play()
	
func set_network_chest_open():
	Network.chests[get_chest_number() - 1] = true
	
func send_net_chest_num(player):
	if !Network.force_local and player.is_master:
		Network.google_send_reliable( { chest_num = get_chest_number() } )
	
func check_player_master_and_anim_item(player):
	if player.is_master:
		animate_item(player)
	else:
		animate_item()
	
func check_net_is_claimed():
	return Network.chests[get_chest_number()-1]
	
func animate_item(player=null):
	var item_spawn = item_res.instance()
	add_child(item_spawn)
	item_spawn.spawned = true
	item_spawn.intended_player = player
	
func get_chest_number():
	return self.name.replace("chest", "").to_int()
	
func get_item():
	#only one item now use random later
	return 'Health'