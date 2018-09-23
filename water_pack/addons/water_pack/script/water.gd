tool
extends MeshInstance

export var use_planar_reflection = false setget set_planar_reflection # use viewport camera reflection
export var colour = Color(0,0.5,1) setget set_colour

var reflect_camera
var reflect_viewport

var plugin
var ready = false

export(Vector2) var velocity = Vector2()
export(float, 0, 10) var density = 1.0

func get_layer(type, name):
	for i in range(1, 21):
		var layer_name = ProjectSettings.get_setting(str("layer_names/"+type+"/layer_", i))
		if layer_name==name:
			return (i-1)

func _enter_tree():
	if !is_in_group("water"):
		add_to_group("water")

func _ready():
	ready = true
	set_planar_reflection(use_planar_reflection)

func mirror(origin, target):
	var own_global_trans = get_global_transform().affine_inverse()
	
	target.global_transform = own_global_trans*origin.get_global_transform()
	# TODO use martix simplfy code
	target.global_transform.origin.y *= -1
	target.global_transform.basis.y.x *= -1
	target.global_transform.basis.x.y *= -1
	target.global_transform.basis.z.y *= -1
	target.global_transform.basis.y.z *= -1

func _process(delta):
	
	var current_cam
	if use_planar_reflection:
		if Engine.is_editor_hint():
			plugin = get_node("/root/EditorNode/WaterPackPlugin")
			current_cam = plugin.editor_camera
			reflect_viewport.size = current_cam.get_parent().size
		else:
			current_cam = get_viewport().get_camera()
		
		if current_cam:
			mirror(current_cam, reflect_camera)
			reflect_camera.keep_aspect = current_cam.keep_aspect
			reflect_camera.projection = current_cam.projection
			reflect_camera.size = current_cam.size
			reflect_camera.fov = current_cam.fov
			reflect_camera.near = current_cam.near
			reflect_camera.far = current_cam.far
		
		$reflect_vp.render_target_update_mode = \
		Viewport.UPDATE_WHEN_VISIBLE if visible \
		else Viewport.UPDATE_DISABLED
	
	if material_override: material_override.set_shader_param("use_planar_reflect", current_cam)

func get_height(coord):
	return global_transform.origin.y

func set_colour(value):
	colour = value
	if material_override: material_override.set_shader_param("colour", value)

func set_planar_reflection(reflect):
	use_planar_reflection = reflect
	
	if not ready: return
	
	if reflect and not reflect_viewport:
		var water_layer  = get_layer("3d_render","water")
		if water_layer:
			layers |= 1 >> water_layer
		
		# add viewport
		reflect_viewport = Viewport.new()
		if Engine.is_editor_hint():
			plugin = get_node('/root/EditorNode/WaterPackPlugin')
			reflect_viewport.size = plugin.get_viewport().size / 2.0
		else:
			reflect_viewport.size = get_viewport().size / 2.0
		
		reflect_viewport.render_target_v_flip = true
		reflect_viewport.transparent_bg = true
		reflect_viewport.msaa = Viewport.MSAA_4X
		reflect_viewport.shadow_atlas_size = 512
		reflect_viewport.name = "reflect_vp"
		# add camera
		reflect_camera = Camera.new()
		if water_layer == null:
			print("set \"water\" in  project -> 3d render layers")
				
		reflect_camera.cull_mask &= ~(1<<water_layer)
		reflect_camera.name = "reflect_cam"
		
		add_child(reflect_viewport)
		reflect_viewport.owner = self
		reflect_viewport.add_child(reflect_camera)
		reflect_camera.current = true
		
		material_override.resource_local_to_scene = true
		
		yield(get_tree(), 'idle_frame')
		yield(get_tree(), 'idle_frame')
		
		var reflect_tex = reflect_viewport.get_texture()
		reflect_tex.set_flags(Texture.FLAG_FILTER)
		if not Engine.is_editor_hint(): reflect_tex.viewport_path = "/root/" + get_node("/root").get_path_to(reflect_viewport)
		
		material_override.set_shader_param("reflect_texture", reflect_viewport.get_texture())
	elif reflect_viewport:
		
		remove_child(reflect_viewport)
		reflect_viewport.owner = null
		reflect_viewport = null
		reflect_camera = null
		material_override.set_shader_param("reflect_texture", null)