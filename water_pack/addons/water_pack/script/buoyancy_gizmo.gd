tool
extends EditorSpatialGizmo
# TODO
# view only selected
# edit in spatial editor
var mat
var node

func _init(node):
    self.node = node
    set_spatial_node(node)
    node.buoyancy_points.connect("data_changed", self, "redraw")
    mat = SpatialMaterial.new()
    mat.flags_unshaded = true
    mat.flags_transparent = true
    mat.flags_no_depth_test = true
    mat.albedo_color = Color(0.277, 0.54, 0.74, 1)

func hightline_selected_point():
    pass

func redraw():
    clear()
    var lines = []
    var handles = []
    var buoyancy_points = node.buoyancy_points.data
    if !buoyancy_points.empty():
        for point in buoyancy_points:
            handles.append(point.pos)
            lines.append(point.pos)
            lines.append(point.pos + point.vector)
        add_handles(handles)
        add_lines(lines, mat, false)
