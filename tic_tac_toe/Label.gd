extends Label



func _on_Level_game_advanced(level):
	if level.is_player1_turn():
		show()
	else:
		hide()
