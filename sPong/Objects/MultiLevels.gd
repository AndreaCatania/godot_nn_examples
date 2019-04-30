extends Node

const max_defined_kicks = 10

export var viewport_scene: PackedScene
export var game_level_scene: PackedScene
export var AIController_scene: PackedScene
export var level_count := 2
export var games_per_organism := 0
export var game_time_per_organism := 10.0
export var neat_pop_path: NodePath
export var champion_level_path: NodePath

onready var neat_pop: NeatPopulation = get_node(neat_pop_path)

var levels = []
var AIs = []

var kicks = []

onready var champion_level = get_node(champion_level_path)
var champion_AI

var organism_processed_counter := 0
var level_in_progress_count := 0
var free_levels

var epoch_advanced := false


""" PUBLIC """


func get_level_count() -> int:
	return levels.size()


func get_level(i) -> GameLevel:
	return levels[i]


func get_level_viewport(i) -> Viewport:
	return levels[i].get_parent()


""" This function returns the ball direction.
It's called by the GameLevel if this script is assigned to GameLevel.ball_kicker
"""
func get_ball_kick_direction(current_round: int) -> Vector2:
	if max_defined_kicks > current_round:
		return kicks[current_round]
	return _int_get_ball_kick_direction()


""" PRIVATE """


func add_game_level():
	assert( levels.size() == AIs.size() )

	var viewport = viewport_scene.instance()
	var level = game_level_scene.instance()
	var controller = AIController_scene.instance()

	level.end_score_threshold = games_per_organism
	level.game_time = game_time_per_organism
	level.use_custom_controllers = true
	level.no_view = true
	level.auto_start = false
	level.ball_kicker = self

	var level_id = levels.size()
	levels.push_back(level)
	AIs.push_back(controller)

	add_child(viewport)
	viewport.add_child(level)
	level.set_player_controller(Globals.Player2, controller)

	level.connect("game_ended", self, "on_game_ended", [level_id])


func init_champion_game_level():
	champion_AI = AIController_scene.instance()
	champion_level.end_score_threshold = 0
	champion_level.game_time = 400.0
	champion_level.set_player_controller(Globals.Player2, champion_AI)


func start_all_levels():

	create_ball_kick_list()

	assert(level_in_progress_count == 0)
	for i in range(levels.size()):
		start_level(i, level_in_progress_count)

	organism_processed_counter = level_in_progress_count


func start_champion_level():
	neat_pop.get_champion_brain_area(champion_AI.brain_area)
	champion_AI.brain_area.save_knowledge("res://champion_knowledge", true)
	champion_level.start_game()


func start_level(level_id, organism_id):
	var level = levels[level_id]
	var AI: AIController = AIs[level_id]

	# TODO The execution cost of this function is not trivial
	neat_pop.organism_get_brain_area(organism_id, AI.brain_area)
	AI.prepare_for_new_game(organism_id)

	level.start_game()
	level_in_progress_count += 1


func epoch_advance():
	assert(level_in_progress_count == 0)
	assert(neat_pop.epoch_advance())
	start_all_levels()
	start_champion_level()


func create_ball_kick_list():
	kicks.resize(max_defined_kicks)
	for i in range(max_defined_kicks):
		kicks[i] = _int_get_ball_kick_direction()


func _int_get_ball_kick_direction() -> Vector2:
	return Vector2(
		max(randf()+0.3, 1.0)*sign(randf()-0.5),
		min(randf()+0.1, 1.0))


""" NOTIFICATIONS """


func _ready():

	for i in range(level_count):
		add_game_level()

	init_champion_game_level()

	organism_processed_counter = 0
	start_all_levels()


func on_game_ended(level_id):

	level_in_progress_count -= 1

	var controller = AIs[level_id]
	controller.compute_ball_hits_fitness()
	neat_pop.organism_set_fitness(controller.organism_id, controller.fitness)

	if organism_processed_counter >= neat_pop.population_size:
		if level_in_progress_count <= 0:
			epoch_advance()
		return

	start_level(level_id, organism_processed_counter)
	organism_processed_counter += 1
