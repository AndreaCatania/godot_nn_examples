extends Control


export(NodePath) var main_world_path
export(NodePath) var info_list_path
export(float) var update_delay := 1.0

export(NodePath) var fps_lbl_path
export(NodePath) var epoch_lbl_path
export(NodePath) var champ_info_lbl_path

var delay_bank := 0.0
onready var fps_lbl = get_node(fps_lbl_path)
onready var epoch_lbl = get_node(epoch_lbl_path)
onready var champ_info_lbl = get_node(champ_info_lbl_path)


""" PUBLIC """


func init():
	var main_w = get_node(main_world_path)
	var info_list = get_node(info_list_path)
	for i in range(main_w.neat_pop.population_size):
		info_list.add_child(Label.new())
	update_world_infos()


func update_world_infos():
	var main_w = get_node(main_world_path)
	var info_list = get_node(info_list_path)
	var fitness := 0.0
	for i in range(main_w.neat_pop.population_size):
		fitness = main_w.neat_pop.organism_get_fitness(i)
		var lbl = info_list.get_child(i)
		var txt = "Organism ID: " + String(i) + ", Fitness: " + String(fitness)
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

	var main_w = get_node(main_world_path)

	fps_lbl.set_text("FPS: " + String(Engine.get_frames_per_second()))
	epoch_lbl.set_text("Epoch: " + String(main_w.neat_pop.get_epoch()) + " - Best personal fitness ever: " + String(main_w.neat_pop.get_best_fitness_ever()))
	champ_info_lbl.set_text("Champion: " + main_w.champion_AI.brain_area.description())