shader_type canvas_item;

uniform sampler2D EUROPA : filter_nearest;
uniform sampler2D MASK : filter_nearest;
uniform sampler2D NOISE : filter_nearest;
uniform sampler2D STARS : filter_nearest;
uniform sampler2D LIGHTS : filter_nearest;
uniform sampler2D LIGHTING : filter_nearest;

uniform sampler2D ROCKET1 : filter_nearest;
uniform sampler2D ROCKET2 : filter_nearest;
uniform sampler2D ROCKET3 : filter_nearest;
uniform sampler2D ROCKET4 : filter_nearest;

uniform float windSpeed = 1;
uniform float rpm = 1;
uniform int rocketStage = 0;

uniform vec2 resolution = vec2(320, 180);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 iuv = (floor(UV * resolution) + 0.5) / resolution;
	//iuv = UV;
	
	vec2 atmosphereRelPos = iuv - vec2(0.5, 0.8);
	float atmosphereRadial = dot(atmosphereRelPos, atmosphereRelPos);
	float atmosphereIntensity = 0.9 - atmosphereRadial;
	
	vec4 europa = texture(EUROPA, iuv);
	vec4 mask = texture(MASK, iuv);
	vec4 noise = texture(NOISE, fract(iuv + vec2((TIME + sin(TIME + UV.x) / 2.) * windSpeed,  sin(TIME + UV.y) * windSpeed / 2.)));
	vec4 stars = texture(STARS, iuv);
	vec4 lights = texture(LIGHTS, iuv);
	vec4 lighting = texture(LIGHTING, iuv);
	
	vec4 rocket1 = texture(ROCKET1, iuv);
	vec4 rocket2 = texture(ROCKET2, iuv);
	vec4 rocket3 = texture(ROCKET3, iuv);
	vec4 rocket4 = texture(ROCKET4, iuv);
	
	float sunlight = cos(TIME * 2. * PI * rpm / 60. + iuv.x + 0.25);
	
	vec2 sunRelPos = iuv - vec2(tan(- TIME * PI * rpm / 60.), 0.4);
	float sunRadial = dot(sunRelPos, sunRelPos);
	float sunIntensity = 1. - sunRadial;
	
	vec4 rocketLayer = vec4(0);
	
	if (rocketStage == 1) {
		rocketLayer = rocket1;
	};
	if (rocketStage == 2) {
		rocketLayer = rocket2;
	};
	if (rocketStage == 3) {
		rocketLayer = rocket3;
	};
	if (rocketStage == 4) {
		rocketLayer = rocket4;
	};
	
	europa = europa * (1. - rocketLayer.w) + rocketLayer * rocketLayer.w;
	
	vec4 sunLayer = max(vec4(mask.x) * pow(sunIntensity, 10), vec4(0));
	vec4 europaLayer = (1. - mask.y) * max(europa * sunlight, (europa + lights) * (lighting * (1. - sunlight)));
	vec4 atmosphereLayer = max(mask.x * vec4(1, 0.4, 0.2, 1) * (noise * 0.25 + vec4(vec3(0.75), 1)) * pow(atmosphereIntensity, 4) * (1. + sunlight), vec4(0));
	vec4 starLayer = mask.y * stars * (1. - sunlight);
	
	COLOR = max((sunLayer + europaLayer + atmosphereLayer + starLayer), vec4(vec3(0), 1));
	//COLOR = max(europaLayer, vec4(vec3(0.), 1.));
	//europa.w = max(europa.w, 1.);
	//COLOR = europa;
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
}
