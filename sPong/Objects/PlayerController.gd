extends Node


var level: GameLevel = null
var player: Player = null


""" PUBLIC """


func init(p_level: GameLevel, p_player: Player):
	level = p_level
	player = p_player


""" NOTIFICATIONS """


func _process(delta):
	if player == null:
		return

	var motion := 0.0

	if Input.is_action_pressed("Player1MoveUp"):
		motion -= 1

	if Input.is_action_pressed("Player1MoveDown"):
		motion += 1

	player.move(motion)
