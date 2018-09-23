shader_type spatial;

uniform vec4 water_color:hint_color;//= vec4(20, 30, 30, 230);
uniform float blur:hint_range(0,10);
uniform float fade_depth = 20;//0~FLOAT_MAX
uniform float distort_factor:hint_range(0,1);
uniform float distort_speed:hint_range(0,1);
uniform sampler2D distort_texture:hint_normal;

//dont put any in front of water
//use camera to view water, and filter infront somthing , when cull plane enable

void fragment(){
	vec2 distortion = vec2(0,0);
	// distort
	distortion = distort_factor*texture(distort_texture,UV+TIME*distort_speed).rg;
	EMISSION = textureLod(SCREEN_TEXTURE, SCREEN_UV+distortion, blur).rgb;
	
	//fade
	float depth_tex = texture(DEPTH_TEXTURE, SCREEN_UV+distortion).r;
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4((SCREEN_UV+distortion) * 2.0 - 1.0, depth_tex * 2.0 - 1.0, 1.0);
	world_pos.xyz /= world_pos.w;
	EMISSION = mix(EMISSION, water_color.rgb, clamp((VERTEX.z - world_pos.z)*0.01, 0.0, 1.0));
	
	METALLIC = 1.0;
	ROUGHNESS = 1.0;
	ALBEDO = vec3(0);
}