extends AnimationPlayer


func animate_turn(level):
	if level.is_player1_turn():
		play_backwards("ChangeTurn")
	else:
		play("ChangeTurn")


func _on_Level_game_started(level):
	animate_turn(level)


func _on_Level_game_advanced(level):
	animate_turn(level)
