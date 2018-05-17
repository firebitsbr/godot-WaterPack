shader_type canvas_item;
//FROM https://www.shadertoy.com/view/ldSfDW

uniform float speed : hint_range(0, 10) = 1;
uniform float scale: hint_range(0, 100) = 40;
uniform float blur : hint_range(0, 10) = 2.5;
uniform sampler2D noiseTexture;

void fragment()
{
	vec4 screen = textureLod(SCREEN_TEXTURE,SCREEN_UV,blur);
    vec2 x = vec2(scale);
    vec4 n = texture(noiseTexture, round(UV*x - .3) / x);
    vec2 z = UV*x * 6.3 + (texture(noiseTexture,UV * 0.1).rg - 0.5)*2.0;
    x = sin(z) - fract(TIME*speed * (n.b + 0.1) + n.g) * .5;
	if (x.x+x.y-n.r*3.0 > 0.5 )	
    	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV+cos(z)*0.2, blur) ;
	else
		COLOR = screen;
}