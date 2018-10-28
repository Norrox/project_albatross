extends KinematicBody2D

const JITTER = 1
const MOVE_SPEED = 250.0
const MAX_HP = 100
const ROLL_WAIT_TIME = 0.5
const MIN_MOVE_DIST = 5

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

func _physics_process(delta):
	direction = Vector2()
	
	if is_master:		
		set_master_info()
		
		if Input.is_action_pressed('roll'):
			_roll()
		
		update_net_self_data()
		send_net_data()
		
		_move(direction)
		_rotate_gun(rifle_rotation)
		play_anim(animation)
	else:
		update_slave_data(Network.players[ID])
		
		var slave_interpolated = global_position.linear_interpolate(slave_position, 0.5)
		var network_difference = slave_interpolated.distance_to(global_position)
		var slave_direction = slave_interpolated - global_position
		
		if network_difference > MIN_MOVE_DIST:
			_move(slave_direction)
		elif network_difference > JITTER and network_difference <= MIN_MOVE_DIST:
			_move(slave_position - global_position)
			
		_rotate_gun(slave_rifle_rotation)
		play_anim(slave_animation)

func set_master_info():
	direction += canvas.stick1_vector
	last_rifle_rotation = rifle_rotation
	rifle_rotation = canvas.stick2_angle
	decide_animation()
	
func send_net_data():
	if $'/root/Game'.force_local:
		return	
	if last_animation != animation:
		Network.google_send_unreliable({ anim = animation })

	if direction != Vector2() or last_rifle_rotation != rifle_rotation:	
		Network.google_send_unreliable({ position = global_position, rotation = rifle_rotation })
		
func update_net_self_data():
	if $'/root/Game'.force_local:
		return	
	Network.update_position(global_position)
	Network.update_anim(animation)
	Network.update_gun_angle(rifle_rotation)
	Network.update_health(health_points)

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
	
func play_anim(animation):
	if animation == $AnimationPlayer.current_animation:
		return
	$AnimationPlayer.play(animation)

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
	if is_master:
		dead = true
		animation = 'die'
		update_reliable('update_player_death')
		
	yield(get_tree().create_timer(0.02), 'timeout')	
	yield($AnimationPlayer,"animation_finished")
	$RespawnTimer.start()
	set_physics_process(false)
	$Rifle.set_process(false)
	for child in get_children():
		if child.has_method('hide'):
			child.hide()
	$CollisionShape2D.disabled = true
	
func _on_RespawnTimer_timeout():
	$RespawnTimer.stop()
	if is_master:
		dead = false
		animation = 'idle'
		play_anim(animation)
		health_points = MAX_HP
		_update_health_bar(health_points)
		update_reliable('update_player_health')
		
	set_physics_process(true)
	$Rifle.set_process(true)
	for child in get_children():
		if child.has_method('show'):
			child.show()
	$CollisionShape2D.disabled = false

func update_reliable(action=''):
	if !$'/root/Game'.force_local and is_master:
		update_net_self_data()
		Network.self_data.action = action
		Network.google_send_reliable(Network.self_data)		