extends BrainArea


func _ready():
	prepare_to_learn()


func _on_Level_game_advanced(level):
	if !level.is_AI_turn():
		return

	var current_board_state = [0, 0, 0, 0, 0, 0, 0, 0, 0]

	for i in range(9):
		if level.board_matrix[i] == level.Mark.TIC:
			current_board_state[i] = -1
		elif level.board_matrix[i] == level.Mark.TAC:
			current_board_state[i] = 1

	var output := guess( current_board_state )

	var expected = explain_rules(current_board_state, output)

	var error = learn(current_board_state, expected, 0.05)

	var spot_id := get_spot(output)

	level.AI_put_mark_id(spot_id)

	print("current_board_state: ", current_board_state)
	print_synaptic("Guess: ", output)
	print("Expected: ", expected)
	print("Error: ", error)
	print("Spot: ", spot_id)


func print_synaptic(msg, _guess: SynapticTerminals):
	var s := "["
	for i in range(_guess.terminal_count()):
		s += String(_guess.get_value(i)) + ","
	s += "]"
	print(msg, s)


func explain_rules(current_board_state, _guess: SynapticTerminals):
	var expected = [0, 0, 0, 0, 0, 0, 0, 0, 0]
	for i in range(9):
		if 0.2 < abs(current_board_state[i]):
			expected[i] = 0
		else:
			expected[i] = _guess.get_value(i)
	return expected


func get_spot(_guess: SynapticTerminals) -> int:
	var spot := 0
	var h_value := 0.0
	for i in range(9):
		if h_value < _guess.get_value(i):
			spot = i
			h_value = _guess.get_value(i)
	return spot
