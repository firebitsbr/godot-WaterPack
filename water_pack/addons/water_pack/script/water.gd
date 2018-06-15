tool
extends MeshInstance
export var use_reflection = true # use viewport camera reflection

var reflect_camera
var reflect_viewport

var plugin
#export var hide_ViewPort = true # hide reflect and refract viewport in editor
export(Vector2) var velocity
export(float, 0, 10) var density 

func get_layer(type, name):
	for i in range(1, 21):
		var layer_name = ProjectSettings.get_setting(str("layer_names/"+type+"/layer_", i))
		if layer_name==name:
			return (i-1)

func _enter_tree():
	if !is_in_group("water"):
		add_to_group("water")

func _ready():
	
	var water_layer  = get_layer("3d_render","water")
	if water_layer != null:
		layers |= 1 >> water_layer
	
	if(use_reflection):
		# add viewport
		reflect_viewport = Viewport.new()
		reflect_viewport.size = get_viewport().size
		reflect_viewport.render_target_v_flip = true
		reflect_viewport.transparent_bg = true
		#reflect_viewport.keep_3d_linear=true //3.1
		reflect_viewport.name = "reflect_vp"
		
		# add camera
		reflect_camera = Camera.new()
		if water_layer == null:
			print("set \"water\" in  project -> 3d render layers")
		
		reflect_camera.cull_mask &= ~(1<<water_layer)
		reflect_camera.name="reflect_cam"
		
		add_child(reflect_viewport)
		reflect_viewport.add_child(reflect_camera)
		
#		material_override = preload('../material/dev_water.material')
		material_override.resource_local_to_scene = true;
		
		yield(get_tree(), 'idle_frame')
		yield(get_tree(), 'idle_frame')
		
		material_override.set_shader_param("reflect_texture",reflect_viewport.get_texture())

func mirror(origin, target):
	if not origin or not target:
		return
	
	target.transform = get_global_transform().affine_inverse()*origin.get_global_transform()
	# TODO use martix simplfy code
	target.transform.origin.y *= -1
	target.transform.basis.y.x *= -1
	target.transform.basis.x.y *= -1
	target.transform.basis.z.y *= -1
	target.transform.basis.y.z *= -1

func _process(delta):
	
	if use_reflection:
		var current_cam
		if Engine.is_editor_hint():
			plugin = get_node('/root/EditorNode/WaterPackPlugin')
			current_cam = plugin.editor_camera
		else:
			current_cam = get_viewport().get_camera()
		
		mirror(current_cam, reflect_camera)