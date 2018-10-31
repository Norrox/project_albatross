extends KinematicBody2D

const JITTER = 1
const MOVE_SPEED = 200.0
const MAX_HP = 100
const ROLL_WAIT_TIME = 0.5
const MIN_MOVE_DIST = 5
const MAX_MOVE_DIST = 20

onready var canvas = $'/root/Game'.get_node("CanvasLayer")
onready var sc_canvas = canvas.get_node('L_debug')

var is_master = false
var ID = "No_ID"
var health_points = MAX_HP
var animation = 'idle'
var last_animation = ''
var direction = Vector2()
var rifle_rotation = 0
var last_rifle_rotation = 0
var start_roll = false
var rolling = false
var can_roll = true
var dead = false

var slave_info = {}
var slave_animation = 'idle'
var slave_position = Vector2()
var slave_rifle_rotation = 0
var slave_hp = MAX_HP

func _ready():
	_update_health_bar(MAX_HP)

func init(nickname, start_position, is_slave):
	$GUI_Node/GUI/Nickname.text = nickname
	global_position = start_position
	if is_slave:
		$Sprite.texture = load('res://player/player.png')
	
func _process(delta):
	if is_master:
		set_master_info()
		update_net_self_data()
		play_anim(animation)
		_rotate_gun(rifle_rotation)
		if start_roll:
			_roll()
	else:
		update_slave_data(Network.players[ID])
		play_anim(slave_animation)
		_rotate_gun(slave_rifle_rotation)
		
func _physics_process(delta):
	if is_master:
		send_net_data()
		_move(direction)
	else:		
		var slave_interpolated = global_position.linear_interpolate(slave_position, 0.5)
		var network_difference = slave_interpolated.distance_to(global_position)
		var slave_direction = slave_interpolated - global_position
		
		if network_difference > MIN_MOVE_DIST and network_difference < MAX_MOVE_DIST:
			_move(slave_direction)
		elif network_difference > JITTER and network_difference <= MIN_MOVE_DIST:
			_move(slave_position - global_position)
		elif network_difference > MAX_MOVE_DIST:
			global_position = Network.players[ID].position		

func set_master_info():
	direction = Vector2()
	direction += canvas.stick1_vector
	last_rifle_rotation = rifle_rotation
	rifle_rotation = canvas.stick2_angle
	decide_animation()

func update_net_self_data():
	if $'/root/Game'.force_local:
		return	
	Network.update_position(global_position)
	Network.update_anim(animation)
	Network.update_gun_angle(rifle_rotation)
	Network.update_health(health_points)
	
func send_net_data():
	if $'/root/Game'.force_local:
		return	
	if last_animation != animation:
		Network.google_send_unreliable({ anim = animation })

	if direction != Vector2() or last_rifle_rotation != rifle_rotation:	
		Network.google_send_unreliable({ position = global_position, rotation = rifle_rotation })
		
func update_reliable(action=''):
	if !$'/root/Game'.force_local and is_master:
		update_net_self_data()
		Network.self_data.action = action
		Network.google_send_reliable(Network.self_data)	

func update_slave_data(slave_info):
	slave_position = slave_info.position
	slave_animation = slave_info.animation
	slave_rifle_rotation = slave_info.rifle_rotation
	slave_hp = slave_info.hp
	$GUI_Node/GUI/HealthBar.value = slave_hp

func decide_animation():
	last_animation = animation
	if !dead and !rolling and direction != Vector2():
		animation = 'run'
	elif rolling:
		animation = 'roll'
	elif dead:
		animation = 'die'
	elif direction == Vector2():
		animation = 'idle'
	
func play_anim(anim):
	if anim == $AnimationPlayer.current_animation:
		return
	$AnimationPlayer.play(anim)
	
func _rotate_gun(rotation):
	$Rifle.rotation = rotation
	if check_flip():
		$Sprite.flip_h = true
		$Rifle.flip_v = true
	else:
		$Sprite.flip_h = false
		$Rifle.flip_v = false
	
func check_flip():
	var rot = int($Rifle.rotation_degrees) % 360
	if rot > -90 and rot < 90:
		return false
	elif (rot > -270 and rot < -90) or (rot > 90 and rot < 270):
		return true

func _move(direction):
	direction = direction.normalized() * MOVE_SPEED
	move_and_slide(direction)

func _roll():
	if !can_roll:
		return
	rolling = true
	can_roll = false
	start_roll = false
	yield($AnimationPlayer,"animation_finished")
	rolling = false
	yield( get_tree().create_timer(ROLL_WAIT_TIME), "timeout" )
	can_roll = true

func _update_health_bar(hp):
	$GUI_Node/GUI/HealthBar.value = hp

func damage(value):
	if is_master:
		health_points -= value
		if health_points <= 0:
			health_points = 0
			_die()
		update_reliable('update_player_health')
		_update_health_bar(health_points)

func _die():
	if dead and is_master:
		return
		
	$RespawnTimer.start()
	set_physics_process(false)
	$Rifle.set_process(false)
	
	if is_master:
		dead = true
		if !$'/root/Game'.force_local:
			update_reliable('update_player_death')
		
	play_anim('die')
	yield($AnimationPlayer,"animation_finished")
	
	hide_player()
	choose_spawn_loc()

func hide_player():
	for child in get_children():
		if child.has_method('hide') and child.name != 'Rifle':
			child.hide()
	$CollisionShape2D.disabled = true	
	
func choose_spawn_loc():
	if is_master:
		randomize()
		var random = randi()%8+1
		var spawn_pos = $'/root/Game/Spawns'.get_node('Spawn' + str(random)).global_position
		global_position = spawn_pos
		if $'/root/Game'.force_local:
			update_reliable('update_player_positions')
	else:
		#move out of view
		global_position = Vector2(-800,-800)
	
func _on_RespawnTimer_timeout():
	if is_master:
		dead = false
		animation = 'idle'
		play_anim(animation)
		health_points = MAX_HP
		_update_health_bar(health_points)
		update_reliable('update_player_health')

	set_physics_process(true)
	$Rifle.set_process(true)
	show_player()
	
func show_player():
	for child in get_children():
		if child.has_method('show'):
			child.show()
	$CollisionShape2D.disabled = false	