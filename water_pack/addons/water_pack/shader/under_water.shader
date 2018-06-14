shader_type canvas_item;

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
}