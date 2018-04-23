    shader_type spatial;
	
	uniform vec2 velocity = vec2(0.01,0);
    uniform vec4 waterColor: hint_color;
    uniform float roughness : hint_range(0, 1);
    uniform float metalness : hint_range(0, 1);
    uniform float specular : hint_range(0, 1);
    uniform sampler2D normalMap; 
    uniform vec2 norMapScale = vec2(10,10);
    uniform float refraction = 10;
	
	
	//Reflective 

    void fragment()
	{
		vec2 uv=mod(norMapScale*UV+TIME*velocity,1);
	    vec3 normal = texture(normalMap,uv).rgb ;  
	    vec3 normalBlend =  mix(normal, normal,0.5); 
	    ALBEDO = waterColor.rgb; 
		ALPHA = waterColor.a;
	    ROUGHNESS =roughness; 
	    METALLIC = metalness; 
		SPECULAR = specular;
	    NORMALMAP = normalize( normal);
    }