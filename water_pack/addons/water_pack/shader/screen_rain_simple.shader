shader_type canvas_item;
// FROM https://www.shadertoy.com/view/ldSfDW

// TODO
// default value after 3.1

uniform float rain_speed : hint_range(0, 10) ; // = 1;
uniform float rain_zoom: hint_range(0, 100) ; //= 40;
uniform float screen_blur : hint_range(0, 10) ; //= 2.5;
uniform sampler2D noise_texture;

void fragment()
{
	vec4 screen = textureLod(SCREEN_TEXTURE,SCREEN_UV,screen_blur);
    vec2 x = vec2(rain_zoom);
    vec4 n = texture(noise_texture, round(UV*x - .3) / x);
    vec2 z = UV*x * 6.3 + (texture(noise_texture,UV * 0.1).rg - 0.5)*2.0;
    x = sin(z) - fract(TIME*rain_speed * (n.b + 0.1) + n.g) * .5;
	if (x.x+x.y-n.r*3.0 > 0.5 )	
    	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV+cos(z)*0.2, screen_blur) ;
	else
		COLOR = screen;
}