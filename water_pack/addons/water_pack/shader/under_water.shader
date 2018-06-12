shader_type spatial;
render_mode unshaded, cull_disabled, world_vert_coords, skip_vertex_transform, depth_test_disabled;

varying vec3 world_vert;

void vertex(){
    VERTEX = (INV_PROJECTION_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_vert = (CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment(){
    //this code can be removed.
    if(world_vert.y > 0.0)
        ALPHA = 0.0;
}
