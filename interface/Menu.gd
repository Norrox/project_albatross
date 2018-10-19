extends Control

var _player_name = ""

func _on_TextField_text_changed(new_text):
	_player_name = new_text

func _on_SignInButton_pressed():
	Network.google_sign_in()
	
func _on_SignOutButton_pressed():
	Network.google_sign_out()

func _load_game():
	get_tree().change_scene('res://Game.tscn')
