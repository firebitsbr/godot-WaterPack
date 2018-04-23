    shader_type spatial;
	
    uniform float UV1_Scale = 10;
    uniform float UV2_Scale = 10;
	uniform vec2 velocity = vec2(0.01,0);
    uniform sampler2D normalMap1; 
    uniform sampler2D normalMap2; 
    uniform vec4 wterColor: hint_color;
    uniform float roughnessValue : hint_range(0, 1);
    uniform float metalnessValue : hint_range(0, 1);
//Reflective 
//Refractive

    void fragment()
	{
		vec2 uv = (UV + (sin(TIME * velocity))) * UV1_Scale; 
		vec2 uv2 = (UV +vec2(0.5,0.5)+ (sin(TIME * velocity))) * UV2_Scale; 
	    vec3 normalMap1Text = texture(normalMap1,uv).rgb ;  
	    vec3 normalMap2Text = texture(normalMap2,uv2 ).rgb ;  
	    vec3 normalBlend =  mix(normalMap1Text,normalMap2Text, sin(TIME)); 
	    vec3 normalOutput = clamp (normalBlend, 0.1, 1); 
	    ALBEDO = wterColor.rgb; 
		ALPHA = wterColor.a;
	    ROUGHNESS =roughnessValue; 
	    METALLIC = metalnessValue ; 
	    NORMALMAP = normalize( normalMap1Text);
    }