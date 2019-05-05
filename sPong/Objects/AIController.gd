extends Node
class_name AIController

export var synaptic_visualizer_scene: PackedScene
export var brain_area_path: NodePath

onready var brain_area: SharpBrainArea = get_node(brain_area_path)

var level: GameLevel = null
var player: Player = null
var synaptic_visualizer = null
var synaptic: SynapticTerminals = null
var result: SynapticTerminals = null
var organism_id: int
var auto_advance_on_5_ball_hit := false

var fitness := 0.0
var ball_hits := 0


""" PUBLIC """


func init(p_level: GameLevel, p_player: Player):
	level = p_level
	player = p_player

	if player == null:
		return

	level.table.connect("goal_received", self, "on_goal_received")
	player.connect("body_exited", self, "_on_ball_hit")

	# Init HUD
	if !level.no_view:
		if synaptic_visualizer == null:
			synaptic_visualizer = synaptic_visualizer_scene.instance()
		var HUD = level.HUD.get_player_HUD(player.player_id)
		HUD.get_node(level.HUD.node_name_syn_vis).add_child(synaptic_visualizer)

	# Init NN
	if synaptic == null:
		synaptic = SynapticTerminals.new()
		result = SynapticTerminals.new()

	# The last one is the bias
	synaptic.resize(Globals.NN_size)

	if synaptic_visualizer:
		synaptic_visualizer.init(1, Globals.NN_size)


func origin_for_nn(pos: Vector2) -> Vector2:
	var a = Vector2(Globals.table_size_x, Globals.table_size_y)
	return (player.get_global_transform().origin - pos) / a


func velocity_for_nn(vel: Vector2) -> Vector2:
	return (vel / Globals.ball_velocity)


func prepare_for_new_game(p_organism_id: int):
	organism_id = p_organism_id
	fitness = Globals.fitness_starting_fitness


func compute_ball_hits_fitness():
	fitness += Globals.compute_fitness(ball_hits)
	ball_hits = 0


""" NOTIFICATIONS """


func _on_ball_hit(body):
	if body is Ball:
		ball_hits += 1

	if auto_advance_on_5_ball_hit:
		if ball_hits >= 5:
			# Just a fast fay to implement a shortcut
			level.on_goal_received(Globals.Player2)


func on_goal_received(player_id):
	if player_id != Globals.Player2:
		return

	fitness += pow(float(ball_hits)+0.5, -2) * Globals.fitness_goal_received

	compute_ball_hits_fitness()


func _physics_process(dt):

	if player == null or level == null:
		return

	if !level.is_playing():
		return

	# Collect game data
	synaptic.set_all(0)

	var ball_pos := origin_for_nn(level.ball.get_global_transform().origin)
	var ball_velocity := velocity_for_nn(level.ball.linear_velocity)

	# Calculate fitness depending on the distance
	var inv_dist_to_ball := 1.0 - min(ball_pos.length(), 1.0)
	fitness += inv_dist_to_ball * Globals.fitness_ball_closness

	# Set data to the synapsis
	synaptic.set_value(0, ball_pos.x)
	synaptic.set_value(1, ball_pos.y)
	synaptic.set_value(2, ball_velocity.x)
	synaptic.set_value(3, ball_velocity.y)
	synaptic.set_value(4, 1) # Bias

	# Visualize data
	if synaptic_visualizer:
		synaptic.paint_on_texture(synaptic_visualizer.get_texture())

	var motion := 0.0

	assert(brain_area.guess( synaptic, result ))

	if result.get_value(0) > 0.8:
		# Move up
		motion -= 1

	if result.get_value(1) > 0.8:
		# Move down
		motion += 1

	player.move(motion)
