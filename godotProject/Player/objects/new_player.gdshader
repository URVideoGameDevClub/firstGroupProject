shader_type canvas_item;

const vec3 DAMAGE_COLOR = vec3(244.0, 216.0, 249.0);

uniform bool is_damage_state;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (is_damage_state) {
		COLOR = vec4(DAMAGE_COLOR, COLOR.a);
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
