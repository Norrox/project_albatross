extends KinematicBody2D

const MOVE_SPEED = 250.0
const MAX_HP = 100
const ROLL_WAIT_TIME = 0.5
const MIN_MOVE_DIST = 5

var is_master = false
var ID = "No_ID"
var health_points = MAX_HP
var animation = 'idle'
var last_animation = ''
var direction = Vector2()
var rifle_rotation = 0
var last_rifle_rotation = 0
var dead = false
var rolling = false
var can_roll = true

func _ready():
	pass
	#_update_health_bar(MAX_HP)

func _physics_process(delta):
	direction = Vector2()
	
	if is_master:		
		direction += $'/root/Game'.get_node("CanvasLayer").stick1_vector
		last_rifle_rotation = rifle_rotation
		rifle_rotation = $'/root/Game'.get_node("CanvasLayer").stick2_angle
	
		if Input.is_action_pressed('roll'):
			_roll()

		last_animation = animation
		if !dead and !rolling and direction != Vector2():
			animation = 'run'
		elif rolling:
			animation = 'roll'
		elif dead:
			animation = 'die'
		elif direction == Vector2():
			animation = 'idle'
				
		_move(direction)
		_rotate_gun(rifle_rotation)
		_animate(animation)
		
		if !$'/root/Game'.force_local:
			Network.update_position(global_position)
			Network.update_anim(animation)
			Network.update_gun_angle(rifle_rotation)		
			if last_animation != animation:
				Network.google_send_reliable({ anim = animation })
				
			if direction != Vector2() or last_rifle_rotation != rifle_rotation:	
				Network.google_send_unreliable({ position = global_position, rotation = rifle_rotation })
	else:
		var slave_info = Network.players[ID]
		var slave_position = slave_info.position
		var slave_animation = slave_info.animation
		var slave_rifle_rotation = slave_info.rifle_rotation
		
		var slave_interpolated = global_position.linear_interpolate(slave_position, 0.5)
		var network_difference = slave_interpolated.distance_to(global_position)
		var slave_direction = slave_interpolated - global_position
		
		if network_difference > MIN_MOVE_DIST:
			_move(slave_direction)
		else:
			#need to move to exact position over time here
			pass
			
		_rotate_gun(slave_rifle_rotation)
		_animate(slave_animation)

func _animate(animation):
	play_anim(animation)

func _rotate_gun(rotation):
	$Rifle.rotation = rotation
	if check_flip():
		_player_left()
		_rifle_left()
	else:
		_player_right()
		_rifle_right()
	
func check_flip():
	var rot = int($Rifle.rotation_degrees) % 360
	if rot > -90 and rot < 90:
		return false
	elif (rot > -270 and rot < -90) or (rot > 90 and rot < 270):
		return true
		

func _move(direction):
	direction = direction.normalized() * MOVE_SPEED
	move_and_slide(direction)

func _player_right():
	$Sprite.flip_h = false
	
func _player_left():
	$Sprite.flip_h = true

func _rifle_right():
	$Rifle.flip_v = false

func _rifle_left():
	$Rifle.flip_v = true

func _update_health_bar(hp):
	$GUI_Node/GUI/HealthBar.value = hp
	if !$'/root/Game'.force_local:
		Network.update_health(hp)
		Network.google_send_reliable({ health = hp })	

func _roll():
	if !can_roll:
		return
	rolling = true
	can_roll = false
	yield($AnimationPlayer,"animation_finished")
	rolling = false
	yield( get_tree().create_timer(ROLL_WAIT_TIME), "timeout" )
	can_roll = true

func damage(value):
	health_points -= value
	if health_points <= 0:
		health_points = 0
		Network.google_send_reliable({ die = true })
		_die()
	_update_health_bar(health_points)

func _die():
	dead = true
	yield($AnimationPlayer,"animation_finished")
	dead = false
	$RespawnTimer.start()
	set_physics_process(false)
	$Rifle.set_process(false)
	for child in get_children():
		if child.has_method('hide'):
			child.hide()
	$CollisionShape2D.disabled = true

func _on_RespawnTimer_timeout():
	set_physics_process(true)
	$Rifle.set_process(true)
	for child in get_children():
		if child.has_method('show'):
			child.show()
	$CollisionShape2D.disabled = false
	health_points = MAX_HP
	_update_health_bar(health_points)

func init(nickname, start_position, is_slave):
	$GUI_Node/GUI/Nickname.text = nickname
	global_position = start_position
	if is_slave:

		$Sprite.texture = load('res://player/player.png')
		
func play_anim(animation):
	if animation == $AnimationPlayer.current_animation:
		return
	$AnimationPlayer.play(animation)