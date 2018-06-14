tool
extends EditorPlugin

var editor_camera;
var editor_cam_backup_transform
var water_physic = preload("./script/water_physic.gd")
var buoyancy_gizmo = preload("./script/buoyancy_gizmo.gd")

func forward_spatial_gui_input(p_camera, p_event):
	editor_camera = p_camera
	
	#if p_camera.transform != editor_cam_backup_transform:
	#	for node in get_tree().get_nodes_in_group("water"):
	#		if node.use_reflection:
	#			var reflect_camera = node.get_node("./reflect_vp/reflect_cam")
	#			mirror(p_camera, reflect_camera, node) 

func mirror(origin, target, mirror_plane):
	target.transform = mirror_plane.get_global_transform().affine_inverse()*origin.get_global_transform()
	target.transform.origin.y *= -1
	target.transform.basis.y.x *= -1
	target.transform.basis.x.y *= -1
	target.transform.basis.z.y *= -1
	target.transform.basis.y.z *= -1

func _enter_tree():
	name = 'WaterPackPlugin'
	
	print("water plugin enter tree")
	set_input_event_forwarding_always_enabled()
	add_custom_type("Water", "MeshInstance", preload("./script/water.gd"), preload("water.png"))
	add_custom_type("BuoyancyPoints", "Resource", preload("./script/buoyancy_points.gd"), preload("water.png"))
	for node in get_tree().get_nodes_in_group("water"):
		node._ready()

func create_spatial_gizmo(for_spatial):
	if for_spatial is water_physic:
		var buoyancy_points = buoyancy_gizmo.new(for_spatial)
		return buoyancy_points

func _exit_tree():
	remove_custom_type("Water")
	remove_custom_type("BuoyancyPoints")