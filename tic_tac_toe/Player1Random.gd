extends Node


func _on_Level_game_started(level):
	if !level.auto_train:
		return
	_on_Level_game_advanced(level)


func _on_Level_game_advanced(level):
	if !level.auto_train:
		return

	if !level.is_player1_turn():
		return

	var rm = random_move(level.get_current_board_state(-1, 1))
	if rm >= 0:
		level.player_put_mark_id(rm)


func random_move(current_board_state) -> int:
	var free_cells = []
	for i in range(9):
		if 0.2 > abs(current_board_state[i]):
			free_cells.push_back(i)

	if free_cells.size() > 0:
		return free_cells[randi()%free_cells.size()]
	return -1
