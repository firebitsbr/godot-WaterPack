tool
extends "water.gd"

var wave_map = preload("../texture/noise_perlin.jpg")
var uncompressed_wave
var time = 0.0

export var speed = 0.1 setget set_speed
export var frequency = 0.03 setget set_frequency
export var amplitude = 0.2 setget set_amplitude

func _enter_tree():
	var img = wave_map.get_data()
	img.decompress()
	uncompressed_wave = img

func _ready():
	material_override.set_shader_param("wave_bump", wave_map)

func _process(delta):
	time += delta
	material_override.set_shader_param("time", time)

func get_height(coord):
	var wave_bump = uncompressed_wave
	var _coord = coord if typeof(coord) == TYPE_VECTOR2 else Vector2(coord.x, coord.z)
	
	var height = texture(wave_bump, _coord*frequency + Vector2(time, 0.0)*speed).r;
	height += texture(wave_bump, _coord*frequency + Vector2(0.0, time)*speed - Vector2(1,1)*0.5).g;
	height -= texture(wave_bump, _coord*frequency - Vector2(time, 0.0)*speed + Vector2(1,1)*0.12).b;
	height -= texture(wave_bump, _coord*frequency - Vector2(0.0, time)*speed + Vector2(1,1)*0.5).r;
	return height * amplitude + global_transform.origin.y;


func mirror(origin, target):
	var own_global_trans = get_global_transform().affine_inverse()
	own_global_trans.origin.y -= 1
	
	target.global_transform = own_global_trans*origin.get_global_transform()
	# TODO use martix simplfy code
	target.global_transform.origin.y *= -1
	target.global_transform.basis.y.x *= -1
	target.global_transform.basis.x.y *= -1
	target.global_transform.basis.z.y *= -1
	target.global_transform.basis.y.z *= -1
	
	return

#HELPER FUNCTION
func texture(tex, uv):
	var img = tex
	if img is Texture: img = img.get_data()
	
	var size = Vector2(img.get_width(), img.get_height())
	
	var _uv = uv*size
	_uv.x = wrapi(_uv.x, 0, size.x)
	_uv.y = wrapi(_uv.y, 0, size.y)
	
	img.lock()
	var color = img.get_pixel(_uv.x, _uv.y)
	img.unlock()
	
	return color

#SETTER FUNCTIONS
func set_speed(value):
	speed = value
	material_override.set_shader_param("speed", value)

func set_frequency(value):
	frequency = value
	material_override.set_shader_param("frequency", value)

func set_amplitude(value):
	amplitude = value
	material_override.set_shader_param("amplitude", value)