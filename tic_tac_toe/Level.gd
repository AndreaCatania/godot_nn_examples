extends Node

signal game_started(level)
signal game_advanced(level)
signal game_finished(level)
signal player1_move(level, spot_id)

export(NodePath) var board_path
export(NodePath) var brain_path
export(float) var game_finish_duration = 2.5
export(bool) var auto_train := false

var game_running := false

enum Mark{
	VOID,
	TIC, # Player
	TAC, # AI
}

enum Player{
	Player1,
	AI,
}

var board_matrix = []
onready var board = get_node(board_path)
var current_player
var winner_mark
var prev_player = Player.AI


func player_put_mark(row: int, column: int):
	return player_put_mark_id(get_id(row, column))


func player_put_mark_id(id: int):
	if current_player == Player.Player1:
		if put_mark_id(id, Mark.TIC):
			return true
	return false


func AI_put_mark(row: int, column: int):
	if current_player == Player.AI:
		return put_mark(row, column, Mark.TAC)
	return false


func AI_put_mark_id(id: int):
	if current_player == Player.AI:
		return put_mark_id(id, Mark.TAC)
	return false

func is_player1_turn():
	return current_player == Player.Player1


func is_AI_turn():
	return current_player == Player.AI


func is_player1_won():
	return winner_mark == Mark.TIC


func is_AI_won():
	return winner_mark == Mark.TAC


func is_cell_void(cell_id):
	return board_matrix[cell_id] == Mark.VOID


func get_current_board_state(tic, tac):
	var current_board_state = [0, 0, 0, 0, 0, 0, 0, 0, 0]

	for i in range(9):
		if board_matrix[i] == Mark.TIC:
			current_board_state[i] = tic # Player
		elif board_matrix[i] == Mark.TAC:
			current_board_state[i] = tac # AI

	return current_board_state

# ---------------------------- PRIVATE -------------------------------------


func put_mark(row: int, column: int, player):
	put_mark_id(get_id(row, column), player)


func put_mark_id(id: int, player):
	var val = board_matrix[id]

	if !is_cell_void(id):
		printerr("The cell is not void")
		return false

	board_matrix[id] = player

	board.get_button_by_id(id).set_mark_texture(player == Player.AI)

	if player == Mark.TIC:
		emit_signal("player1_move", self, id)

	advance_game()
	return true


func get_id(row, column):
	return row * 3 + column


func start_game(delay: float):

	game_running = true
	if delay>0.0:
		yield(get_tree().create_timer(delay), "timeout")

	for row in range(3):
		for column in range(3):
			board.get_button(row, column).reset()
	board_matrix = [
		Mark.VOID,Mark.VOID,Mark.VOID,
		Mark.VOID,Mark.VOID,Mark.VOID,
		Mark.VOID,Mark.VOID,Mark.VOID]
	if prev_player == Player.Player1:
		current_player = Player.AI
	else:
		current_player = Player.Player1
	prev_player = current_player
	emit_signal("game_started", self)


func _end_game():
	game_running = false
	emit_signal("game_finished", self)


func check_win() -> bool:
	var winner = check_win_on_matrix(board_matrix)
	if winner != Mark.VOID:
		winner_mark = winner
		_end_game()
		return true
	return false


func check_win_on_matrix(bm):
	# Check vertical
	for row in range(3):
		if bm[get_id(row, 0)] == bm[get_id(row, 1)] &&\
			bm[get_id(row, 0)] == bm[get_id(row, 2)] &&\
			bm[get_id(row, 0)] != Mark.VOID:
			return bm[get_id(row, 0)]

	# Check horizontal
	for column in range(3):
		if bm[get_id(0, column)] == bm[get_id(1, column)] &&\
			bm[get_id(0, column)] == bm[get_id(2, column)]&&\
			bm[get_id(0, column)] != Mark.VOID:
			return bm[get_id(0, column)]

	# Check oblique
	if bm[get_id(0, 0)] == bm[get_id(1, 1)] &&\
		bm[get_id(1, 1)] == bm[get_id(2, 2)]&&\
			bm[get_id(0, 0)] != Mark.VOID:
		return bm[get_id(0, 0)]

	if bm[get_id(0, 2)] == bm[get_id(1, 1)] &&\
		bm[get_id(1, 1)] == bm[get_id(2, 0)]&&\
		bm[get_id(0, 2)] != Mark.VOID:
		return bm[get_id(0, 2)]

	return Mark.VOID


func check_draw() -> bool:
	for i in range(9):
		if board_matrix[i] == Mark.VOID:
			return false
	winner_mark = Mark.VOID
	_end_game()
	return true


func advance_game():
	if current_player == Player.Player1:
		current_player = Player.AI
	else:
		current_player = Player.Player1

	if !check_win():
		if !check_draw():
			emit_signal("game_advanced", self)


# ---------------------------- NOTIFICATION --------------------------------


func _process(delta):
	if !game_running:
		if !auto_train:
			start_game(game_finish_duration)
		else:
			start_game(0)
