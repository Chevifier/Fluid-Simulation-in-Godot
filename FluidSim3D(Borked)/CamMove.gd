extends Spatial
var mouse = Vector2()
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	var input = Input.get_vector("left","right", "down", "up")
	var velocity = Vector3()
	
	velocity += input.x * global_transform.basis.x * 20 * delta
	velocity -= input.y * global_transform.basis.z * 20 * delta
	var vertical = Input.get_axis("crouch","jump")
	velocity += vertical * global_transform.basis.y * 20 * delta
	
	
	global_transform.origin += velocity
	
	rotation_degrees.y -= mouse.x * 20 * delta
	$Camera.rotation_degrees.x -= mouse.y * 20 * delta
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	mouse = Vector2()
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse = event.relative
