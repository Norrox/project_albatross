extends Sprite

var RADIUS = 0
var SMALL_RADIUS = 0
const RADIUS_ALLOWANCE = 300
const PLACEMENT_OFFSET = 110

var stick1_pos = Vector2()
var stick2_pos = Vector2()
var left_event_pos = Vector2()
var right_event_pos = Vector2()
var player_name = ""

func _ready():
	if !$'/root/Game'.force_local:
		player_name = Network.get_current_player_display_name()
	else:
		player_name = 'test'
	position.x = PLACEMENT_OFFSET
	position.y = get_viewport().size.y - PLACEMENT_OFFSET
	stick1_pos = $Analog_Small.global_position
	var right_stick = get_node("../Analog_Big_Right")
	right_stick.position.x = get_viewport().size.x - PLACEMENT_OFFSET
	right_stick.position.y = get_viewport().size.y - PLACEMENT_OFFSET
	stick2_pos = right_stick.get_node("Analog_Small").global_position
	RADIUS = texture.get_height() / 2
	SMALL_RADIUS = 13

func _input(event):
    if event is InputEventMouseButton and event.is_action_released('shoot'):
        $Analog_Small.position = Vector2()
        $"../".stick1_vector = Vector2()
        $"../".stick1_speed = 0

    if event is InputEventScreenDrag and event.index >= 0:
       if stick1_pos.distance_to(event.position) < RADIUS + RADIUS_ALLOWANCE:
            left_event_pos = event.position
            move_analog_small(left_event_pos, 0)
       if stick2_pos.distance_to(event.position) < RADIUS + RADIUS_ALLOWANCE:
            right_event_pos = event.position
            move_analog_small(right_event_pos, 1)
		
func move_analog_small(event_pos, stick):
    if stick == 0:
        var dist = stick1_pos.distance_to(event_pos)
        
        if dist + SMALL_RADIUS > RADIUS:
            dist = RADIUS - SMALL_RADIUS
			
        var vect = (event_pos - stick1_pos).normalized()

        $"../".stick1_vector = vect
        $"../".stick1_speed = dist
		
        $Analog_Small.position = vect * dist
    elif stick == 1:
        var dist = stick2_pos.distance_to(event_pos)
        
        if dist + SMALL_RADIUS > RADIUS:
            dist = RADIUS - SMALL_RADIUS
            $'/root/'.get_node(player_name).get_node("Rifle").shoot = true
        else:
            $'/root/'.get_node(player_name).get_node("Rifle").shoot = false
			
        var vect = (event_pos - stick2_pos).normalized()
        var angle = event_pos.angle_to_point(stick2_pos)

        $"../".stick2_vector = vect
        $"../".stick2_speed = dist
        $"../".stick2_angle = angle
		
        $"../Analog_Big_Right/Analog_Small".position = vect * dist
