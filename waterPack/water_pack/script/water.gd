
extends MeshInstance
export var useRefration = true
#export var hideRefViewPort = true # hide reflect and refract viewport

var reflectCamera
func _ready():
	if(useRefration):
		var reflectVp = Viewport.new()
		reflectVp.size=get_viewport().size
		reflectVp.render_target_v_flip=true
		reflectCamera = Camera.new()	
		add_child(reflectVp)
		reflectVp.add_child(reflectCamera)
		material_override.set_shader_param("reflectTexture",reflectVp.get_texture())
		print("Hello world")
	

func _process(delta):
	if(useRefration):
		var currentCam = get_viewport().get_camera()
		var refleCam = reflectCamera
		refleCam.transform = get_global_transform().affine_inverse()*currentCam.get_global_transform()
		# todo use martix simplfy code
		refleCam.transform.origin.y *= -1
		refleCam.transform.basis.y.x *= -1
		refleCam.transform.basis.x.y *= -1
		refleCam.transform.basis.z.y *= -1
		refleCam.transform.basis.y.z *= -1