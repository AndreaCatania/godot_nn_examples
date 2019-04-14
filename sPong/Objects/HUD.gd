extends Control

export(NodePath) var player1_side_path
export(NodePath) var player2_side_path

onready var player1_side = get_node(player1_side_path)
onready var player2_side = get_node(player2_side_path)

const node_name_score = "Score"
const node_name_syn_vis = "SynapticVisualizer"

""" PUBLIC """


func update_score(score_p1: int, score_p2: int):

	var format_string = "%0*d"

	player1_side.get_node(node_name_score).set_text((format_string % [2, score_p1]))
	player2_side.get_node(node_name_score).set_text(format_string % [2, score_p2])


func get_player_HUD(player):
	if player == Globals.Player1:
	 return player1_side
	else:
		return player2_side
