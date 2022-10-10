extends RigidBody2D

var static_mode_switch_legth = 2
func _integrate_forces(state):
	if state.linear_velocity.length() < static_mode_switch_legth:
		sleeping = true
