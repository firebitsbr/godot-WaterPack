shader_type spatial;
render_mode skip_vertex_transform;

uniform sampler2D reflect_texture;

uniform sampler2D waves;
uniform float amplitude;
uniform float frequency;
uniform float speed;

uniform vec4 colour: hint_color;
uniform float density;

uniform bool use_planar_reflect;
//NOISE FUNCTION WITH RESPECTIVE HELPERS
float cubic(float c0, float p0, float p1, float c1, float t) {
	float t2 = t*t;
	float t3 = t2*t;
	return (t3-t2-t+1.0)*p0 + (t3-2.0*t2+t)*c0 + (t3-t2)*c1 + (-3.0*t3+4.0*t2)*p1;
}
float noise3D(vec3 p) {
	float iz = floor(p.z);
	float fz = fract(p.z);
	
	vec2 offset = vec2(0.356, 0.879) * 0.64338;
	
	float a = texture(waves, p.xy + offset * iz).r;
	float b = texture(waves, p.xy + offset * (iz+1.0)).r;
	float ca = texture(waves, p.xy + offset * (iz-1.0)).r;
	float cb = texture(waves, p.xy + offset * (iz+2.0)).r;
	
	return cubic(ca, a, b, cb, fz);
}
float perlin(vec2 pos, float time) {
	float p_noise = 2.0 * noise3D(vec3(pos.xy*frequency, time*speed))*amplitude - 1.0;
	return p_noise + 2.0 * noise3D(vec3(pos.xy*frequency*2.0, time*speed+4.3))*amplitude/2.0 - 1.0;
}

vec3 wave_normal(vec2 pos, float time, float res) {
	vec2 _res = vec2(res,0);
	
	vec3 right = vec3(pos.xy + _res.xy, perlin(pos + _res.xy, time)).xzy;
	vec3 left = vec3(pos.xy - _res.xy, perlin(pos - _res.xy, time)).xzy;
	vec3 down = vec3(pos.xy + _res.yx, perlin(pos + _res.yx, time)).xzy;
	vec3 up = vec3(pos.xy - _res.yx, perlin(pos - _res.yx, time)).xzy;
	
	return -normalize(cross(right-left, down-up));
}

//FRESNEL FUNCTION
float fresnel(float n1, float n2, float cos_theta) {
	float R0 = pow((n1 - n2) / (n1+n2), 2);
	float fres = R0 + (1.0 - R0)*pow(1.0 - abs(cos_theta), 5);
	
	//float critical_angle = asin(n1 / n2);
	//if(acos(abs(cos_theta)) > critical_angle && sign(cos_theta) == -1.0) return 1.0;
	
	return fres;
}

//function from https://gamedev.stackexchange.com/questions/92015/optimized-linear-to-srgb-glsl
vec4 to_linear(vec4 sRGB) {
	bvec4 cutoff = lessThan(sRGB, vec4(0.04045));
	vec4 higher = pow((sRGB + vec4(0.055))/vec4(1.055), vec4(2.4));
	vec4 lower = sRGB/vec4(12.92);
	
	return mix(higher, lower, cutoff);
}

varying vec3 vert_coord;
varying float vert_dist;
varying vec3 eye_vector;

void vertex() {
	VERTEX = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	//pass varyings and transform vertex in view space
	vert_coord = VERTEX;
	VERTEX = (INV_CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz;
	eye_vector = (CAMERA_MATRIX * vec4(normalize(VERTEX), 0.0)).xyz;
	vert_dist = length(VERTEX);
}

void fragment() {
	//calculate normals based on wave
	NORMAL = wave_normal(vert_coord.xz, TIME, vert_dist/30.0);
	
	//calculate reflectiveness based on fresnel and camera angle
	float eye_dot_norm = dot(eye_vector, NORMAL);
	float n1 = 1.0, n2 = 1.3333;
	float reflectiveness = fresnel(n1, n2, eye_dot_norm);
	
	vec2 distort_uv = SCREEN_UV - NORMAL.xz*0.05;
	vec3 water_colour = texture(SCREEN_TEXTURE, distort_uv).rgb;
	vec4 fog_colour = colour;
	
	//calculate refraction with fog
	float depth_tex = texture(DEPTH_TEXTURE, distort_uv).r;
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4(distort_uv * 2.0 - 1.0, depth_tex * 2.0 - 1.0, 1.0);
	world_pos.xyz /= world_pos.w;
	fog_colour.a = clamp((VERTEX.z - world_pos.z) * density, 0.0, 1.0);
	water_colour = mix(water_colour, fog_colour.rgb, fog_colour.a);
	
	//calculate planar reflection(if there is one)
	vec4 reflect_colour = to_linear(texture(reflect_texture, distort_uv));
	reflect_colour = use_planar_reflect ? reflect_colour : vec4(0.0);
	
	ROUGHNESS = reflect_colour.a;
	METALLIC = reflectiveness * (1.0-reflect_colour.a);
	ALBEDO = vec3(reflectiveness * (1.0-reflect_colour.a));
	EMISSION = mix(water_colour, reflect_colour.rgb, reflectiveness);
	
	//transform normal to view space for lighting
	NORMAL = (INV_CAMERA_MATRIX * vec4(NORMAL, 0.0)).xyz;
}

void light() {
	DIFFUSE_LIGHT = vec3(0.0);
}