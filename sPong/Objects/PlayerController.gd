extends Node


var level: GameLevel = null
var player: Player = null


""" PUBLIC """


func init(p_level: GameLevel, p_player: Player):
	level = p_level
	player = p_player


""" NOTIFICATIONS """


func _process(delta):
	if Input.is_action_pressed("Player1MoveUp"):
		player.move(Player.MOTION_UP)
	elif Input.is_action_pressed("Player1MoveDown"):
		player.move(Player.MOTION_DOWN)
	else:
		player.move(Player.MOTION_NONE)
