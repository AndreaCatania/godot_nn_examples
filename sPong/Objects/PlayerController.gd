extends Node


var player: Player = null


""" PUBLIC """


func init(p_player: Player):
	player = p_player


""" NOTIFICATIONS """


func _process(delta):
	if Input.is_action_pressed("Player1MoveUp"):
		player.move(Player.MOTION_UP)
	elif Input.is_action_pressed("Player1MoveDown"):
		player.move(Player.MOTION_DOWN)
	else:
		player.move(Player.MOTION_NONE)
