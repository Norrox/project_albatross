extends Node2D

enum PLAYER_TYPE {
	human,
	skeleton,
	bandit	
	}
	
enum MATCH_TYPE {
	one_verse_one,
	ffa_4,
	ffa_8
	}

var player_type = PLAYER_TYPE.human
var enable_ultra_graphics = false
var match_type = MATCH_TYPE.ffa_8