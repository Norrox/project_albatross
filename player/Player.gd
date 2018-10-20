extends KinematicBody2D

const MOVE_SPEED = 250.0
const MAX_HP = 100
const ROLL_WAIT_TIME = 0.5

var is_master = false
var ID = "No_ID"
var health_points = MAX_HP
var animation = 'idle'
var direction = Vector2()
var dead = false
var rolling = false
var can_roll = true

var slave_info = {}
var slave_animation = 'idle'
var slave_direction = Vector2()
var slave_position = Vector2()

func _ready():
	_update_health_bar()

func _physics_process(delta):
	direction = Vector2()
	slave_direction = Vector2()
	
	if is_master:		
		direction += get_parent().find_node("CanvasLayer").stick1_vector
	
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
				
		_move(direction)
		_rotate_gun()
		_animate(animation)
		
		Network.update_dir(direction)
		Network.update_position(global_position)
		Network.update_anim(animation)
		#Network.update_gun_angle()		
		#Network.google_send_player_info()
		Network.google_send_unreliable(global_position)
	else:
		var slave_info = Network.players[ID]
		#slave_direction = slaver.direction
		slave_position = Network.players[ID].position
		slave_animation = slave_info.animation
		
		position = slave_position
		#_move(slave_direction)
		#_rotate_gun()
		_animate(slave_animation)

func _animate(animation):
	play_anim(animation)

func _rotate_gun():
	$Rifle.rotation = get_parent().find_node("CanvasLayer").stick2_angle
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
		rpc('_die')
	_update_health_bar()

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