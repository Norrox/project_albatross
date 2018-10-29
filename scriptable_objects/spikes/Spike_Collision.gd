extends Area2D

const SPIKE_DAMAGE = 5

var is_in_spikes = false
var can_damage = true
var player_body = null

func _ready():
	connect('body_entered', self, '_on_body_entered')
	connect('body_exited', self, '_on_body_exited')
	
func _process(delta):
	if is_in_spikes and can_damage:
		if $'../AnimationPlayer'.current_animation == 'up' and !player_body.rolling:
			player_body.damage(SPIKE_DAMAGE)
			can_damage = false
			yield(get_tree().create_timer(1), "timeout")
			can_damage = true
			
func _on_body_entered(body):
	if body.is_in_group('players'):
		is_in_spikes = true
		player_body = body
	
func _on_body_exited(body):
	is_in_spikes = false
	player_body = null