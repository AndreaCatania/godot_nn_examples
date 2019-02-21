extends BrainArea

export(bool) var learn_on_lose := true

var board_states = []
var player_moves = []

const knowledge_file_name = "res://knowledge/knw_200_100.knw"

func _ready():
	prepare_to_learn()
	load_knowledge(knowledge_file_name)


func _on_Level_game_started(level):
	_on_Level_game_advanced(level)


func _on_Level_game_advanced(level):
	if !level.is_AI_turn():
		return

	# Normal move
	var current_board_state = level.get_current_board_state(-1, 1)

	var cell_id
	var i = 0
	while true:
		i += 1
		cell_id = guess_move(current_board_state)
		if level.is_cell_void(cell_id):
			break
	print("Normal move cycles count: ", i)

	# Check if next move make AI win
	var board_matrix = level.board_matrix.duplicate()
	board_matrix[cell_id] = level.Mark.TAC
	if level.check_win_on_matrix(board_matrix) == level.Mark.TAC:
		# AI with next move win
		put_mark_and_learn(level, current_board_state, cell_id)
		return

	# Counter attack move
	var opponent_current_board_state = level.get_current_board_state(1, -1)
	var opponent_cell_id
	var o_i = 0
	while true:
		o_i += 1
		opponent_cell_id = guess_move(opponent_current_board_state)
		if level.is_cell_void(opponent_cell_id):
			break
	print("Counter move cycles count: ", o_i)

	# Check if next move make Player1 win
	board_matrix = level.board_matrix.duplicate()
	board_matrix[opponent_cell_id] = level.Mark.TIC
	if level.check_win_on_matrix(board_matrix) == level.Mark.TIC:
		# If player is going to win block it
		put_mark_and_learn(level, current_board_state, opponent_cell_id)
		return

	# Nothing special just normal move
	level.AI_put_mark_id(cell_id)


func put_mark_and_learn(level, current_board_state, cell_id):
	level.AI_put_mark_id(cell_id)
	var expected_move = [0, 0, 0, 0, 0, 0, 0, 0, 0]
	expected_move[cell_id] = 1
	learn(current_board_state, expected_move, 0.1)


func _on_Level_player1_move(level, cell_id):
	if !learn_on_lose:
		return

	var opponent_current_board_state = level.get_current_board_state(1, -1) # Inverted marks

	opponent_current_board_state[cell_id] = 0

	board_states.push_back(opponent_current_board_state)
	player_moves.push_back(cell_id)


func _on_Level_game_finished(level):
	if level.is_AI_won():
		board_states.clear()
		player_moves.clear()
		return

	var good_game = clamp(1.0 - board_states.size() / 7.0, 0.0, 1.0)

	for i in range(board_states.size()):
		var expected_move = [0, 0, 0, 0, 0, 0, 0, 0, 0]
		expected_move[player_moves[i]] = 1
		learn(board_states[i], expected_move, 0.005 + 0.12 * pow(good_game, 5))

	board_states.clear()
	player_moves.clear()

	save_knowledge(knowledge_file_name, true)


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
			expected[i] = 1
	return expected


func get_cell_id(_guess: SynapticTerminals) -> int:
	var cell_id := 0
	var h_value := 0.0
	for i in range(9):
		if h_value < _guess.get_value(i):
			cell_id = i
			h_value = _guess.get_value(i)
	return cell_id


func guess_move(current_board_state) -> int:
	var output := guess( current_board_state )
	var expected = explain_rules(current_board_state, output)
	var error = learn(current_board_state, expected, 0.005)
	var cell_id := get_cell_id(output)
	return cell_id
