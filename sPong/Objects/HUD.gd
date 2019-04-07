extends Control

export(NodePath) var score_player1_lbl_path
export(NodePath) var score_player2_lbl_path


""" PUBLIC """


func update_score(score_p1: int, score_p2: int):

	var format_string = "%0*d"

	get_node(score_player1_lbl_path).set_text((format_string % [2, score_p1]))
	get_node(score_player2_lbl_path).set_text(format_string % [2, score_p2])
