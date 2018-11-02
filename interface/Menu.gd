extends Control

func _ready():
	if OS.get_name() == 'Windows':
		get_tree().change_scene('res://Game.tscn')

func _load_game():
	get_tree().change_scene('res://Game.tscn')

func _on_SpinBox_value_changed(value):
	print("~~~~~~~~~~~MIN_PLAYERS_CHANGED~~~~~~~~~" + str(value))
	Network.MIN_PLAYERS = int(value)

func _on_QuickMatchButton_pressed():
	if !Network.signed_in and !Network.signing_in_busy:
		print('Not signed in or trying to sign in.. signing in interactive')
		Network.google_sign_in(false)
	elif !Network.signed_in and Network.signing_in_busy:
		print('Waiting for sign in')
	var delta = 0.0
	while !Network.signed_in:
		yield(get_tree().create_timer(0.02),'timeout')
		delta += 0.02
		if delta > Network.SIGN_IN_WAIT_TIME:
			print('Failed to sign in.. signing out')
			Network.google_sign_out()
			break
	if Network.signed_in:
		print('starting quick match')
		Network.start_quick_game(Network.MIN_PLAYERS, Network.MAX_PLAYERS, 0)
