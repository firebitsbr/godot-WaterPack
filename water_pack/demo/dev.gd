tool
extends Node


var bouyancy_points = [{pos = Vector3(0,0,0), vector = Vector3(0,1,0)},{pos = Vector3(0,0,1), vector = Vector3(0,1,0)}]

func _get(property):
    for idx in range(bouyancy_points.size()):
        if property == "{level1}/{level2}/{level3}".format({"level1":"bouyancy_points","level2":idx,"level3":"position"}):
            return bouyancy_points[idx].pos 
        if property == "{level1}/{level2}/{level3}".format({"level1":"bouyancy_points","level2":idx,"level3":"vector"}):
            return bouyancy_points[idx].vector

func _set(property, value):
    for idx in range(bouyancy_points.size()):
        if property == "{level1}/{level2}/{level3}".format({"level1":"bouyancy_points","level2":idx,"level3":"position"}):
            bouyancy_points[idx].pos = value
            return true
        if property == "{level1}/{level2}/{level3}".format({"level1":"bouyancy_points","level2":idx,"level3":"vector"}):
            bouyancy_points[idx].vector = value
            return true
    return false

func _get_property_list():
    var custom_inpector = []
    for idx in range(bouyancy_points.size()):
        var inspector_item = {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT,
            "name": "{level1}/{level2}/{level3}".format({"level1":"bouyancy_points","level2":idx,"level3":"position"}),
            "type": TYPE_VECTOR3
           }
        custom_inpector.append(inspector_item)
        inspector_item = {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT,
            "name": "{level1}/{level2}/{level3}".format({"level1":"bouyancy_points","level2":idx,"level3":"vector"}),
            "type": TYPE_VECTOR3
           }
        custom_inpector.append(inspector_item)
    return custom_inpector
