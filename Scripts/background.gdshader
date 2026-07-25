shader_type canvas_item;

uniform sampler2D EUROPA;
uniform sampler2D MASK;
uniform sampler2D NOISE;
uniform sampler2D STARS;
uniform sampler2D LIGHTS;
uniform sampler2D UI;

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
    vec4 stars = texture(STARS, iuv);
    vec4 lights = texture(LIGHTS, iuv);
    vec4 ui = texture(UI, iuv);
    
    ui = vec4(0.);
    lights = vec4(0.);
    
    float sunlight = cos(TIME * 2. * PI * rpm / 60. + iuv.x + 0.25);
    
    vec2 sunRelPos = iuv - vec2(tan(- TIME * PI * rpm / 60.), 0.4);
    float sunRadial = dot(sunRelPos, sunRelPos);
    float sunIntensity = 1. - sunRadial;
    
    vec4 sunLayer = max(vec4(mask.x) * pow(sunIntensity, 10), vec4(0));
    vec4 europaLayer = (1. - mask.y) * max(europa * sunlight, europa * (lights * (1. - sunlight)));
    vec4 atmosphereLayer = max(mask.x * vec4(1, 0.4, 0.2, 1) * (noise * 0.25 + vec4(vec3(0.75), 1)) * pow(atmosphereIntensity, 4) * (1. + sunlight), vec4(0));
    vec4 starLayer = mask.y * stars * (1. - sunlight);
    
    COLOR = max((sunLayer + europaLayer + atmosphereLayer + starLayer) * (1. - ui.w) + ui, vec4(vec3(0), 1));
    //COLOR = max(europaLayer, vec4(vec3(0.), 1.));
    //europa.w = max(europa.w, 1.);
    //COLOR = europa;
}

void light() {
    // Called for every pixel for every light affecting the CanvasItem.
    // Uncomment to replace the default light processing function with this one.
}