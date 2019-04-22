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

var fitness := 0.0

""" PUBLIC """


func init(p_level: GameLevel, p_player: Player):
	level = p_level
	player = p_player

	if player == null:
		return

	player.connect("body_exited", self, "_on_ball_exited")

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

	synaptic.resize(Globals.NN_grid_size_x * Globals.NN_grid_size_y)

	if synaptic_visualizer:
		synaptic_visualizer.init(Globals.NN_grid_size_x, Globals.NN_grid_size_y)


func transform_for_nn(pos: Vector2) -> Vector2:
	return (player.get_global_transform().origin - pos) * Globals.NN_grid_factor + Globals.NN_grid_offset


func is_inside_NN_scope(pos: Vector2) -> bool:
	return pos.x < Globals.NN_grid_size_x and pos.x >= 0 and\
		pos.y < Globals.NN_grid_size_y and pos.y >= 0


func prepare_for_new_game(p_organism_id: int):
	organism_id = p_organism_id
	fitness = 0.0


""" NOTIFICATIONS """


func _on_ball_exited(body):
	if body is Ball:
		fitness += 0.2


func _process(dt):

	if player == null or level == null:
		return

	if !level.is_playing():
		return

	# Collect game data
	synaptic.set_all(0)

	var ball_pos := transform_for_nn(level.ball.get_global_transform().origin) 

	if is_inside_NN_scope( ball_pos ):
		synaptic.set_value__grid(
			Globals.NN_grid_size_x, Globals.NN_grid_size_y,
			ball_pos.x, ball_pos.y,
			1.0,
			Globals.NN_propagation_radius,
			Globals.NN_propagation_power)

	# Visualize data
	if synaptic_visualizer:
		synaptic.paint_on_texture(synaptic_visualizer.get_texture())

	var motion := 0.0

	assert(brain_area.guess( synaptic, result ))

	if result.get_value(0) > 0.6:
		# Move up
		motion -= 1

	elif result.get_value(1) > 0.6:
		# Move down
		motion += 1

	player.move(motion)
