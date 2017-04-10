extends Spatial

var view_sensitivity = 0.035
var body = 0.0
var pitch = 0.0
var speed = 0.15

func _ready():
	set_process(true)
	set_fixed_process(true)
	set_process_input(true)
	
func _enter_tree():
	get_node("gimbal/innergimal/cam").make_current()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(ie):
	if ie.type == InputEvent.MOUSE_MOTION:
		var sensitivity = view_sensitivity;
		set_body_rot(pitch - ie.relative_y * sensitivity, body - ie.relative_x * sensitivity);

func _fixed_process(delta):
	if Input.is_mouse_button_pressed(1):
		var transform = get_viewport().get_camera().get_global_transform();
		var result = get_world().get_direct_space_state().intersect_ray(transform.origin, transform.xform(Vector3(0,0,-1*10)), [self]);
		if !result.empty():
			get_node("/root/world").paint_uv(result["position"], result["normal"], Color("#ffff00"))


func set_body_rot(npitch, nyaw):
	body = fmod(nyaw, 360)
	pitch = max(min(npitch, 90), -90)
	get_node("gimbal").set_rotation(Vector3(0, deg2rad(body), 0))
	get_node("gimbal/innergimal").set_rotation(Vector3(deg2rad(pitch), 0, 0))
	
func _process(delta):
	var aim = get_node("gimbal/innergimal").get_global_transform().basis;

	var direction = Vector3();
	
	if Input.is_key_pressed(KEY_W):
		direction -= aim[2];
	if Input.is_key_pressed(KEY_S):
		direction += aim[2];
	if Input.is_key_pressed(KEY_A):
		direction -= aim[0];
	if Input.is_key_pressed(KEY_D):
		direction += aim[0];
	
	direction = direction.normalized()*speed;
	translate(direction)
