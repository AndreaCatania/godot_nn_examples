extends RigidBody2D
class_name Player


var player_id
var motion := 0.0


""" PUBLIC """


func init(p_player_id):
	player_id = p_player_id


func move(p_motion: float):
	motion = clamp(p_motion, -1.0, 1.0)


""" NOTIFICATIONS """


func _integrate_forces(state):
	var vel = Vector2(0, 0)

	vel.y = motion * Globals.player_velocity

	set_linear_velocity(vel)
	set_angular_velocity(0)


