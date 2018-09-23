shader_type spatial;
render_mode unshaded;

uniform sampler2D water_texture;
uniform sampler2D waves;

uniform float water_scale = 3.0;
uniform float wave_scale = 0.01;

uniform float speed = 0.1;

void vertex() {
    VERTEX.y += texture(waves, VERTEX.xz * wave_scale + vec2(TIME, 0.0)*speed).r;
    VERTEX.y += texture(waves, VERTEX.xz * wave_scale + vec2(-TIME / 2.0, TIME)*speed).r;
}

void fragment() {
	ALBEDO = texture(water_texture, UV*water_scale + vec2(sin(TIME)*0.1)).rgb;
}
