    shader_type spatial;
    //render_mode world_vertex_coords;
    uniform vec4 color : hint_color;
    uniform int numWaves;
    uniform float waterHeight;
    uniform float wavelength = 8.0;
    uniform float amplitude = 8.0;
    uniform float speed = 8.0;
    uniform vec2 direction = vec2(8.0, 8.0);
    uniform float pi = 3.1415926535897932384626433832795;
    varying vec3 position;
    varying vec3 worldNormal;
    varying vec3 eyeNormal;
    uniform vec3 eyePos;
    float wave(int i, float x, float y, float t) {
        float frequency = 2.0 * pi / wavelength;
        float phase = speed * frequency;
        float theta = dot(direction, vec2(x, y));
        return amplitude * sin(theta * frequency + t * phase);
    }
    float waveHeight(float x, float y, float t) {
        float height = 0.0;
        for (int i = 0; i < numWaves; i++) {
            height += wave(i, x, y, t);
        }
        return height;
    }
    float dWaveDx(int i, float x, float y, float t) {
        float frequency = 2.0 * pi / wavelength;
        float phase = speed * frequency;
        float theta = dot(direction, vec2(x, y));
        float A = amplitude * direction.x * frequency;
        return A * cos(theta * frequency + t * phase);
    }
    float dWaveDy(int i, float x, float y, float t) {
        float frequency = 2.0 * pi / wavelength;
        float phase = speed * frequency;
        float theta = dot(direction, vec2(x, y));
        float A = amplitude * direction.y * frequency;
        return A * cos(theta * frequency + t * phase);
    }
    vec3 waveNormal(float x, float y, float t) {
        float dx;
        float dy;
        for (int i; i < numWaves; i++) {
            dx += dWaveDx(i, x, y, t);
            dy += dWaveDy(i, x, y, t);
        }
        vec3 n = vec3(-dx, -dy, 1.0);
        return n;
    }
    void vertex() {
        vec4 pos = vec4(VERTEX, 1.0).xzyw;
        pos.z = (waterHeight + waveHeight(pos.x, pos.y, TIME));
        position = pos.xzy / pos.w;
        worldNormal = waveNormal(pos.x, pos.y, TIME);
        eyeNormal = (MODELVIEW_MATRIX * vec4(worldNormal, 0.0).xzyw).xyz;
        NORMAL = eyeNormal;
        TANGENT = eyeNormal;
        BINORMAL = eyeNormal;
        VERTEX = (position).xyz;
    }
    void fragment() {
        SPECULAR = float(1.0);
        ROUGHNESS = float(0.05);
    //  CLEARCOAT = float(0.99);
    //  CLEARCOAT_GLOSS = float(1.0);
        ALBEDO = color.rgb;
        ALPHA = color.a;
    }