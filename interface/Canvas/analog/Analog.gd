extends Sprite

var RADIUS = 0
var SMALL_RADIUS = 0
const RADIUS_ALLOWANCE = 55
const PLACEMENT_OFFSET = 120
const SCREEN_SIZE = Vector2(1152, 648)
const ROLL_BTN_OFFSET = Vector2(-50, -250)

var stick1_pos = Vector2()
var stick2_pos = Vector2()
var left_event_pos = Vector2()
var right_event_pos = Vector2()
var player_name = ""
var rifle = null

func _ready():
	if !Network.force_local:
		player_name = Network.get_current_player_display_name()
	else:
		player_name = 'test'
		
	while $'/root/'.get_node(player_name) == null:
		yield(get_tree().create_timer(0.02), "timeout")
	rifle = $'/root/'.get_node(player_name).get_node("Pivot").get_node("Rifle")
	
	position.x = PLACEMENT_OFFSET
	position.y = SCREEN_SIZE.y - PLACEMENT_OFFSET
	stick1_pos = $Analog_Small.global_position
	var right_stick = get_node("../Analog_Big_Right")
	right_stick.position.x = SCREEN_SIZE.x - PLACEMENT_OFFSET
	right_stick.position.y = SCREEN_SIZE.y - PLACEMENT_OFFSET
	stick2_pos = right_stick.get_node("Analog_Small").global_position
	
	var roll_button = $'../Roll_Button'
	roll_button.position = stick2_pos
	roll_button.position += ROLL_BTN_OFFSET
	
	RADIUS = texture.get_height() / 2
	SMALL_RADIUS = 13
	
func _input(event):
	if (event is InputEventMouseButton and event.is_action_released('shoot') or (event is InputEventScreenTouch and !event.is_pressed())):
		if $Analog_Small.global_position.distance_to(event.position) < get_node("../Analog_Big_Right/Analog_Small").global_position.distance_to(event.position):
			reset_left_stick()
		else:
			reset_right_stick()

	if event is InputEventScreenDrag and event.index >= 0:
		move_sticks(event)
			
func reset_left_stick():
	$Analog_Small.position = Vector2()
	$"../".stick1_vector = Vector2()
	$"../".stick1_speed = 0
	
func reset_right_stick():
	get_node("../Analog_Big_Right/Analog_Small").position = Vector2()
	rifle.shoot = false
	$"../".stick2_vector = Vector2()
	$"../".stick2_speed = 0
	
func move_sticks(event):
	if stick1_pos.distance_to(event.position) < RADIUS + RADIUS_ALLOWANCE:
		left_event_pos = event.position
		move_analog_small(left_event_pos, 0)
		
	if stick2_pos.distance_to(event.position) < RADIUS + RADIUS_ALLOWANCE:
		right_event_pos = event.position
		move_analog_small(right_event_pos, 1)
		
func move_analog_small(event_pos, stick):
	if stick == 0:
		move_left_stick(event_pos)
	elif stick == 1:
		move_right_stick(event_pos)
		
func move_left_stick(event_pos):
	var dist = stick1_pos.distance_to(event_pos)
    
	if dist + SMALL_RADIUS > RADIUS:
		dist = RADIUS - SMALL_RADIUS
		
	var vect = (event_pos - stick1_pos).normalized()

	$"../".stick1_vector = vect
	$"../".stick1_speed = dist
	
	$Analog_Small.position = vect * dist
	
func move_right_stick(event_pos):
	var dist = stick2_pos.distance_to(event_pos)
        
	if dist + SMALL_RADIUS > RADIUS:
		dist = RADIUS - SMALL_RADIUS
		rifle.shoot = true
	else:
		rifle.shoot = false
		
	var vect = (event_pos - stick2_pos).normalized()
	var angle = event_pos.angle_to_point(stick2_pos)

	$"../".stick2_vector = vect
	$"../".stick2_speed = dist
	$"../".stick2_angle = angle
	
	$"../Analog_Big_Right/Analog_Small".position = vect * dist