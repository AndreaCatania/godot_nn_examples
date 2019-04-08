extends RigidBody2D
class_name Ball

var want_to_kick = false
var from
var dir

""" PUBLIC """


func kick(p_from, p_dir):
	want_to_kick = true
	from = p_from
	dir = p_dir


""" NOTIFICATIONS """


func _integrate_forces(state):
	if want_to_kick:
		want_to_kick = false
		state.set_transform(from)
		set_linear_velocity(dir.normalized() * Globals.ball_velocity)

	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		if collider is Player:
			var collider_vel = collider.get_linear_velocity().length_squared()
			var n = state.get_contact_local_normal(i)
			state.apply_impulse(Vector2(), n * (min(collider_vel, 1.0) * Globals.player_hit_impulse))


func _on_Ball_body_entered(body):
	pass