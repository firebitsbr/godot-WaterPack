shader_type spatial;
render_mode unshaded, cull_disabled, world_vert_coords, skip_vertex_transform, depth_test_disabled;

varying vec3 world_vert;

void vertex(){
    VERTEX = (INV_PROJECTION_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_vert = (CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

uniform float blur:hint_range(0,10);
uniform float fade_depth = 20;//0~FLOAT_MAX
uniform float distort_factor:hint_range(0,1);
uniform float distort_speed:hint_range(0,1);
uniform sampler2D distort_texture:hint_normal;
uniform vec4 water_color : hint_color ;//= vec4(20, 30, 30, 230);
uniform bool disort_enable = true;

//dont put any in front of water
//use camera to view water, and filter infront somthing , when cull plane enable

void fragment(){
    //this code can be removed.
    if(world_vert.y > 0.0)
        ALPHA = 0.0;
}
}
