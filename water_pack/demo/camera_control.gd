extends Camera

export var zoom_min_distance = 0.1
export var zoom_max_distance = 1000
var center_pos
var target_distance
var target_direction
var target_rotate
var zoom_speed = 2.0
export var zoom_sensitivity = 4.0
export var rotate_speed = 10.0
var start_smooth_move = false

func _ready():

    center_pos = Vector3(0, 0, 0)
    var relative_pos = global_transform.origin - center_pos
    target_distance = relative_pos.length()
    target_direction = relative_pos.normalized()

func _process(delta):
    if start_smooth_move == true:
        var relative_pos = global_transform.origin - center_pos
        var distance = relative_pos.length()
        var direction = relative_pos.normalized()
        distance += delta * zoom_sensitivity * (target_distance - distance)
        direction += delta * rotate_speed * (target_direction - direction)
        var target_pos = center_pos + direction * distance
        look_at_from_position(target_pos, center_pos, Vector3(0, 1, 0))
        if distance == target_distance and direction == target_direction:
            start_smooth_move = false


var nav_pan_mode = false
export var nav_pan_sensitivity = 0.1
var nav_look_mode = false
export var nav_look_sensitivity = 0.005
var nav_rotate_mode = false
export var nav_rotate_sensitivity = 0.005

func _input(event):
    if event.is_action_pressed("zoom_in"):
        target_distance -= zoom_speed
        if target_distance < zoom_min_distance:
            target_distance = zoom_min_distance
        start_smooth_move = true

    if event.is_action_pressed("zoom_out"):
        target_distance += zoom_speed
        if target_distance > zoom_max_distance:
            target_distance = zoom_max_distance
        start_smooth_move = true

    if event.is_action_pressed("top_view"):
        target_direction = Vector3(0, 1, 0)
        start_smooth_move = true

    if event.is_action_pressed("bottom_view"):
        target_direction = Vector3(0, -1, 0)
        start_smooth_move = true

    if event.is_action_pressed("left_view"):
        target_direction = Vector3(-1, 0, 0)
        start_smooth_move = true

    if event.is_action_pressed("right_view"):
        target_direction = Vector3(1, 0, 0)
        start_smooth_move = true

    if event.is_action_pressed("front_view"):
        target_direction = Vector3(0, 0, 1)
        start_smooth_move = true

    if event.is_action_pressed("back_view"):
        target_direction = Vector3(0, 0, -1)
        start_smooth_move = true
    # ratate
    if event.is_action_pressed("nav_look"):
        nav_look_mode = true
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    if event.is_action_released("nav_look"):
        nav_look_mode = false
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    if nav_look_mode == true:
        if event is InputEventMouseMotion:
            var mouse_move = event.relative
            var movement = Vector3(mouse_move.x * nav_look_sensitivity, mouse_move.y * nav_look_sensitivity, 0)
            rotate_object_local(Vector3(0, 1, 0), movement.x)
            rotate_object_local(Vector3(1, 0, 0), movement.y)
            target_direction = -global_transform.basis.z
            center_pos = global_transform.origin - target_direction * target_distance
            look_at_from_position(global_transform.origin,
                                  center_pos, Vector3(0, 1, 0))
    # rotate around
    if event.is_action_pressed("nav_rotate"):
        nav_rotate_mode = true
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    if event.is_action_released("nav_rotate"):
        nav_rotate_mode = false
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    if nav_look_mode == true:
        if event is InputEventMouseMotion:
            var mouse_move = event.relative
            var movement = Vector3(mouse_move.x * nav_rotate_sensitivity, mouse_move.y * nav_rotate_sensitivity, 0)
            target_direction = -global_transform.basis.z
            center_pos = global_transform.origin - target_direction * target_distance
            look_at_from_position(global_transform.origin,
                                  center_pos, Vector3(0, 1, 0))

    # pan
    if event.is_action_pressed("nav_pan"):
        nav_pan_mode = true
    if event.is_action_released("nav_pan"):
        nav_pan_mode = false
    if nav_pan_mode == true:
        if event is InputEventMouseMotion:
            var mouse_move = event.relative
            var movement = Vector3(-mouse_move.x * nav_pan_sensitivity, mouse_move.y * nav_pan_sensitivity, 0)
            translate_object_local(movement)
            center_pos = global_transform.origin - target_direction * target_distance
