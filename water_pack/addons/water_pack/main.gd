tool
extends EditorPlugin

func forward_spatial_gui_input(p_camera, p_event):
	print("spatical action0")
	for node in get_root().get_nodes_in_group("water"):
		var reflect_camera = node.get_node("./reflect_vp/reflect_cam")
		mirror(p_camera, reflect_camera) 
	print("spatical action")

func mirror(origin, target):
	target.transform = get_global_transform().affine_inverse()*origin.get_global_transform()
	target.transform.origin.y *= -1
	target.transform.basis.y.x *= -1
	target.transform.basis.x.y *= -1
	target.transform.basis.z.y *= -1
	target.transform.basis.y.z *= -1

func _enter_tree():
	print("enter plugin tree")
	add_custom_type("water", "MeshInstance", preload("./script/water.gd"), preload("water.png"))

func _exit_tree():
	remove_custom_type("water")