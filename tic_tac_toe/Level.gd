extends Node

signal game_started(level)
signal game_advanced(level)
signal game_finished(level)

export(NodePath) var board_path
export(float) var game_finish_duration = 2.5

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


func player_put_mark(row: int, column: int):
	if current_player == Player.Player1:
		return put_mark(row, column, Mark.TIC)
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


# ---------------------------- PRIVATE -------------------------------------


func put_mark(row: int, column: int, player):
	put_mark_id(get_id(row, column), player)


func put_mark_id(id: int, player):
	var val = board_matrix[id]

	if val != Mark.VOID:
		printerr("The cell is not void")
		return false

	board_matrix[id] = player

	board.get_button_by_id(id).set_mark_texture(player == Player.AI)

	advance_game()
	return true


func get_id(row, column):
	return row * 3 + column


func start_game():
	for row in range(3):
		for column in range(3):
			board.get_button(row, column).reset()
	board_matrix = [
		Mark.VOID,Mark.VOID,Mark.VOID,
		Mark.VOID,Mark.VOID,Mark.VOID,
		Mark.VOID,Mark.VOID,Mark.VOID]
	current_player = Player.Player1
	emit_signal("game_started", self)


func check_win() -> bool:
	# Check vertical
	for row in range(3):
		if board_matrix[get_id(row, 0)] == board_matrix[get_id(row, 1)] &&\
			board_matrix[get_id(row, 0)] == board_matrix[get_id(row, 2)] &&\
			board_matrix[get_id(row, 0)] != Mark.VOID:
			winner_mark = board_matrix[get_id(row, 0)]
			emit_signal("game_finished", self)
			return true

	# Check horizontal
	for column in range(3):
		if board_matrix[get_id(0, column)] == board_matrix[get_id(1, column)] &&\
			board_matrix[get_id(0, column)] == board_matrix[get_id(2, column)]&&\
			board_matrix[get_id(0, column)] != Mark.VOID:
			winner_mark = board_matrix[get_id(0, column)]
			emit_signal("game_finished", self)
			return true

	# Check oblique
	if board_matrix[get_id(0, 0)] == board_matrix[get_id(1, 1)] &&\
		board_matrix[get_id(1, 1)] == board_matrix[get_id(2, 2)]&&\
			board_matrix[get_id(0, 0)] != Mark.VOID:
		winner_mark = board_matrix[get_id(0, 0)]
		emit_signal("game_finished", self)
		return true

	if board_matrix[get_id(0, 2)] == board_matrix[get_id(1, 1)] &&\
		board_matrix[get_id(1, 1)] == board_matrix[get_id(2, 0)]&&\
		board_matrix[get_id(0, 2)] != Mark.VOID:
		winner_mark = board_matrix[get_id(0, 2)]
		emit_signal("game_finished", self)
		return true

	return false


func advance_game():
	if current_player == Player.Player1:
		current_player = Player.AI
	else:
		current_player = Player.Player1

	if !check_win():
		emit_signal("game_advanced", self)


# ---------------------------- NOTIFICATION --------------------------------


func _ready():
	start_game()


func _on_Level_game_finished(level):
	yield(get_tree().create_timer(game_finish_duration), "timeout")
	start_game()
