extends Node

export(bool) var is_player_1_gamer = true

export(PackedScene) var player_scene
export(PackedScene) var ball_scene
export(PackedScene) var player_controller_scene
export(NodePath) var camera_path
export(NodePath) var table_path
export(NodePath) var HUD_path
export(NodePath) var start_round_timer_path

var camera
var table
var player1
var player2
var ball
var HUD
var start_round_timer

var score_player1 = 0
var score_player2 = 0

""" PUBLIC """


""" PRIVATE """

func init_objects():
	player1 = player_scene.instance()
	player2 = player_scene.instance()
	ball = ball_scene.instance()
	camera = get_node(camera_path)
	table = get_node(table_path)
	HUD = get_node(HUD_path)
	start_round_timer = get_node(start_round_timer_path)

	table.connect("goal_received", self, "on_goal_received")
	table.connect("ball_outside", self, "on_ball_outside")

	player1.init(Globals.Player1)
	player2.init(Globals.Player2)

	start_round_timer.connect("timeout", self, "_start_round")

	add_child(player1)
	add_child(player2)
	add_child(ball)


func init_positions():

	player1.set_global_transform(table.get_spawn(Globals.Player1).get_global_transform())
	player2.set_global_transform(table.get_spawn(Globals.Player2).get_global_transform())
	ball.set_global_transform(table.get_ball_spawn().get_global_transform())


func init_controller():
	if is_player_1_gamer:
		var pc1 = player_controller_scene.instance()
		pc1.init(player1)
		add_child(pc1)


func start_game():
	randomize()
	start_round()


func start_round():
	if start_round_timer.get_wait_time() > 0.1:
		ball.set_mode(RigidBody2D.MODE_KINEMATIC)
		ball.hide()
		start_round_timer.start()
	else:
		_start_round()


""" NOTIFICATIONS """

func _ready():
	init_objects()
	init_positions()
	init_controller()
	start_game()


func on_goal_received(player):

	if player == Globals.Player1:
		score_player2 += 1
	else:
		score_player1 += 1

	HUD.update_score(score_player1, score_player2)
	start_round()


func on_ball_outside():
	start_round()


func _start_round():
	var from = table.get_ball_spawn().get_global_transform()
	var dir = table.get_ball_kick_direction()
	ball.kick(from, dir)
	ball.set_mode(RigidBody2D.MODE_CHARACTER)
	ball.show()
	start_round_timer.stop()
