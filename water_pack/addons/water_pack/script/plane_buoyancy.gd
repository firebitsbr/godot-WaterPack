extends spatical;

export(NodePath) var water
var buoyancy_points
var buoyancy_factor
# auto generate buoyancy point
# editor buoyancy view 

func _ready():
	for node in get_childs():
		if node.type == PinJoint:
			buoyancy_points.append(node)

func _process(delta):
	var water_high = water.global_transform.basic
	var water_velocity = water.velocity
	var buoyancy_factor = water.buoyancy_factor
	for node in float_points:
		apply_impulse(node.Translation, Vector3(0,1,0)*factor+Vector3(water_velocity.x,0,water_velocity.y) )