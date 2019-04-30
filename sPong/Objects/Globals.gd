extends Node

enum {
	Player1,
	Player2
}

enum {
	GAME_PAUSED,
	GAME_PLAYING,
	GAME_ENDED
}

const player_velocity = 1000
const player_hit_impulse = 1.1
const ball_velocity = 450
const table_size_x = 500
const table_size_y = 500

const NN_grid_size_x = 1
const NN_grid_size_y = 750
const NN_propagation_radius = 10
const NN_propagation_power = 0.3
const NN_grid_factor = Vector2(0, -1.0)
const NN_grid_offset = Vector2(0, 750.0 / 2.0)

const fitness_starting_fitness = 0.0
const fitness_ball_closness = 0.02


func compute_fitness(ball_hits) -> float:
	return pow(ball_hits / 2.0, 3.0)