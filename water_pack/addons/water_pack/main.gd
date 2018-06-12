tool
extends EditorPlugin
var editor_cam_backup_transform;

func forward_spatial_gui_input(p_camera, p_event):
	if p_camera.transform != editor_cam_backup_transform:
		for node in get_tree().get_nodes_in_group("water"):
			if node.use_reflection:
				var reflect_camera = node.get_node("./reflect_vp/reflect_cam")
				mirror(p_camera, reflect_camera, node) 
		
func mirror(origin, target, mirror_plane):
	target.transform = mirror_plane.get_global_transform().affine_inverse()*origin.get_global_transform()
	target.transform.origin.y *= -1
	target.transform.basis.y.x *= -1
	target.transform.basis.x.y *= -1
	target.transform.basis.z.y *= -1
	target.transform.basis.y.z *= -1

func _enter_tree():
	print("water plugin enter tree")
	set_input_event_forwarding_always_enabled()
	add_custom_type("Water", "MeshInstance", preload("./script/water.gd"), preload("water.png"))
	add_custom_type("BuoyancyPoints", "Resource", preload("./script/buoyancy_points.gd"), preload("water.png"))
	for node in get_tree().get_nodes_in_group("water"):
		var reflect_viewport = node.get_node("./reflect_vp")
		reflect_viewport.size = get_viewport().size

func _exit_tree():
	remove_custom_type("Water")
	remove_custom_type("BuoyancyPoints")