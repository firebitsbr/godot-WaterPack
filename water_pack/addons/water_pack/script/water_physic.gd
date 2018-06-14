extends RigidBody

# todo
# auto generate buoyancy point
# editor buoyancy view

export(NodePath) var water
onready var water_node = get_node(water)
export(Resource) var buoyancy_points  #TODO filter CUSTOM buoyancy_points type when support
onready var base_linear_damp = linear_damp
onready var base_angular_damp = angular_damp


func _ready():
    pass

func _process(delta):
    if Engine.is_editor_hint():
        update_buoyancy_points()
    var water_velocity = water_node.velocity
    var water_density = water_node.density
    var under_water_points = 0
    for point in buoyancy_points.data:
        # buoyancy
        var depth = water_node.global_transform.origin.y-(global_transform.origin.y+point.pos.y)
        if depth>0:
            under_water_points +=1
            var force = water_density*point.vector*depth+ Vector3(water_velocity.x,0,water_velocity.y)
            apply_impulse(point.pos, force*delta)
    # damp        
    linear_damp = water_density* under_water_points/buoyancy_points.data.size() * base_linear_damp
    angular_damp = water_density* under_water_points/buoyancy_points.data.size() * base_angular_damp