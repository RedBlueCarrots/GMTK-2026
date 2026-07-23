shader_type canvas_item;
uniform vec2 GDT_MOUSE_POS;

uniform sampler2D EUROPA;
uniform sampler2D MASK;
uniform sampler2D NOISE;
uniform sampler2D STARS;

uniform float windSpeed = 1;

uniform vec2 resolution = vec2(320, 180);

void vertex() {
    // Called for every vertex the material is visible on.
}

vec2 int2(vec2 xy) {
    xy.x = round(xy.x);
    xy.y = round(xy.y);
    return xy;
}

void fragment() {
    vec2 iuv = int2(UV * resolution) / resolution;
    
    vec2 ab = iuv - vec2(0.5, 0.8);
    float radial = dot(ab, ab);
    float intensity = 0.9 - radial;
    
    vec4 europa = texture(EUROPA, iuv);
    vec4 mask = texture(MASK, iuv);
    vec4 noise = texture(NOISE, fract(iuv + vec2((TIME + sin(TIME + UV.x) / 2.) * windSpeed,  sin(TIME + UV.y) * windSpeed / 2.)));
    vec4 stars = texture(STARS, iuv);
    COLOR = europa + mask * vec4(1, 0, 0, 1) * (noise * 0.5 + vec4(vec3(0.5), 1)) * pow(intensity, 2 );
}

void light() {
    // Called for every pixel for every light affecting the CanvasItem.
    // Uncomment to replace the default light processing function with this one.
}