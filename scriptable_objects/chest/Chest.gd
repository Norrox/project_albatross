extends StaticBody2D

var opening = false

func _ready():
	$AnimationPlayer.play('idle')
	
func open(player_name):
	if check_net_is_claimed() or opening:
		return
	opening = true
	$AnimationPlayer.play('open')	
	if !$'/root/Game'.force_local:
		Network.google_send_reliable( { chest_num = get_chest_number() - 1 } )
	
func check_net_is_claimed():
	return Network.chests[get_chest_number()-1]
	
func get_chest_number():
	var chest_name = self.name
	var length = len(chest_name)
	return int(chest_name.substr(length-1, length))