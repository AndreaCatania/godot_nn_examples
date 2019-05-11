extends Node


var level: GameLevel = null
var player: Player = null


""" PUBLIC """


func init(p_level: GameLevel, p_player: Player):
	level = p_level
	player = p_player

	var w = InputEventKey.new()
	w.scancode = KEY_W
	var a = InputEventKey.new()
	a.scancode = KEY_W
	var l = InputEventKey.new()
	l.scancode = KEY_LEFT
	var u = InputEventKey.new()
	u.scancode = KEY_UP

	InputMap.add_action("Player1MoveUp")
	InputMap.action_add_event("Player1MoveUp", w)
	InputMap.action_add_event("Player1MoveUp", a)
	InputMap.action_add_event("Player1MoveUp", l)
	InputMap.action_add_event("Player1MoveUp", u)

	var s = InputEventKey.new()
	s.scancode = KEY_S
	var d = InputEventKey.new()
	d.scancode = KEY_D
	var r = InputEventKey.new()
	r.scancode = KEY_RIGHT
	var do = InputEventKey.new()
	do.scancode = KEY_DOWN

	InputMap.add_action("Player1MoveDown")
	InputMap.action_add_event("Player1MoveDown", s)
	InputMap.action_add_event("Player1MoveDown", d)
	InputMap.action_add_event("Player1MoveDown", r)
	InputMap.action_add_event("Player1MoveDown", do)


""" NOTIFICATIONS """


func _process(delta):
	if player == null:
		return

	var motion := 0.0

	if Input.is_action_pressed("Player1MoveUp"):
		motion -= 1

	if Input.is_action_pressed("Player1MoveDown"):
		motion += 1

	player.move(motion)
