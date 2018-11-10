extends Node2D

enum PLAYER_TYPE {
	human,
	skeleton,
	bandit	
	}

var player_type = PLAYER_TYPE.skeleton
var enable_ultra_graphics = false
var match_1v1 = true