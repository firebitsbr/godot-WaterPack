tool
extends Node2D

export(GradientTexture) var water_color setget set_water_color
export(Color) var surface_color = Color(1,1,1) setget set_surface_color

export(int) var water_height = 300 setget set_water_height
export(int, 0, 163884) var water_depth = 300 setget set_water_depth
export(int) var water_start = 0 setget set_water_start
export(int) var water_end = 1024 setget set_water_end

export(int, 2, 1024) var resolution = 128 setget set_resolution

var points = []

var ready = false

func _ready():
	ready = true
	for i in range(resolution):
		points.append(wave_particle.new())
	set_polygon()
	set_water_color(water_color)
	set_surface_color(surface_color)
	
	splash(Vector2(512, 360), Vector2(0, 200))

func set_resolution(value):
	resolution = value
	set_polygon()

func set_water_height(value):
	water_height = value
	if ready: $Polygon2D.material.set_shader_param('water_height', value)
	set_polygon()

func set_water_depth(value):
	water_depth = value
	if ready: $Polygon2D.material.set_shader_param('water_depth', value)
	set_polygon()

func set_water_start(value):
	water_start = value
	set_polygon()

func set_water_end(value):
	water_end = value
	set_polygon()

func set_water_color(value):
	water_color = value
	if ready: $Polygon2D.texture = value

func set_surface_color(value):
	surface_color = value
	if ready: $Polygon2D.set_color(value)

func set_polygon():
	if not ready: return
	
	var poly = $Polygon2D
	if not poly: return
	
	var polygon = PoolVector2Array()
	var uv = PoolVector2Array()
	
	polygon.append(Vector2(water_start, water_height+water_depth))
	uv.append(Vector2(0,0))
	
	for i in range(resolution-1):
		var t1 = float(i)/(resolution-1)
		var t2 = float(i+1)/(resolution-1)
		var x1 = (1-t1)*water_start + t1*water_end
		var x2 = (1-t2)*water_start + t2*water_end
		polygon.append(Vector2(x1, water_height+points[i].height))
		uv.append(Vector2(t1,1))
		polygon.append(Vector2(x2, water_height+points[i+1].height))
		uv.append(Vector2(t2,1))
		polygon.append(Vector2(x2, water_height+water_depth-(1 if i != resolution-2 else 0)))
		uv.append(Vector2(1,0))
	
	poly.set_polygon(polygon)
	poly.set_uv(uv)

func _physics_process(delta):
	for i in range(points.size()-1):
		var place_hold_particle = wave_particle.new()
		var left_neighbour = points[i-1] if i != 0 else place_hold_particle
		var right_neighbour = points[i+1] if i != points.size() else place_hold_particle
		
		points[i].update(delta, left_neighbour, right_neighbour)
	set_polygon()

func splash(pos, vel):
	var splash_inst = preload('res://addons/water_pack/preset/2d_splash.tscn').instance()
	splash_inst.position = pos
	splash_inst.set_impact_vel(vel)
	splash_inst.modulate = surface_color
	add_child(splash_inst)
	
	var index = range_lerp(pos.x, water_start, water_end, 0, resolution);
	
	points[floor(index)].velocity = -vel.length()*wave_particle.dampness()*10.0
	points[ceil(index)].velocity = -vel.length()*wave_particle.dampness()*10.0


class wave_particle:
	var height = 0.0
	var velocity = 0.0
	
	func update(delta, n1, n2):
		var accel = -height*stiffness() - velocity*dampness();
		accel += (n1.height - height) * propagation();
		accel += (n2.height - height) * propagation();
		
		velocity += accel * delta
		height += velocity * delta
	
	static func stiffness(): return 120.0
	static func propagation(): return 140.0
	static func dampness(): return 6.0