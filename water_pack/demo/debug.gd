tool
extends EditorScript

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _run():
	for idx in range(0):
    	print(idx)

func set_bouyancy():
	var water_physic = get_scene().get_node("./boat")
	var buoyancy_data = water_physic.buoyancy_points.data
	buoyancy_data.clear()
	buoyancy_data.append({pos = Vector3(0,0,0), vector = Vector3(0,1,0)})