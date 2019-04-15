extends Node

const NN_grid_factor = Vector2(-0.1, -0.1)
const NN_grid_offset = Vector2(25.0, 75.0 / 2.0)
const NN_grid_size_x = 25
const NN_grid_size_y = 75
const NN_propagation_radius = 1
const NN_propagation_power = 250

export(PackedScene) var synaptic_visualizer_scene

var level: GameLevel = null
var player: Player = null
var synaptic_visualizer = null
var synaptic: SynapticTerminals = null


""" PUBLIC """


func init(p_level: GameLevel, p_player: Player):
	level = p_level
	player = p_player

	# Init HUD
	synaptic_visualizer = synaptic_visualizer_scene.instance()
	var HUD = level.HUD.get_player_HUD(player.player_id)
	HUD.get_node(level.HUD.node_name_syn_vis).add_child(synaptic_visualizer)

	# Init NN
	synaptic = SynapticTerminals.new()
	synaptic.resize(NN_grid_size_x * NN_grid_size_y)
	synaptic_visualizer.init(NN_grid_size_x, NN_grid_size_y)


func transform_for_nn(pos: Vector2) -> Vector2:
	return (player.get_global_transform().origin - pos) * NN_grid_factor + NN_grid_offset


func is_inside_NN_scope(pos: Vector2) -> bool:
	return pos.x < NN_grid_size_x and pos.x >= 0 and\
		pos.y < NN_grid_size_y and pos.y >= 0


""" NOTIFICATIONS """


func _process(dt):

	# Collect game data
	synaptic.set_all(0)

	if level.is_playing():
		var ball_pos := transform_for_nn(level.ball.get_global_transform().origin) 

		if is_inside_NN_scope( ball_pos ):
			synaptic.set_value__grid(
				NN_grid_size_x, NN_grid_size_y,
				ball_pos.x, ball_pos.y,
				1.0,
				NN_propagation_radius,
				NN_propagation_power)

	# Visualize data
	synaptic.paint_on_texture(synaptic_visualizer.get_texture())
