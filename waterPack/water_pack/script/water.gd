
extends MeshInstance
export var use_reflection = false
#export var hideRefViewPort = true # hide reflect and refract viewport

var reflect_camera
func _ready():
	if(use_reflection):
		var reflect_viewport = Viewport.new()
		reflect_viewport.size=get_viewport().size
		reflect_viewport.render_target_v_flip=true
		reflect_camera = Camera.new()	
		add_child(reflect_viewport)
		reflect_viewport.add_child(reflect_camera)
		material_override.set_shader_param("reflectTexture",reflect_viewport.get_texture())
		print("Hello world")
	

func _process(delta):
	if(use_reflection):
		var current_cam = get_viewport().get_camera()
		var reflect_cam = reflect_camera
		reflect_cam.transform = get_global_transform().affine_inverse()*current_cam.get_global_transform()
		# todo use martix simplfy code
		reflect_cam.transform.origin.y *= -1
		reflect_cam.transform.basis.y.x *= -1
		reflect_cam.transform.basis.x.y *= -1
		reflect_cam.transform.basis.z.y *= -1
		reflect_cam.transform.basis.y.z *= -1