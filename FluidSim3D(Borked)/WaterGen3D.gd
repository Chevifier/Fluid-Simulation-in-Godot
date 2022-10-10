extends Position3D
#Water Gen with PhysicsServer
export(SpatialMaterial) var particle_material:SpatialMaterial;

export var max_water_particles = 1000
var current_particle_count = 0
var spawn_timer = 0
export var spawn_time = 1.0
var multimesh
var water_particles = []

func _ready():
	create_multimesh()
	
func create_multimesh():
	#Create 1 multimesh for all water particle
	var vs = VisualServer
	multimesh = vs.multimesh_create()
	#initailze the multimesh data
	vs.multimesh_allocate(multimesh,max_water_particles,VisualServer.MULTIMESH_TRANSFORM_3D,VisualServer.MULTIMESH_COLOR_8BIT)
	#create the bash mesh
	var mesh = vs.make_sphere_mesh(10,10,0.7)
	#set the mesh material
	vs.mesh_surface_set_material(mesh,0,particle_material)
	#set the mesh to the multimesh
	vs.multimesh_set_mesh(multimesh,mesh)
	#create visual instance to represent the multimesh
	var water_particle = vs.instance_create()
	#set the multimesh to the instance
	vs.instance_set_base(water_particle,multimesh)
	#set the instance to be in the active scenario
	#Think of it as a universe or multiverse ;)
	vs.instance_set_scenario(water_particle,get_world().scenario)
	


func create_particle(multimesh_index):
	#References
	var ps = PhysicsServer
	var vs = VisualServer
	# set tranform for initial location
	var trans = global_transform 
	trans.origin += Vector3(rand_range(-0.15,0.15),rand_range(-0.15,0.15),rand_range(-0.15,0.15))
	#physics body
	var water_col = ps.body_create()
	ps.body_set_mode(water_col,Physics2DServer.BODY_MODE_RIGID)
	#like the universe again
	ps.body_set_space(water_col,get_world().space)
	#create collision shape
	var col_shape = ps.shape_create(PhysicsServer.SHAPE_SPHERE)
	ps.shape_set_data(col_shape,0.55)
	#add the shape to the body
	ps.body_add_shape(water_col,col_shape,Transform.IDENTITY)
	#collision layer and mask
	ps.body_set_collision_layer(water_col,1)
	ps.body_set_collision_mask(water_col,1)
	#physics parameter
	ps.body_set_param(water_col,PhysicsServer.BODY_PARAM_FRICTION,0.0)
	ps.body_set_param(water_col,PhysicsServer.BODY_PARAM_MASS,0.05)
	ps.body_set_param(water_col,PhysicsServer.BODY_PARAM_GRAVITY_SCALE,2.0)
	ps.body_set_state(water_col,PhysicsServer.BODY_STATE_TRANSFORM,trans)
	#set multimesh current index object to same transform
	vs.multimesh_instance_set_transform(multimesh,multimesh_index,trans)
	#add pair to array
	water_particles.append([water_col,multimesh_index])
	current_particle_count += 1
	Globals.total_water_particles += 1
	
func _physics_process(delta):
	if spawn_timer < 0 and current_particle_count < max_water_particles:
		#add 2 per spawn time
		for i in 5:
			create_particle(current_particle_count)
		spawn_timer = spawn_time
	spawn_timer -= 1
	for col in water_particles:
		var trans = PhysicsServer.body_get_state(col[0],Physics2DServer.BODY_STATE_TRANSFORM)
		#trans.origin = trans.origin - global_transform.origin
		VisualServer.multimesh_instance_set_transform(multimesh,col[1],trans)
		#Delete particles
		if trans.origin.y < -10:
			#remove physics body
			PhysicsServer.free_rid(col[0])
			#remove reference array
			water_particles.erase(col)
			Globals.total_water_particles -=1
			#Cant remove multimesh objects so put them somewhere far
			trans.origin = Vector3(0,-100000,0)
			VisualServer.multimesh_instance_set_transform(multimesh,col[1],trans)
