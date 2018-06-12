tool
extends Node

const NUMBER_OF_WAVES = 10

const resolution = 64
const levels = 10
const scale = 256.0
const morphing_levels = 2

var lod
var initialized = false

export(float, 0, 10000) var wavelength = 60.0 setget set_wavelength
export(float, 0, 1) var steepness = 0.01 setget set_steepness
export(float, 0, 10000) var amplitude = 0.25 setget set_amplitude
export(Vector2) var wind_direction = Vector2(1, 0) setget set_wind_direction
export(float, 0, 1) var wind_align = 0.0 setget set_wind_align
export(float) var speed = 10.0 setget set_speed

export(bool) var noise_enabled = true setget set_noise_enabled
export(float) var noise_amplitude = 1.27 setget set_noise_amplitude
export(float) var noise_frequency = 0.008 setget set_noise_frequency
export(float) var noise_speed = 0.44 setget set_noise_speed

export(float) var foam_height = 0.8 setget set_foam_height

export(int) var seed_value = 0 setget set_seed

var waves = []
var waves_in_tex = ImageTexture.new()

func _ready():
	# Prepare the LOD material and geometries
	var shader = preload('res://addons/water_pack/shader/LOD.shader')
	var shader_mat = ShaderMaterial.new()
	shader_mat.shader = shader
	shader_mat.set_shader_param('resolution', resolution)
	shader_mat.set_shader_param('morph_levels', morphing_levels)
	shader_mat.set_shader_param('noise', preload('res://addons/water_pack/texture/noise_perlin.jpg'))
	shader_mat.set_shader_param('noise_params', get_noise_params())
	shader_mat.set_shader_param('foam', preload('res://addons/water_pack/texture/foam.png'))
	
	lod = preload('res://addons/water_pack/script/LODPlane.gd')
	lod = lod.new(resolution, levels, scale, morphing_levels)
	lod.generate(shader_mat)
	add_child(lod, true)
	
	#Get the waves ready
	waves_in_tex = ImageTexture.new()
	update_waves()


func _process(delta):
	set_shader_param('time_offset', OS.get_ticks_msec()/1000.0 * speed)
	initialized = true

func set_wavelength(value):
	wavelength = value
	if initialized:
		update_waves()

func set_steepness(value):
	steepness = value
	if initialized:
		update_waves()

func set_amplitude(value):
	amplitude = value
	if initialized:
		update_waves()

func set_wind_direction(value):
	wind_direction = value
	if initialized:
		update_waves()

func set_wind_align(value):
	wind_align = value
	if initialized:
		update_waves()

func set_seed(value):
	seed_value = value
	if initialized:
		update_waves()

func set_speed(value):
	speed = value
	set_shader_param('speed', value)

func set_foam_height(value):
	foam_height = value
	set_shader_param('foam_height', value)

func set_noise_enabled(value):
	noise_enabled = value
	if not initialized: return
	
	var old_noise_params = get_shader_param('noise_params', 0)
	if old_noise_params:
		old_noise_params.d = 1 if value else 0
		set_shader_param('noise_params', old_noise_params)
	else:
		set_shader_param('noise_params', get_noise_params())

func set_noise_amplitude(value):
	noise_amplitude = value
	if not initialized: return
	
	var old_noise_params = get_shader_param('noise_params', 0)
	if old_noise_params:
		old_noise_params.x = value
		set_shader_param('noise_params', old_noise_params)
	else:
		set_shader_param('noise_params', get_noise_params())

func set_noise_frequency(value):
	noise_frequency = value
	if not initialized: return
	
	var old_noise_params = get_shader_param('noise_params', 0)
	if old_noise_params:
		old_noise_params.y = value
		set_shader_param('noise_params', old_noise_params)
	else:
		set_shader_param('noise_params', get_noise_params())

func set_noise_speed(value):
	noise_speed = value
	if not initialized: return
	
	var old_noise_params = get_shader_param('noise_params', 0)
	if old_noise_params:
		old_noise_params.z = value
		set_shader_param('noise_params', old_noise_params)
	else:
		set_shader_param('noise_params', get_noise_params())

func get_displace(position):
	
	var new_p;
	if typeof(position) == TYPE_VECTOR3:
		new_p = Vector3(position.x, 0.0, position.z)
	elif typeof(position) == TYPE_VECTOR2:
		new_p = Vector3(position.x, 0.0, position.y)
	else:
		printerr('Position is not a vector3!')
		breakpoint
	
	var w; var amp; var steep; var phase; var dir
	for i in waves:
		amp = i['amplitude']
		if amp == 0.0: continue
		
		dir = Vector2(i['wind_directionX'], i['wind_directionY'])
		w = i['frequency']
		steep = i['steepness'] / (w*amp)
		phase = 2.0 * w
		
		var W = position.dot(w*dir) + phase * OS.get_ticks_msec()/1000.0 * speed
		
		new_p.x += steep*amp * dir.x * cos(W)
		new_p.z += steep*amp * dir.y * cos(W)
		new_p.y += amp * sin(W)
	return new_p;

func update_waves():
	#Generate Waves..
	seed(seed_value)
	var amp_length_ratio = amplitude / wavelength
	waves.clear()
	for i in range(NUMBER_OF_WAVES):
		var _wavelength = rand_range(wavelength/6.0, wavelength)
		var _wind_direction = wind_direction.rotated(rand_range(-PI, PI)*(1-wind_align))
		
		waves.append({
			'amplitude': _wavelength * amp_length_ratio,
			'steepness': rand_range(0, steepness),
			'wind_directionX': _wind_direction.x,
			'wind_directionY': _wind_direction.y,
			'frequency': sqrt(0.098 * TAU/_wavelength)
		})
	#Put Waves in Texture..
	var img = Image.new()
	img.create(5, NUMBER_OF_WAVES, false, Image.FORMAT_RF)
	img.lock()
	for i in range(NUMBER_OF_WAVES):
		var wv = waves[i]
		img.set_pixel(0, i, Color(wv.amplitude, 0,0,0))
		img.set_pixel(1, i, Color(wv.steepness, 0,0,0))
		img.set_pixel(2, i, Color(wv.wind_directionX, 0,0,0))
		img.set_pixel(3, i, Color(wv.wind_directionY, 0,0,0))
		img.set_pixel(4, i, Color(wv.frequency, 0,0,0))
	img.unlock()
	waves_in_tex.create_from_image(img, 0)
	
	set_shader_param('waves', waves_in_tex)

func get_noise_params():
	return Plane(noise_amplitude, noise_frequency, noise_speed, noise_enabled)

func set_shader_param(uniform, value):
	if lod:
		for i in lod.get_children():
			i.material_override.set_shader_param(uniform, value)

func get_shader_param(uniform, indx):
	if lod:
		return lod.get_child(indx).material_override.get_shader_param(uniform)