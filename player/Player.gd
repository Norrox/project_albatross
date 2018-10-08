extends KinematicBody2D

const MOVE_SPEED = 250.0
const MAX_HP = 100

#enum MoveDirection { UP, DOWN, LEFT, RIGHT, NONE }

slave var slave_position = Vector2()
slave var slave_movement = Vector2()
slave var slave_mouse_pos = Vector2()
slave var slave_animation = 'idle'

var health_points = MAX_HP
var mouse_pos = Vector2()
var animation = 'idle'
var dead = false
var rolling = false

func _ready():
	_update_health_bar()

func _physics_process(delta):
	var direction = Vector2()
	
	if is_network_master():		
		mouse_pos = get_global_mouse_position()
	
		if Input.is_action_pressed('left'):
			direction += Vector2(-1, 0)
		if Input.is_action_pressed('right'):
			direction += Vector2(1, 0)
		if Input.is_action_pressed('up'):
			direction += Vector2(0, -1)
		if Input.is_action_pressed('down'):
			direction += Vector2(0, 1)
		
		if Input.is_action_pressed('roll'):
			_roll()

		if !dead and !rolling and direction != Vector2():
			animation = 'run'
		elif rolling:
			animation = 'roll'
		elif dead:
			animation = 'die'
		elif direction == Vector2():
			animation = 'idle'
				
		rset_unreliable('slave_position', position)
		rset('slave_movement', direction)
		rset('slave_mouse_pos', mouse_pos)
		rset('slave_animation', animation)
		_move(direction)
		_rotate_gun(mouse_pos)
		_animate(animation)
	else:
		_move(slave_movement)
		_rotate_gun(slave_mouse_pos)
		_animate(slave_animation)
		position = slave_position
		mouse_pos = slave_mouse_pos
		animation = slave_animation
	
	if get_tree().is_network_server():
		var player_id = int(name)
		Network.update_position(player_id, position)
		Network.update_rotation(player_id, $Rifle.rotation)

func _animate(animation):
	play_anim(animation)

func _rotate_gun(mouse_pos):
	$Rifle.look_at(mouse_pos)
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

func _update_health_bar():
	$GUI/HealthBar.value = health_points

sync func _roll():
	rolling = true
	yield($AnimationPlayer,"animation_finished")
	rolling = false

func damage(value):
	health_points -= value
	if health_points <= 0:
		health_points = 0
		rpc('_die')
	_update_health_bar()

sync func _die():
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
	_update_health_bar()

func init(nickname, start_position, is_slave):
	$GUI/Nickname.text = nickname
	global_position = start_position
	if is_slave:
		$Sprite.texture = load('res://player/player.png')
		
func play_anim(animation):
	if animation == $AnimationPlayer.current_animation:
		return
	$AnimationPlayer.play(animation)