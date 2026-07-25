shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if ((UV.x-0.5)*(UV.x-0.5)+(UV.y-0.5)*(UV.y-0.5) > 0.2 ){
		COLOR.a = 0.0;
	} else if (COLOR.a == 0.0){
		COLOR = vec4(0.0, 0.0, 0.0, 0.5);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
