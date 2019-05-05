extends Control

export var level: NodePath

export var player1_side_path: NodePath
export var player2_side_path: NodePath

export var main_menu_path: NodePath
export var difficult_dd_path: NodePath
export var match_point_dd_path: NodePath

onready var main_menu = get_node(main_menu_path)
onready var difficult_dd = get_node(difficult_dd_path)
onready var match_point_dd = get_node(match_point_dd_path)

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


func hide_syn_vis():
	get_player_HUD(Globals.Player1).get_node(node_name_syn_vis).hide()
	get_player_HUD(Globals.Player2).get_node(node_name_syn_vis).hide()


""" Notificaitons """


func _ready():
	init_main_menu()


func _on_ResumeBtn_pressed():
	hide_menu()


func _on_PauseBtn_pressed():
	show_menu()


func _on_StartMatchBtn_pressed():
	pass # Replace with function body.


func _on_ExitGameBtn_pressed():
	get_tree().quit()


""" Private """


func init_main_menu():

	difficult_dd.add_item("vs Animal")
	difficult_dd.add_item("vs Dude")
	difficult_dd.add_item("vs Galaxy champion")

	match_point_dd.add_item("10")
	match_point_dd.add_item("20")
	match_point_dd.add_item("30")
	match_point_dd.add_item("50")
	match_point_dd.add_item("100")


func show_menu():
	get_tree().paused = true
	main_menu.show()


func hide_menu():
	main_menu.hide()
	get_tree().paused = false
