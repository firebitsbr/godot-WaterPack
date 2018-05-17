    shader_type spatial;
	
	uniform vec2 velocity = vec2(0.01,0);
    uniform vec4 waterColor: hint_color=vec4(40,80,60,190);
    uniform float roughness : hint_range(0, 1)=0.1;
    uniform float metalness : hint_range(0, 1)=0.6;
    uniform float specular : hint_range(0, 1)=0.1;
    uniform sampler2D normalMap; 
    uniform vec2 norMapScale = vec2(10,10);
    uniform float refraction = 10;
	uniform float waveScale :hint_range(0, 1)=1;

    void fragment()
	{
		vec2 uv=mod(norMapScale*UV+TIME*velocity,1);
	    vec3 normal1 = texture(normalMap,uv).rgb ;  
		vec2 uv2=mod(norMapScale*UV-TIME*velocity,1);
		vec3 normal2 = texture(normalMap,uv2).rgb ;  
		vec3 normal3 = mix(normal1,normal2,0.5) ;  
		vec3 normal = mix(vec3(1,1,1),normal3,waveScale) ;  
	    ALBEDO = waterColor.rgb; 
		ALPHA = waterColor.a;
	    ROUGHNESS =roughness; 
	    METALLIC = metalness; 
		SPECULAR = specular;
	    NORMALMAP = normalize( normal);
    }