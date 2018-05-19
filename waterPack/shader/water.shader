shader_type spatial;
//render_mode world_vertex_coords;

uniform float TIME;
uniform vec4 waterColor : hint_color = vec4(40, 80, 60, 190);
uniform float roughness : hint_range(0, 1) = 0.1;
uniform float metalness : hint_range(0, 1) = 0.6;
uniform float specular : hint_range(0, 1) = 0.1;

// normal map wave
uniform sampler2D normalMap1;
uniform float normal1Scale : hint_range(0, 1) = 1;
uniform vec2 normal1Velocity = vec2(0.01, 0);
uniform vec2 normal1UVScale = vec2(10, 10);

uniform sampler2D normalMap2;
uniform float normal2Scale : hint_range(0, 1) = 1;
uniform vec2 normal2Velocity = vec2(0.01, 0);
uniform vec2 normal2UVScale = vec2(10, 10);

uniform float refraction : hint_range(0, 10) = 1;
uniform float proximity_fade_distance = 2;

void fragment()
{
    ROUGHNESS = roughness;
    METALLIC = metalness;
    SPECULAR = specular;

    // normal wave
    vec3 normal1 = vec3(1, 1, 1);
    vec3 normal2 = vec3(1, 1, 1);
    if (normal1Scale != 0.0)
    {
        vec2 uv1 = mod(normal1UVScale * UV + TIME * normal1Velocity, 1);
        normal1 = texture(normalMap1, uv1).rgb;
    }
    if (normal2Scale != 0.0)
    {
        vec2 uv2 = mod(normal2UVScale * UV + TIME * normal2Velocity, 1);
        normal2 = texture(normalMap2, uv2).rgb;
    }
    //MIX NORMAL
    vec3 n1 = normal1 * 2.0 - 1.0;
    vec3 n2 = normal2 * 2.0 - 1.0;
    vec3 normal = normalize(vec3(n1.xy * normal1Scale + n2.xy * normal2Scale, n1.z * n2.z));
    NORMAL = normalize(normal * 0.5 + 0.5);
	
    ALBEDO = waterColor.rgb;
	
    // transprant
    // fake refraction

	 	vec3 refra_normal = normalize( mix(NORMAL,TANGENT * NORMALMAP.x + BINORMAL * NORMALMAP.y + NORMAL * NORMALMAP.z,NORMALMAP_DEPTH) );
//		vec2 screen_offset = refra_normal.xy * refraction/VERTEX.z;
    	vec2 screen_offset = NORMAL.xy * refraction/VERTEX.z;				
	    float depth_tex = textureLod(DEPTH_TEXTURE, SCREEN_UV+screen_offset, 0.0).r;
    	vec4 world_pos = INV_PROJECTION_MATRIX * vec4( (SCREEN_UV+screen_offset)*2.0-1.0, depth_tex*2.0-1.0, 1.0);
    	world_pos.xyz/=world_pos.w;
    	float factor = clamp(1.0-smoothstep(world_pos.z+proximity_fade_distance, world_pos.z, VERTEX.z), 0.0, 1.0);
		float depth = -world_pos.z+VERTEX.z;
		if((factor!=1.0))
		{
			float refra_amount = 1.0 - factor;
   			vec3 refractColor = textureLod(SCREEN_TEXTURE, SCREEN_UV+screen_offset*depth, ROUGHNESS*8.0).rgb* refra_amount;
			ALBEDO *= 1.0 - refra_amount;
    		EMISSION += refractColor;
		}
    	ALPHA = 1.0;
	
    //fake reflection
    //	if (reflection != 0.0)
    //    {
    //		vec3 reflec = texture(reflectionTexure, UV);
    //		baseColor = lerp (baseColor, reflec, saturate(refl2Refr * 2.0));
    //    }
	
	//fresnel
//	float Eta=0.6;
//	float FresnelPower=5.0;
//	float F=((1.0-Eta)*(1.0-Eta))/((1.0+Eta)*(1.0+Eta));
//	float Ratio = F + (1.0-F) * pow(1.0 - dot(normalize(VERTEX), NORMAL),FresnelPower);
//	vec3 Color = mix(refractColor, reflectColor, Ratio);

}

//wave4
uniform bool useWave4 = true;
uniform float gerstnerIntensity = 1;
uniform vec4 wave4Amplitude;
uniform vec4 wave4Frequency;
uniform vec4 wave4Steepness;
uniform vec4 wave4Speed;
uniform vec4 wave4DirectionAB;
uniform vec4 wave4DirectionCD;

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
    if (useWave4)
    {
        vec3 offs = GerstnerOffset4(VERTEX.xz, wave4Steepness, wave4Amplitude, wave4Frequency, wave4Speed, wave4DirectionAB, wave4DirectionCD);
        vec3 nrml = GerstnerNormal4(VERTEX.xz, wave4Amplitude, wave4Frequency, wave4Speed, wave4DirectionAB, wave4DirectionCD);
        VERTEX = VERTEX + offs;
        NORMAL = nrml;
    }
}
