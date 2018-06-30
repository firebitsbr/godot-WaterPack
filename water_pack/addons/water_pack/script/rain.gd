extends Spatial

var plugin

func _ready():
	if Engine.is_editor_hint():
		plugin = get_node('/root/EditorNode/WaterPackPlugin')

func _process(delta):
	var camera
	
	if Engine.is_editor_hint():
		camera = plugin.editor_camera
	else:
		camera = get_viewport().get_camera()
	
	if not camera: return
	
	global_transform.origin = camera.global_transform.origin
	translation.y += 5.0