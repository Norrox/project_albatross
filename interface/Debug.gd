extends Node

onready var lb_debug = $"."

func _ready():
	lb_debug.set_text(lb_debug.get_text() + '\n' + 'Use debug_print() to print here')

func debug_print(msg):
	lb_debug.set_text(lb_debug.get_text() + '\n' + msg)