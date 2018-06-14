tool

extends Resource

export var data = []  # [{pos = Vector3(0,0,0), vector = Vector3(0,1,0)}]
signal data_changed

func set_all(length):
    for point in data:
        point.Vector = point.Vector.normalized()*length

func _get(property):
    if property =="bouyancy points size":
        return data.size()
    for idx in range(data.size()):
        if property == "{level1}/{level2}/{level3}".format({"level1":"bouyancy points","level2":idx,"level3":"position"}):
            return data[idx].pos 
        if property == "{level1}/{level2}/{level3}".format({"level1":"bouyancy points","level2":idx,"level3":"vector3"}):
            return data[idx].vector

func _set(property, value):
    if property =="bouyancy points size":
        for idx in range(value-data.size()):
            data.push_back({pos = Vector3(0,0,0), vector = Vector3(0,0,0)})
        for idx in range(-value+data.size()):
            data.pop_back()
        emit_signal("data_changed")
        return true
    for idx in range(data.size()):
        if property == "{level1}/{level2}/{level3}".format({"level1":"bouyancy points","level2":idx,"level3":"position"}):
            data[idx].pos = value
            emit_signal("data_changed")
            return true
        if property == "{level1}/{level2}/{level3}".format({"level1":"bouyancy points","level2":idx,"level3":"vector3"}):
            data[idx].vector = value
            emit_signal("data_changed")
            return true
    return false

func _get_property_list():
    var custom_inpector = []
    var inspector_item
    inspector_item = {
        "hint": PROPERTY_HINT_NONE,
        "usage": PROPERTY_USAGE_DEFAULT,
        "name": "bouyancy points size",
        "type": TYPE_INT
       }
    custom_inpector.append(inspector_item)
    for idx in range(data.size()):
        inspector_item = {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT,
            "name": "{level1}/{level2}/{level3}".format({"level1":"bouyancy points","level2":idx,"level3":"position"}),
            "type": TYPE_VECTOR3
           }
        custom_inpector.append(inspector_item)
        inspector_item = {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT,
            "name": "{level1}/{level2}/{level3}".format({"level1":"bouyancy points","level2":idx,"level3":"vector3"}),
            "type": TYPE_VECTOR3
           }
        custom_inpector.append(inspector_item)
    return custom_inpector
