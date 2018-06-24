extends RigidBody

# todo
# auto generate buoyancy point
# editor buoyancy view

export(NodePath) var water
export(Resource) var buoyancy_points  #TODO filter CUSTOM buoyancy_points type when support
export var buoyancy_multiplier = 1.0

export var debug = true

onready var water_node = get_node(water)
var base_linear_damp
var base_angular_damp

func _ready():
	base_linear_damp = linear_damp
	base_angular_damp = angular_damp
	
	if base_linear_damp < 0.0:
		base_linear_damp = ProjectSettings.get_setting("physics/3d/water_linear_damp")
	if base_angular_damp < 0.0:
		base_angular_damp = ProjectSettings.get_setting("physics/3d/water_angular_damp")
	
	if debug:
		var debug_geom = ImmediateGeometry.new()
		debug_geom.name = 'debug'
		add_child(debug_geom)
		debug_geom.set_as_toplevel(true)
		debug_geom.global_transform = Transform()
		
		var mat = SpatialMaterial.new()
		mat.flags_unshaded = true
		mat.flags_use_point_size = true
		#mat.flags_no_depth_test = true
		mat.params_point_size = 10
		debug_geom.material_override = mat

func _integrate_forces(state):
	
	#Never going to be called without `tool` keyword
	#if Engine.is_editor_hint():
	#	update_buoyancy_points()
	if buoyancy_points.data.size() != 0:
		var water_velocity = Vector3()
		var water_density = 1.0
		if water_node is preload("res://addons/water_pack/script/water.gd"):
			water_velocity = water_node.velocity
			water_density = water_node.density
		
		var under_water_points = 0
		var forces = []
		for point in buoyancy_points.data:
			# buoyancy
			var global_point = global_transform.xform(point)
			var water_height = water_node.get_height(global_point)
			var depth = water_node.global_transform.origin.y - global_transform.xform(point).y
			if water_height - global_point.y > 0:
				under_water_points += 1
				var force = water_density*Vector3(0,1,0)*depth + Vector3(water_velocity.x,0,water_velocity.y)
				apply_impulse(point, force*state.step*buoyancy_multiplier)
				forces.append([point, force*buoyancy_multiplier])
		# damp
		linear_damp = water_density * under_water_points/buoyancy_points.data.size() * base_linear_damp
		angular_damp = water_density * under_water_points/buoyancy_points.data.size() * base_angular_damp
		
		if debug:
			$debug.clear()
			$debug.begin(Mesh.PRIMITIVE_POINTS)
			for point in buoyancy_points.data:
				$debug.add_vertex(global_transform.xform(point))
			$debug.end()
			
			$debug.begin(Mesh.PRIMITIVE_LINES)
			for force in forces:
				$debug.add_vertex(global_transform.xform(force[0]))
				$debug.add_vertex(global_transform.xform(force[0]) + force[1])
			$debug.end()
