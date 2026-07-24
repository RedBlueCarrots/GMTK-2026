shader_type canvas_item;

uniform sampler2D EUROPA;
uniform sampler2D MASK;
uniform sampler2D NOISE;
uniform sampler2D NIGHT;

uniform float windSpeed = 1;
uniform float rpm = 1;

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
    
    vec2 atmosphereRelPos = iuv - vec2(0.5, 0.8);
    float atmosphereRadial = dot(atmosphereRelPos, atmosphereRelPos);
    float atmosphereIntensity = 0.9 - atmosphereRadial;
    
    vec4 europa = texture(EUROPA, iuv);
    vec4 mask = texture(MASK, iuv);
    vec4 noise = texture(NOISE, fract(iuv + vec2((TIME + sin(TIME + UV.x) / 2.) * windSpeed,  sin(TIME + UV.y) * windSpeed / 2.)));
    vec4 night = texture(NIGHT, iuv);
    
    float sunlight = cos(TIME * 2. * PI * rpm / 60. + iuv.x);
    
    vec4 lights = vec4(0.);
    
    vec2 sunRelPos = iuv - vec2(tan(- TIME * PI * rpm / 60.), 0.4);
    float sunRadial = dot(sunRelPos, sunRelPos);
    float sunIntensity = 1. - sunRadial;
    
    vec4 sunLayer = max(mask * pow(sunIntensity, 10), vec4(vec3(0),1));
    vec4 europaLayer = europa * (sunlight + (1. - sunlight) * lights);
    vec4 atmosphereLayer = mask * vec4(1, 0.4, 0.2, 1) * (noise * 0.25 + vec4(vec3(0.75), 1)) * pow(atmosphereIntensity, 4) * (1. + sunlight);
    vec4 nightLayer = mask * night * (1. - sunlight);
    
    COLOR = vec4(vec3(0), 1000) + sunLayer + europaLayer + atmosphereLayer + nightLayer;
}

void light() {
    // Called for every pixel for every light affecting the CanvasItem.
    // Uncomment to replace the default light processing function with this one.
}