
extends MeshInstance
export var use_reflection = false # use viewport camera reflection
#export var hide_ViewPort = true # hide reflect and refract viewport in editor

var reflect_camera

func get_layer(type, name):
	for i in range(1, 21):
		var layer_name = ProjectSettings.get_setting(str("layer_names/"+type+"/layer_", i))
		if layer_name==name:
			return 	(i-1)
	return 	null




func _ready():
	var water_layer  = get_layer("3d_render","water")
	if water_layer != null:
		layers |= 1>>water_layer
	if(use_reflection):
		var reflect_viewport = Viewport.new()
		reflect_viewport.size=get_viewport().size
		reflect_viewport.render_target_v_flip=true
		reflect_viewport.keep_3d_linear=true
		
		reflect_camera = Camera.new()	
		if water_layer == null:
			print("set \"water\" in  project -> 3d render layers")
		reflect_camera.cull_mask &= ~(1<<water_layer)
		add_child(reflect_viewport)
		reflect_viewport.add_child(reflect_camera)
		
		var mat = material_override
		mat.resource_local_to_scene = true;
		mat.set_shader_param("reflect_texture",reflect_viewport.get_texture())

func mirror(origin, target):
	target.transform = get_global_transform().affine_inverse()*origin.get_global_transform()
	# TODO use martix simplfy code
	target.transform.origin.y *= -1
	target.transform.basis.y.x *= -1
	target.transform.basis.x.y *= -1
	target.transform.basis.z.y *= -1
	target.transform.basis.y.z *= -1


func _process(delta):
	if use_reflection and !Engine.is_editor_hint():
		var current_cam = get_viewport().get_camera()
		var reflect_cam = reflect_camera
		reflect_cam.transform = get_global_transform().affine_inverse()*current_cam.get_global_transform()
		# todo use martix simplfy code
		reflect_cam.transform.origin.y *= -1
		reflect_cam.transform.basis.y.x *= -1
		reflect_cam.transform.basis.x.y *= -1
		reflect_cam.transform.basis.z.y *= -1
		reflect_cam.transform.basis.y.z *= -1
