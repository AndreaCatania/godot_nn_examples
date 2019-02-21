extends AnimationPlayer


func _on_Level_game_started(level):
	seek(0.2, true)


func _on_Level_game_finished(level):
	if level.is_player1_won():
		play_backwards("won")
	elif level.is_AI_won():
		play("won")
