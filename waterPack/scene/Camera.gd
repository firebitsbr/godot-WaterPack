extends Camera;

var view_sensitivity = 0.3;

const walk_speed = 5;
const jump_speed = 3;
const max_accel = 0.02;
const air_accel = 0.1;

func _input(ie):
	if ie.type == InputEvent.MOUSE_MOTION:
		var pitch = rad2deg(get_rotation().x);
		
		pitch = max(min(pitch - ie.relative_y * view_sensitivity, 90), -90);
		
		set_rotation(Vector3(deg2rad(pitch), 0, 0));

func _integrate_forces(state):
	
	var aim = get_node("body").get_global_transform().basis;
	var direction = Vector3();
	
	if Input.is_key_pressed("move_forward"):
		direction -= aim[2];
	if Input.is_key_pressed("move_back"):
		direction += aim[2];
	if Input.is_key_pressed("move_left"):
		direction -= aim[0];
	if Input.is_key_pressed("move_right"):
		direction += aim[0];
	direction = direction.normalized();
	apply_impulse(Vector3(), direction * air_accel * get_mass());
	state.integrate_forces();

func _ready():
	set_process_input(true);

func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);