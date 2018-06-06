shader_type spatial;
render_mode vertex_lighting, world_vertex_coords;

uniform sampler2D wave_bump: hint_black;

uniform highp float speed = 0.1;
uniform float amplitude = 0.3;
uniform float height = 0.0;

uniform float fog_density = 1.0;
uniform vec4 fog_colour: hint_color;

uniform float roughness = 0.0;
uniform float metallic = 1.0;

varying vec3 world_pos;
varying vec3 eye_vector;

void vertex() {
	VERTEX.y += texture(wave_bump, UV*20.0 + vec2(TIME, 0.0)*speed).r;
	VERTEX.y += texture(wave_bump, UV*20.0 + vec2(0.0, TIME)*speed - 0.5).r;
	VERTEX.y *= amplitude;
	VERTEX.y += height;
	
	world_pos = VERTEX;
	vec4 view_pos = INV_CAMERA_MATRIX * vec4(VERTEX, 1.0);
	eye_vector = (CAMERA_MATRIX * vec4(VERTEX, 0.0)).xyz;
}

float fresnel(float n1, float n2, float cos_theta) {
	float R0 = pow((n1 - n2) / (n1+n2), 2);
	return R0 + (1.0 - R0)*pow(1.0 - cos_theta, 5);
}

void fragment() {
	//The following two lines of code makes the water look low-poly and flat-shaded.
	NORMAL = cross(dFdx(VERTEX), dFdy(VERTEX));
	NORMAL = normalize(NORMAL);
	
	float surf_dist = FRAGCOORD.z / FRAGCOORD.w;
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	vec4 upos = (INV_PROJECTION_MATRIX * vec4(SCREEN_UV*2.0-1.0, depth*2.0-1.0,1.0));
	float fog_factor = clamp(-(upos.z/upos.w+surf_dist)*fog_density, 0.0, 1.0);
	
	float fn = fresnel(1.0, 1.33, abs(dot(NORMAL, normalize(VERTEX))));
	vec3 refraction = mix(texture(SCREEN_TEXTURE, SCREEN_UV).rgb, fog_colour.rgb, fog_factor);
	
	ROUGHNESS = roughness;
	METALLIC = metallic;
	
	ALBEDO = refraction;
}