shader_type canvas_item;

uniform float outline_size = 0.01;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (COLOR.a == 0.0) {
		float outline_score = (
			texture(TEXTURE, UV + vec2(outline_size, 0.0)).a
			+ texture(TEXTURE, UV + vec2(-outline_size, 0.0)).a
			+ texture(TEXTURE, UV + vec2(0.0, outline_size)).a
			+ texture(TEXTURE, UV + vec2(0.0, -outline_size)).a
		);
		
		if (outline_score > 0.0) {
			COLOR = vec4(1.0, 1.0, 1.0, 1.0);
		}
	}
}
