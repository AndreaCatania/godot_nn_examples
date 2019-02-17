extends Node


func _on_Level_game_advanced(level):
	if !level.is_AI_turn():
		return

	yield(get_tree().create_timer(0.5), "timeout")

	for r in range(3):
		for c in range(3):
			if level.AI_put_mark(r, c):
				return
