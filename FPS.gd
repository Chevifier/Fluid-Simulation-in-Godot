extends Label


var fps
var physics_fps
var particles =0
export var adjust_physics_update = false

func _process(delta):
	fps = Engine.get_frames_per_second()
	physics_fps = Engine.iterations_per_second
	particles = Globals.total_water_particles
	text = "FPS: " + str(fps) + "\nPhysics FPS: " + str(physics_fps)\
		+ "\nParticles: " + str(particles)+"\nFAILED, GOTTA LEARN C++ :'/"

