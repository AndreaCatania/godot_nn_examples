extends Node

const reduction_factor = 0.1
const NN_grid_size_x = 52 # 50 + 2, where two are the rows for the player positions
const NN_grid_size_y = 50

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
	return (Vector2(250, 250) + pos) * reduction_factor

""" NOTIFICATIONS """


func _process(dt):

	# Collect game data
	synaptic.set_all(0)

	if level.is_playing():
		var ball_pos := transform_for_nn(level.ball.get_global_transform().origin)

		synaptic.set_value__grid(
			NN_grid_size_x, NN_grid_size_y,
			ball_pos.x, ball_pos.y,
			1.0,
			1, 250)

	# Visualize data
	synaptic.paint_on_texture(synaptic_visualizer.get_texture())
