extends Control

var button_busy = false
var quick_match_started = false

func _ready():
	if OS.get_name() == 'Windows':
		get_tree().change_scene('res://Game.tscn')

func _load_game():
	get_tree().change_scene('res://Game.tscn')

func _on_SpinBox_value_changed(value):
	print("~~~~~~~~~~~MIN_PLAYERS_CHANGED~~~~~~~~~" + str(value))
	Network.MIN_PLAYERS = int(value)

func _on_QuickMatchButton_pressed():
	if !Network.is_online():
		print('not online')
		return
	
	var skip = false
	if Network.signed_in:
		skip = true
	if button_busy or quick_match_started:
		return
	button_busy = true
	if !skip:
		try_sign_in()
		wait_till_signed_in()
		if !Network.signed_in:
			print('failed to sign in')
			return
	#connected - start quick match
	Network.start_quick_game(Network.MIN_PLAYERS, Network.MAX_PLAYERS, 0)
	quick_match_started = true
	button_busy = false

func _on_SignOutButton_pressed():
	if Network.signed_in:
		Network.google_clear_cache()
		Network.google_sign_out()
		
func try_sign_in():
	if !Network.signing_in_busy:
			print('Not signed in or trying to sign in.. signing in interactive')
			Network.google_sign_in(false)
	else:
		print('sign in already in progress.. busy')
		
func wait_till_signed_in():
	var wait_time = 0.0
	while !Network.signed_in:
		if wait_time > Network.SIGN_IN_WAIT_TIME + 0.2:
			print('wait time expired')
			break
		yield(get_tree().create_timer(0.02),'timeout')		
		wait_time += 0.02