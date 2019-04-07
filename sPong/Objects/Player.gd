extends RigidBody2D
class_name Player


var player_id
var motion = MOTION_NONE


""" PUBLIC """


enum {MOTION_UP, MOTION_NONE, MOTION_DOWN}


func init(p_player_id):
	player_id = p_player_id


func move(p_motion):
	motion = p_motion


""" NOTIFICATIONS """


func _integrate_forces(state):
	var vel = Vector2(0, 0)

	if motion == MOTION_UP:
		vel.y = -Globals.player_velocity
	elif motion == MOTION_DOWN:
		vel.y = Globals.player_velocity

	set_linear_velocity(vel)
	set_angular_velocity(0)
