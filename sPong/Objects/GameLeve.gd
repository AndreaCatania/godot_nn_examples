extends Node
class_name GameLevel

signal game_ended()

# When this is true, the controllers can and must be initialized elsewhere
export(bool) var use_custom_controllers = false

export var player_scene: PackedScene
export var ball_scene: PackedScene
export var player1_controller_scene: PackedScene
export var player2_controller_scene: PackedScene
export var camera_path: NodePath
export var table_path: NodePath
export var HUD_path: NodePath
export var start_round_timer_path: NodePath

export var auto_start := true
export var no_view := false
export var end_score_threshold := 5

var camera = null
var table = null
var player1 = null
var player2 = null
var player1_controller = null
var player2_controller = null
var ball = null
var HUD = null
var start_round_timer = null

var score_player1 := 0
var score_player2 := 0
var winner

var state := Globals.GAME_ENDED


""" PUBLIC """


func set_player_controller(player_id, controller):

	var player: Player = null
	var curr_controller = null
	if player_id == Globals.Player1:
		player = player1
		curr_controller = player1_controller
	else:
		player = player2
		curr_controller = player2_controller

	if curr_controller != null:
		curr_controller.get_parent().remove_child(curr_controller)
		curr_controller.init(null, null)

	controller.init(self, player)
	add_child(controller)

	if player_id == Globals.Player1:
		player1_controller = controller
	else:
		player2_controller = controller


func get_state():
	return state


func is_playing() -> bool:
	return state == Globals.GAME_PLAYING


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

	if no_view:
		camera.queue_free()
		table.hide()


func init_positions():
	player1.set_global_transform(table.get_spawn(Globals.Player1).get_global_transform())
	player2.set_global_transform(table.get_spawn(Globals.Player2).get_global_transform())
	ball.set_global_transform(table.get_ball_spawn().get_global_transform())


func init_controller():
	if use_custom_controllers:
		return

	set_player_controller(Globals.Player1, player1_controller_scene.instance())
	set_player_controller(Globals.Player2, player2_controller_scene.instance())


func start_game():
	randomize()
	state = Globals.GAME_PAUSED
	score_player1 = 0
	score_player2 = 0
	round_advance()


func round_advance():

	# Check ending
	if score_player1 >= end_score_threshold or\
		score_player2 >= end_score_threshold:
		end_game()
		return

	if start_round_timer.get_wait_time() > 0.05:
		ball.set_linear_velocity(Vector2())
		ball.hide()
		start_round_timer.start()
	else:
		_start_round()


func _start_round():
	var from = table.get_ball_spawn().get_global_transform()
	var dir = table.get_ball_kick_direction()
	ball.kick(from, dir)
	ball.show() 
	start_round_timer.stop()
	state = Globals.GAME_PLAYING


func end_game():

	ball.set_linear_velocity(Vector2())
	ball.hide()

	if score_player1 >= end_score_threshold:
		winner = Globals.Player1

	if score_player2 >= end_score_threshold:
		winner = Globals.Player2

	state = Globals.GAME_ENDED
	emit_signal("game_ended")


func on_ball_outside():
	round_advance()


""" NOTIFICATIONS """

func _ready():
	init_objects()
	init_positions()
	init_controller()

	if auto_start:
		start_game()


func on_goal_received(player):

	if player == Globals.Player1:
		score_player2 += 1
	else:
		score_player1 += 1

	state = Globals.GAME_PAUSED
	if !no_view:
		HUD.update_score(score_player1, score_player2)
	round_advance()
