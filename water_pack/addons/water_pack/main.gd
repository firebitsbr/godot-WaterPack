tool
extends EditorPlugin

var editor_camera

var water_physics = preload("./script/water_physics.gd")
var buoyancy_gizmo = preload("./script/buoyancy_gizmo.gd")
var viewport_size

var auto_buoy_button

signal input(event)

func forward_spatial_gui_input(p_camera, p_event):
	if not editor_camera: editor_camera = p_camera

func _ready():
	viewport_size = get_viewport().size
	
func _enter_tree():
	name = 'WaterPackPlugin'
	
	print("water plugin enter tree")
	add_custom_type("BuoyantBody", "RigidBody", water_physics, preload("buoyant_body.png"))
	add_custom_type("Water", "MeshInstance", preload("./script/water.gd"), preload("water.png"))
	add_custom_type("BuoyancyPoints", "Resource", preload("./script/buoyancy_points.gd"), preload("water.png"))
	
	#auto_buoy_button = preload('./editor_gui_stuff/GenBuoyancyButton.tscn')
	#add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, auto_buoy_button)
	#auto_buoy_button.hide()
	
	if not ProjectSettings.has_setting("physics/3d/water_linear_damp"):
		ProjectSettings.set_setting("physics/3d/water_linear_damp", 1.0)
		ProjectSettings.add_property_info({
			"name": "physics/3d/water_linear_damp",
			"type": TYPE_REAL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "linear drag force underwater"
		})
	if not ProjectSettings.has_setting("physics/3d/water_angular_damp"):
		ProjectSettings.set_setting("physics/3d/water_angular_damp", 1.0)
		ProjectSettings.add_property_info({
			"name": "physics/3d/water_angular_damp",
			"type": TYPE_REAL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "angular drag force underwater"
		})

func create_spatial_gizmo(for_spatial):
	if for_spatial is water_physics:
		var buoyancy_points = buoyancy_gizmo.new(self, for_spatial)
		return buoyancy_points

func _exit_tree():
	remove_custom_type("Water")
	remove_custom_type("BuoyantBody")
	remove_custom_type("BuoyancyPoints")
	
	print("water plugin enter tree")

func handles(object):
	return true

func _input(event):
	emit_signal('input', event)