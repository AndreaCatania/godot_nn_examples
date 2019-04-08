extends Node2D

signal goal_received(player)
signal ball_outside()

export(NodePath) var goal_player1_path
export(NodePath) var goal_player2_path
export(NodePath) var spawn_player1_path
export(NodePath) var spawn_player2_path
export(NodePath) var spawn_ball_path
export(NodePath) var audio_player_goal_p1
export(NodePath) var audio_player_goal_p2


""" NOTIFICATIONS """

func _on_GoalPlayer1_body_entered(body):
	emit_signal("goal_received", Globals.Player1)
	#get_node(audio_player_goal_p1).play()


func _on_GoalPlayer2_body_entered(body):
	emit_signal("goal_received", Globals.Player2)
	#get_node(audio_player_goal_p2).play()

""" PUBLIC """


func get_goal(player) -> Node2D:
	var goal: Node2D
	if player == Globals.Player1:
		goal = get_node(goal_player1_path)
	else:
		goal = get_node(goal_player2_path)
	return goal


func get_spawn(player) -> Node2D:
	var spawn: Node2D
	if player == Globals.Player1:
		spawn = get_node(spawn_player1_path)
	else:
		spawn = get_node(spawn_player2_path)
	return spawn


func get_ball_spawn() -> Node2D:
	return get_node(spawn_ball_path) as Node2D


func get_ball_kick_direction():
	return Vector2(
		max(randf()+0.3, 1.0)*sign(randf()-0.5),
		randf()*0.5)


func _on_PlayeableArea_body_exited(body):
	if body is Ball:
		emit_signal("ball_outside")
