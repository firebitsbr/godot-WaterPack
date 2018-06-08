shader_type spatial;
render_mode world_vertex_coords;

uniform sampler2D wet_map;
uniform float wet_map_strength = 1.0;
uniform float wet_map_bias = 0.0;
uniform bool invert_wet_map = true;
uniform vec2 wet_dirt_size = vec2(30,30);

uniform sampler2D texture_normal : hint_normal;

uniform vec2 translation;

void vertex() {
	UV2 = (VERTEX.xz-translation) / wet_dirt_size + 0.5;
	UV2 = 1.0 - UV2;
}

void fragment() {
	ALBEDO = COLOR.rgb;
	
	float wetness = invert_wet_map ? 1.0-texture(wet_map, UV2).r : texture(wet_map, UV2).r;
	wetness = wet_map_strength * (wetness - wet_map_bias);
	wetness = clamp(wetness, 0.0, 1.0);
	ALPHA = COLOR.a * pow(wetness, 2.0);
	
	METALLIC = 1.0;
	ROUGHNESS = 0.0;
	NORMALMAP = texture(texture_normal,UV).rgb;
	
	ALPHA *= distance(NORMALMAP.rg, vec2(0.5)) * 2.0;
}
