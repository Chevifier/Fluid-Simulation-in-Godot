extends Node2D
#Water Gen with Physics2DServer
export(Texture) var particle_texture:Texture;
export var max_water_particles = 1000
var current_particle_count = 0
var spawn_timer = 0
export var spawn_time = 1.0
var water_particles = []

func create_particle():
	var ps = Physics2DServer
	var vs = VisualServer
	# set position
	var trans = global_transform 
	trans.origin += Vector2(rand_range(-10,10),rand_range(-10,10))
	#physics body
	var water_col = ps.body_create()
	ps.body_set_mode(water_col,Physics2DServer.BODY_MODE_RIGID)
	ps.body_set_space(water_col,get_world_2d().space)
	#create circle shape for collision
	var shape = ps.circle_shape_create()
	ps.shape_set_data(shape,8)
	#add shape to rigid body
	ps.body_add_shape(water_col,shape,Transform2D.IDENTITY)
	#set collision layer and mask
	ps.body_set_collision_layer(water_col,1)
	ps.body_set_collision_mask(water_col,1)
	#set physics parameters
	ps.body_set_param(water_col,Physics2DServer.BODY_PARAM_FRICTION,0.0)
	ps.body_set_param(water_col,Physics2DServer.BODY_PARAM_MASS,0.05)
	ps.body_set_param(water_col,Physics2DServer.BODY_PARAM_GRAVITY_SCALE,2.0)
	ps.body_set_state(water_col,PhysicsServer.BODY_STATE_TRANSFORM,trans)
	#Visual
	#create canvas item(all 2D objects are canvas items)
	var water_particle = vs.canvas_item_create()
	#set the parent to this object
	vs.canvas_item_set_parent(water_particle, get_canvas_item())
	#set its transform
	vs.canvas_item_set_transform(water_particle,trans)
	#create a rectangle that will contain the texture
	var rect = Rect2()
	rect.position = Vector2(-8,-8)
	rect.size = particle_texture.get_size()/2
	#add the texture to the canvas item
	vs.canvas_item_add_texture_rect(water_particle,rect,particle_texture)
	#set the texture color to pink
	vs.canvas_item_set_self_modulate(water_particle,Color("ff00ff"))
	#add RID pair to array
	water_particles.append([water_col,water_particle])

func _physics_process(delta):
	#add particles while less than max amount set and timer < 0
	if spawn_timer < 0 and current_particle_count < max_water_particles:
		create_particle()
		current_particle_count += 1
		Globals.total_water_particles += 1
		spawn_timer = spawn_time
	spawn_timer -= 1
	#update particle texture position to be at Rigid body position
	for col in water_particles:
		var trans = Physics2DServer.body_get_state(col[0],Physics2DServer.BODY_STATE_TRANSFORM)
		trans.origin = trans.origin - global_position
		VisualServer.canvas_item_set_transform(col[1],trans)
		#Delete particles if Y position > than 1500. 2D y down is positive
		if trans.origin.y > 1500:
			#remove RIDs
			Physics2DServer.free_rid(col[0])
			VisualServer.free_rid(col[1])
			#remove reference
			water_particles.erase(col)
			Globals.total_water_particles -=1
