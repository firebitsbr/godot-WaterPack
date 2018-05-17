shader_type spatial;
//render_mode world_vertex_coords;
 
//wave4 
uniform float TIME;
uniform float gerstnerIntensity = 1;
uniform vec4 water4Amplitude;
uniform vec4 water4Frequency;
uniform vec4 water4Steepness;
uniform vec4 water4Speed;
uniform vec4 water4DirectionAB;
uniform vec4 water4DirectionCD;

vec3 GerstnerOffset(vec2 xzVtx, float steepness, float amp, float freq, float speed, vec2 dir)
{
	vec3 offsets;
	offsets.x =
		steepness * amp * dir.x *
		cos(freq * dot(dir, xzVtx) + speed * TIME);
	offsets.z =
		steepness * amp * dir.y *
		cos(freq * dot(dir, xzVtx) + speed * TIME);
	offsets.y =
		amp * sin(freq * dot(dir, xzVtx) + speed * TIME);
	return offsets;
}
vec3 GerstnerOffset4(vec2 xzVtx, vec4 steepness, vec4 amp, vec4 freq, vec4 speed, vec4 dirAB, vec4 dirCD)
{
	vec3 offsets;
	vec4 AB = steepness.xxyy * amp.xxyy * dirAB.xyzw;
	vec4 CD = steepness.zzww * amp.zzww * dirCD.xyzw;
	vec4 dotABCD = freq.xyzw * vec4(dot(dirAB.xy, xzVtx), dot(dirAB.zw, xzVtx), dot(dirCD.xy, xzVtx), dot(dirCD.zw, xzVtx));
	vec4 COS = cos(dotABCD + TIME * speed);
	vec4 SIN = sin(dotABCD + TIME * speed);

	offsets.x = dot(COS, vec4(AB.xz, CD.xz));
	offsets.z = dot(COS, vec4(AB.yw, CD.yw));
	offsets.y = dot(SIN, amp);

	return offsets;
}
vec3 GerstnerNormal(vec2 xzVtx, float amp, float freq, float speed, vec2 dir)
{
	vec3 nrml = vec3(0, 0, 0);
	nrml.x -=
		dir.x * (amp * freq) *
		cos(freq * dot(dir, xzVtx) + speed * TIME);
	nrml.z -=
		dir.y * (amp * freq) *
		cos(freq * dot(dir, xzVtx) + speed * TIME);
	return nrml;
}

vec3 GerstnerNormal4(vec2 xzVtx, vec4 amp, vec4 freq, vec4 speed, vec4 dirAB, vec4 dirCD)
{
	vec3 nrml = vec3(0, 2.0, 0);

	vec4 AB = freq.xxyy * amp.xxyy * dirAB.xyzw;
	vec4 CD = freq.zzww * amp.zzww * dirCD.xyzw;

	vec4 dotABCD = freq.xyzw * vec4(dot(dirAB.xy, xzVtx), dot(dirAB.zw, xzVtx), dot(dirCD.xy, xzVtx), dot(dirCD.zw, xzVtx));

	vec4 COS = cos(dotABCD + TIME * speed);

	nrml.x -= dot(COS, vec4(AB.xz, CD.xz));
	nrml.z -= dot(COS, vec4(AB.yw, CD.yw));

	nrml.xz *= gerstnerIntensity;
	nrml = normalize(nrml);

	return nrml;
}


void vertex()
{
//	vec3 offs = GerstnerOffset(VERTEX.xz, wave1steepness, wave1amplitude, wave1frequency, wave1speed, wave1direction);
//	vec3 nrml = GerstnerNormal(VERTEX.xz,  wave1amplitude, wave1frequency, wave1speed, wave1direction);
	vec3 offs = GerstnerOffset4(VERTEX.xz, water4Steepness, water4Amplitude, water4Frequency, water4Speed, water4DirectionAB, water4DirectionCD);
	vec3 nrml = GerstnerNormal4(VERTEX.xz, water4Amplitude, water4Frequency, water4Speed, water4DirectionAB, water4DirectionCD);

	VERTEX = VERTEX + offs;
	NORMAL = nrml;
}
 
// normal map wave
uniform vec2 velocity = vec2(0.01, 0);
uniform vec4 waterColor : hint_color = vec4(40, 80, 60, 190);
uniform float roughness : hint_range(0, 1) = 0.1;
uniform float metalness : hint_range(0, 1) = 0.6;
uniform float specular : hint_range(0, 1) = 0.1;
uniform sampler2D normalMap;
uniform vec2 norMapScale = vec2(10, 10);
uniform float refraction = 10;
uniform float waveScale : hint_range(0, 1) = 1;

void fragment()
{
	vec2 uv = mod(norMapScale * UV + TIME * velocity, 1);
	vec3 normal = texture(normalMap, uv).rgb;
	normal = mix(vec3(1,1,1),normal,waveScale) ;  
	ALBEDO = waterColor.rgb;
	ALPHA = waterColor.a;
	ROUGHNESS = roughness;
	METALLIC = metalness;
	SPECULAR = specular;
	NORMALMAP = normalize(normal);
}