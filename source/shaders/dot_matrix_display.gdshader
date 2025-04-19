shader_type canvas_item;

uniform int texture_width = 128;
uniform int texture_height = 64;
uniform float circle_radius : hint_range(0.0, 2.0, 0.0625) = 0.5;
uniform float circle_shape : hint_range(0.0, 1.0, 0.0625) = 0.5;

uniform vec4 color_on : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color_off : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float color_strength : hint_range(1.0, 3.0, 0.0625) = 1.0;

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

	COLOR = mix(color_off, color_on * color_strength, dot(texture(TEXTURE, UV).rgb, vec3(0.2126, 0.7152, 0.0722)));
	COLOR.a *= shape_blend < 1.0 ? 1.0 : 0.0;
}
