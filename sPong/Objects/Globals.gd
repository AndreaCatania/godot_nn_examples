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

const NN_size = 5

const fitness_starting_fitness = 500.0
const fitness_ball_closness = 0.03
const fitness_goal_received = -10.0 # changes depending on the ball hits

const knw_easy_path = "res://champion_knowledge_easy.brainweights"
const knw_normal_path = "res://champion_knowledge_normal.brainweights"
const knw_extreme_path = "res://champion_knowledge_extreme.brainweights"


func compute_fitness(ball_hits) -> float:
	return pow(ball_hits / 2.0, 3.0)
