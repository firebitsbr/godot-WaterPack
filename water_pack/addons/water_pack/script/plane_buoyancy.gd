extends RigidBody

# todo
# auto generate buoyancy point
# editor buoyancy view
# use point data replace node
#class buoyancy_point:
#	var pos
#	var force

export(NodePath) var water
#var buoyancy_points = Array()
onready var water_node = get_node(water)
export(Resource) var buoyancy_points  #TODO CUSTOM buoyancy_points type when support

func update_buoyancy_points():
	for node in get_children():
		if node.get_class() == "Spatial":
			buoyancy_points.append(node)

func _ready():
	update_buoyancy_points()

func _process(delta):
	if Engine.is_editor_hint():
		update_buoyancy_points()
	var water_high = water_node.global_transform.basis.y
	var water_velocity = water_node.velocity
	var water_density = water_node.density
	for point in buoyancy_points:
		var depth = point.global_transform.basis.y-water_node.global_transform.basis.y
		var force = water_density*point.force*depth+ Vector3(water_velocity.x,0,water_velocity.y)
		apply_impulse(point.translation, force)

