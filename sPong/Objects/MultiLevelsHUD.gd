extends Control


export(NodePath) var main_world_path
export(NodePath) var info_list_path
export(float) var update_delay := 1.0

export(NodePath) var fps_lbl_path

var delay_bank := 0.0
onready var fps_lbl = get_node(fps_lbl_path)

""" PUBLIC """


func init():
	var main_w = get_node(main_world_path)
	var info_list = get_node(info_list_path)
	for l in main_w.levels:
		info_list.add_child(Label.new())
	update_world_infos()


func update_world_infos():
	var main_w = get_node(main_world_path)
	var info_list = get_node(info_list_path)
	var level: GameLevel
	for i in range(main_w.get_level_count()):
		level = main_w.get_level(i)
		var lbl = info_list.get_child(i + 1) # + 1 because of the header
		var txt = "World #" + String(i) + " - Score player 1: " + String(level.score_player1) + " - Score player 2: " + String(level.score_player2)
		lbl.set_text(txt)


""" NOTIFICATIONS """


func _on_MultiLevels_ready():
	init()


func _process(delta):

	delay_bank += delta
	if update_delay > delay_bank:
		return

	delay_bank = 0
	update_world_infos()

	fps_lbl.set_text("FPS: " + String(Engine.get_frames_per_second()))
