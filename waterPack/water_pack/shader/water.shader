shader_type spatial;
//render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
// todo optimiz

uniform float TIME;
uniform vec4 water_color : hint_color = vec4(20, 30, 30, 230);
uniform float roughness : hint_range(0, 1) = 0.1;
uniform float metalness : hint_range(0, 1) = 0.6;
uniform float specular : hint_range(0, 1) = 0.1;

// normal map wave
uniform sampler2D normal_map1;
uniform float normal1_scale : hint_range(0, 1) = 1;
uniform vec2 normal1_velocity = vec2(0.01, 0);
uniform vec2 normal1_uv_scale = vec2(10, 10);

uniform sampler2D normal_map2;
uniform float normal2_scale : hint_range(0, 1) = 1;
uniform vec2 normal2_velocity = vec2(0.01, 0);
uniform vec2 normal2_uv_scale = vec2(10, 10);

uniform uint SIMPLE_FADE_MODE = 0;
uniform uint REFRACT_MODE = 1;
uniform uint transprant_mode = 1; //todo replace with enum alfter godot 3.1

uniform uint FAKE_REFRACT_OFFSET_DEPTH = 0;
uniform uint FAKE_REFRACT_LINE_DEPTH = 1;
uniform uint refract_method = 1; //todo replace with enum alfter godot 3.1

uniform sampler2D reflect_texture : hint_black;

uniform float refraction : hint_range(0, 10) = .1;
uniform float fade_distance = 1;
uniform sampler2D foam_texture : hint_white;
uniform vec4 foam_color : hint_color;

void fragment()
{
    ROUGHNESS = roughness;
    METALLIC = metalness;
    SPECULAR = specular;
    //	RIM = 0.1;
    //	RIM_TINT = 0.7;
    // normal wave
    vec3 normal1 = vec3(1, 1, 1);
    vec3 normal2 = vec3(1, 1, 1);
    if (normal1_scale != 0.0)
    {
        vec2 uv1 = mod(normal1_uv_scale * UV + TIME * normal1_velocity, 1);
        normal1 = texture(normal_map1, uv1).rgb;
    }
    if (normal2_scale != 0.0)
    {
        vec2 uv2 = mod(normal2_uv_scale * UV + TIME * normal2_velocity, 1);
        normal2 = texture(normal_map2, uv2).rgb;
    }
    //MIX NORMAL
    vec3 n1 = normal1 * 2.0 - 1.0;
    vec3 n2 = normal2 * 2.0 - 1.0;
    vec3 normal = normalize(vec3(n1.xy * normal1_scale + n2.xy * normal2_scale, n1.z * n2.z));
    NORMAL = normalize(normal * 0.5 + 0.5);

    ALBEDO = water_color.rgb;

    vec3 refract_color = vec3(0, 0, 0);
    if (transprant_mode == SIMPLE_FADE_MODE)
    {
        float depth_tex = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
        vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth_tex * 2.0 - 1.0, 1.0);
        world_pos.xyz /= world_pos.w;
        ALPHA *= clamp(1.0 - smoothstep(world_pos.z + fade_distance, world_pos.z, VERTEX.z), 0.0, 1.0);
    }
    else if (transprant_mode == REFRACT_MODE)
    {
        // fake refraction
        if (refract_method == FAKE_REFRACT_OFFSET_DEPTH)
        {
            //refraction with depth = offset depth
            //	 	vec3 refra_normal = normalize( mix(NORMAL,TANGENT * NORMALMAP.x + BINORMAL * NORMALMAP.y + NORMAL * NORMALMAP.z,NORMALMAP_DEPTH) );
            //		vec2 screen_offset = refra_normal.xy * refraction/VERTEX.z;
            vec2 screen_offset = NORMAL.xy * refraction / VERTEX.z;
            float depth_tex = textureLod(DEPTH_TEXTURE, SCREEN_UV + screen_offset, 0.0).r;
            vec4 world_pos = INV_PROJECTION_MATRIX * vec4((SCREEN_UV + screen_offset) * 2.0 - 1.0, depth_tex * 2.0 - 1.0, 1.0);
            world_pos.xyz /= world_pos.w;
            float depth = distance(VERTEX.xyz, world_pos.xyz);
            if ((depth < fade_distance))
            {
                float factor = clamp(1.0 - depth / fade_distance, 0.0, 1.0);
                //fix edge
                float line_depth_tex = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
                vec4 line_world_pos = INV_PROJECTION_MATRIX * vec4((SCREEN_UV)*2.0 - 1.0, line_depth_tex * 2.0 - 1.0, 1.0);
                line_world_pos.xyz /= line_world_pos.w;
                //			float linedepth=VERTEX.z-line_world_pos.z;
                float linedepth = distance(VERTEX.xyz, line_world_pos.xyz);
                if (!((depth < 0.0) && (linedepth > fade_distance)))
                {
                    refract_color = textureLod(SCREEN_TEXTURE, SCREEN_UV + screen_offset * depth, ROUGHNESS * 8.0).rgb * factor;
                    EMISSION = refract_color;
                }
            }
        }
        else if (refract_method == FAKE_REFRACT_LINE_DEPTH)
        {
            //refraction with depth = line depth
            float depth_tex = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
            vec4 world_pos = INV_PROJECTION_MATRIX * vec4((SCREEN_UV)*2.0 - 1.0, depth_tex * 2.0 - 1.0, 1.0);
            world_pos.xyz /= world_pos.w;
            float depth = distance(VERTEX.xyz, world_pos.xyz);
            //		float depth=VERTEX.z-world_pos.z;
            if ((depth < fade_distance))
            {
                //		vec3 refra_normal = normalize( mix(NORMAL,TANGENT * NORMALMAP.x + BINORMAL * NORMALMAP.y + NORMAL * NORMALMAP.z,NORMALMAP_DEPTH) );
                //		vec2 screen_offset = refra_normal.xy * refraction/VERTEX.z* depth;
                vec2 screen_offset = NORMAL.xy * refraction / VERTEX.z * depth;
                float factor = clamp(1.0 - depth / fade_distance, 0.0, 1.0);
                refract_color = textureLod(SCREEN_TEXTURE, SCREEN_UV + screen_offset, ROUGHNESS * 8.0).rgb * factor;
                //fix edge
                float real_depth_tex = textureLod(DEPTH_TEXTURE, SCREEN_UV + screen_offset, 0.0).r;
                vec4 real_world_pos = INV_PROJECTION_MATRIX * vec4((SCREEN_UV + screen_offset) * 2.0 - 1.0, real_depth_tex * 2.0 - 1.0, 1.0);
                real_world_pos.xyz /= real_world_pos.w;
                float realDepth = distance(VERTEX.xyz, real_world_pos.xyz);
                //		float realDepth=VERTEX.z-real_world_pos.z;
                if (realDepth > fade_distance)
                {
                    refract_color = vec3(0, 0, 0);
                }
            }
        }
        ALPHA = 1.0;
    }
    else
    {
        ALPHA = water_color.a;
    }
    float refl_distort = 0.1;
    //fake reflection
    vec3 reflect_color = textureLod(reflect_texture, SCREEN_UV + NORMAL.xy * refl_distort / VERTEX.z, ROUGHNESS * 8.0).rgb * 0.7;

    //fresnel
    float eta = 0.6;
    float fresnel_power = 3.0;
    float F = ((1.0 - eta) * (1.0 - eta)) / ((1.0 + eta) * (1.0 + eta));
    float ratio = F + (1.0 - F) * pow(1.0 - dot(normalize(-VERTEX), NORMAL), fresnel_power);
    EMISSION = mix(refract_color, reflect_color, ratio);
}

//Gerstner wave4
uniform bool gerstner_wave4_enable = true;
uniform float gerstner_factor = 1;
uniform vec4 wave4_amplitude;
uniform vec4 wave4_frequency;
uniform vec4 wave4_steepness;
uniform vec4 wave4_speed;
uniform vec4 wave4_direction12;
uniform vec4 wave4_direction34;

vec3 gerstner_offset(vec2 xzVtx, float steepness, float amp, float freq, float speed, vec2 dir)
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
vec3 gerstner_offset4(vec2 xzVtx, vec4 steepness, vec4 amp, vec4 freq, vec4 speed, vec4 dirAB, vec4 dirCD)
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
vec3 gerstner_normal(vec2 xzVtx, float amp, float freq, float speed, vec2 dir)
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

vec3 gerstner_normal4(vec2 xzVtx, vec4 amp, vec4 freq, vec4 speed, vec4 dirAB, vec4 dirCD)
{
    vec3 nrml = vec3(0, 2.0, 0);

    vec4 AB = freq.xxyy * amp.xxyy * dirAB.xyzw;
    vec4 CD = freq.zzww * amp.zzww * dirCD.xyzw;

    vec4 dotABCD = freq.xyzw * vec4(dot(dirAB.xy, xzVtx), dot(dirAB.zw, xzVtx), dot(dirCD.xy, xzVtx), dot(dirCD.zw, xzVtx));

    vec4 COS = cos(dotABCD + TIME * speed);

    nrml.x -= dot(COS, vec4(AB.xz, CD.xz));
    nrml.z -= dot(COS, vec4(AB.yw, CD.yw));

    nrml.xz *= gerstner_factor;
    nrml = normalize(nrml);

    return nrml;
}

void vertex()
{
    if (gerstner_wave4_enable)
    {
        vec3 offs = gerstner_offset4(VERTEX.xz, wave4_steepness, wave4_amplitude, wave4_frequency, wave4_speed, wave4_direction12, wave4_direction34);
        vec3 nrml = gerstner_normal4(VERTEX.xz, wave4_amplitude, wave4_frequency, wave4_speed, wave4_direction12, wave4_direction34);
        VERTEX = VERTEX + offs;
        NORMAL = nrml;
    }
}
