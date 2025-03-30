shader_type canvas_item;

uniform int texture_width = 64;
uniform int texture_height = 32;
uniform float circle_radius = 1.0;
uniform float circle_shape = 0.0;

void fragment() {
	vec2 pixel_pos = UV * vec2(float(texture_width), float(texture_height));
	ivec2 pixel_coords = ivec2(pixel_pos);
	vec2 center = vec2(pixel_coords) + vec2(0.5);
	vec2 offset = abs(pixel_pos - center) / (0.5 * circle_radius);

	float shape_blend = mix(
		pow(offset.x, 2.0) + pow(offset.y, 2.0),
		max(offset.x, offset.y),
		clamp(circle_shape, 0.0, 1.0)
	);

	// Keep color, modify alpha
	COLOR.a *= shape_blend > 1.0 ? 1.0 : 0.0;
}
