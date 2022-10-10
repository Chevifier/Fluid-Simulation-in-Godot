extends RigidBody2D
#Use play with water
export var infuence =1000
export var stiffness = 100



func _physics_process(delta):
	var I = infuence
	var S = stiffness 
	var P = get_global_mouse_position() - global_transform.origin
	var M = mass
	var V = linear_velocity
	var impulse = (I*P) - (S*M*V)
	apply_central_impulse(impulse * delta)
