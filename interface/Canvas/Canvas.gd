extends CanvasLayer

var stick1_speed = 0
var stick1_vector = Vector2()
var stick2_speed = 0
var stick2_vector = Vector2()
var stick2_angle = 0

var fps = 48

onready var lb_fps = $L_fps

func _on_TouchScreenButton_pressed():
	$'/root/'.get_node(Network.self_data.name).start_roll = true

func _process(delta):
	fps = Engine.get_frames_per_second()
	lb_fps.set_text(str(fps))

func _on_FPSTimer_timeout():
	$FPSTimer.start()
	
	if  fps < 29:
		print('setting target fps to 30')
		Engine.target_fps = 30
