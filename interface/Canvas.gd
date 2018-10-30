extends CanvasLayer

var stick1_speed = 0
var stick1_vector = Vector2()
var stick2_speed = 0
var stick2_vector = Vector2()
var stick2_angle = 0

onready var lb_fps = $L_fps

func _process(delta):
	#DEBUG: FPS Counter UI Label
	lb_fps.set_text(str(Engine.get_frames_per_second()))

func _on_TouchScreenButton_pressed():
	$'/root/'.get_node(Network.self_data.name).start_roll = true
