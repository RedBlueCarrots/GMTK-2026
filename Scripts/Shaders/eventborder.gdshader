shader_type canvas_item;

uniform sampler2D MASK;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 mask = texture(MASK, UV);
	if (mask == vec4(0., 0., 0., 1.)) {
		COLOR.a = 0.0;
	}
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
