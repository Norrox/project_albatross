extends Control

var button_busy = false

func _ready():
	if OS.get_name() == 'Windows':
		Network.ready = true
		#Global.goto_scene('res://Game.tscn')
		#Global.goto_scene('res://GrassLevel.tscn')
		Global.goto_scene('res://SpaceLevel.tscn')
	else:
		Settings.player_type = Settings.PLAYER_TYPE.skeleton

func _load_game():
	if Settings.match_type == Settings.MATCH_TYPE.one_verse_one:
		Global.goto_scene('res://GrassLevel.tscn')
	elif Settings.match_type == Settings.MATCH_TYPE.ffa_8:
		Global.goto_scene('res://Game.tscn')
	else:
		Global.goto_scene('res://SpaceLevel.tscn')

func _on_SpinBox_value_changed(value):
	print("~~~~~~~~~~~MIN_PLAYERS_CHANGED~~~~~~~~~" + str(value))
	Network.MIN_PLAYERS = int(value)

func _on_QuickMatchButton_pressed():
	if button_busy:
		return
	if Network.quick_match_started:
		Network.google_show_waiting_room()
		return
	button_busy = true
	if !Network.signed_in:
		try_sign_in()
		wait_till_signed_in()
	#connected - start quick match
	Network.start_quick_game(Network.MIN_PLAYERS, Network.MAX_PLAYERS, 0)
	Network.quick_match_started = true
	button_busy = false

func _on_SignOutButton_pressed():
	if Network.signed_in:
		Network.google_clear_cache()
		Network.google_sign_out()
		
func try_sign_in():
	if !Network.signing_in_busy:
		print('Not signed in or trying to sign in.. signing in interactive')
		Network.google_sign_in()
	else:
		print('sign in already in progress.. busy')
		
func wait_till_signed_in():
	while !Network.signed_in:
		yield(get_tree().create_timer(0.02),'timeout')		


func _on_SkeletonButton_pressed():
	Settings.player_type = Settings.PLAYER_TYPE.skeleton
	$Panel/PlayerStats/PlayerEnlarged.texture = preload('res://player/skeleton/idle1.png')
	$Panel/PlayerStats/PlayerEnlarged.offset = Vector2(0,-0.5)
	$Panel/PlayerStats/PlayerEnlarged/Weapon.texture = load('res://player/skeleton/weapon/weapon.png')
	$Panel/PlayerStats/PlayerEnlarged/Weapon.offset = Vector2(0,-0.5)
	$Panel/PlayerStats/PlayerEnlarged/Weapon.rotation_degrees = 18.5
	
	$Panel/PlayerStats/Text/Phrase.text = 'Six Feet of Earth Makes Us All Equal'
	$Panel/PlayerStats/Text/WeaponName.text = 'BLOOD WAND'
	$Panel/PlayerStats/Text/WeaponDescriptionPos.text = 'Expands\n\nNo Recoil'
	$Panel/PlayerStats/Text/WeaponDescriptionNeg.text = '\n\n\n\nSlow'

func _on_HumanButton_pressed():
	Settings.player_type = Settings.PLAYER_TYPE.human
	$Panel/PlayerStats/PlayerEnlarged.texture = preload('res://player/human/sprites/Idle_idle_0.png')
	$Panel/PlayerStats/PlayerEnlarged.offset = Vector2(-1,0)
	$Panel/PlayerStats/PlayerEnlarged/Weapon.texture = preload('res://player/human/weapons/rifle/main gun_Gun_0.png')
	$Panel/PlayerStats/PlayerEnlarged/Weapon.offset = Vector2(1,-3)
	$Panel/PlayerStats/PlayerEnlarged/Weapon.rotation = 0
	
	$Panel/PlayerStats/Text/Phrase.text = 'Keep a stiff upper lip'
	$Panel/PlayerStats/Text/WeaponName.text = 'PSYONIX'
	$Panel/PlayerStats/Text/WeaponDescriptionPos.text = 'Fast\n\nMove Steady'
	$Panel/PlayerStats/Text/WeaponDescriptionNeg.text = '\n\n\n\nStand Recoil'


func _on_BanditButton_pressed():
	Settings.player_type = Settings.PLAYER_TYPE.bandit
	$Panel/PlayerStats/PlayerEnlarged.texture = preload('res://player/bandit/idle_idle_0.png')
	$Panel/PlayerStats/PlayerEnlarged.offset = Vector2(0.5,-1)
	$Panel/PlayerStats/PlayerEnlarged/Weapon.texture = preload('res://player/bandit/weapon/gun_gun_0.png')
	$Panel/PlayerStats/PlayerEnlarged/Weapon.offset = Vector2(-2.0,-4)
	$Panel/PlayerStats/PlayerEnlarged/Weapon.rotation = 0
	
	$Panel/PlayerStats/Text/Phrase.text = 'There is a method in man\'s wickedness'
	$Panel/PlayerStats/Text/WeaponName.text = 'DEAD LEAD'
	$Panel/PlayerStats/Text/WeaponDescriptionPos.text = 'Fastest\n\nNo Recoil'
	$Panel/PlayerStats/Text/WeaponDescriptionNeg.text = '\n\n\n\nSmall'

func _on_Match1v1Button_pressed():
	if Network.quick_match_started:
		$ErrorSound.play()
		return
	Settings.match_type = Settings.MATCH_TYPE.one_verse_one
	Network.MIN_PLAYERS = 1
	Network.MAX_PLAYERS = 1


func _on_MatchFFAButton_pressed():
	if Network.quick_match_started:
		$ErrorSound.play()
		return
	Settings.match_type = Settings.MATCH_TYPE.ffa_8
	Network.MIN_PLAYERS = 7
	Network.MAX_PLAYERS = 7


func _on_MatchFFA4Button_pressed():
	if Network.quick_match_started:
		$ErrorSound.play()
		return
	Settings.match_type = Settings.MATCH_TYPE.ffa_4
	Network.MIN_PLAYERS = 3
	Network.MAX_PLAYERS = 3
