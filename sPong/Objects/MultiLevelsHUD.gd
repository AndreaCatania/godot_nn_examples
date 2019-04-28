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
	var e_info := String()
	e_info += "Epoch: " + String(main_w.neat_pop.get_epoch())
	e_info += "\nBest personal fitness ever: " + String(main_w.neat_pop.get_best_fitness_ever())
	e_info += "\nPop average fitness: " + String(main_w.neat_pop.get_statistic(NeatPopulation.STATISTIC_POP_AVG_FITNESS))
	e_info += "\nSpecies count: " + String(main_w.neat_pop.get_statistic(NeatPopulation.STATISTIC_SPECIES_COUNT))
	e_info += "\nBest species offspring count: " + String(main_w.neat_pop.get_statistic(NeatPopulation.STATISTIC_SPECIES_BEST_OFFSPRING))
	e_info += "\nPop epoch last improvement: " + String(main_w.neat_pop.get_statistic(NeatPopulation.STATISTIC_POP_EPOCH_LAST_IMPROVEMENT))
	epoch_lbl.set_text(e_info)
	champ_info_lbl.set_text("Champion: " + main_w.champion_AI.brain_area.description())