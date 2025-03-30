shader_type canvas_item;

uniform float threshold = 0.5;

uniform vec4 color_on : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color_off : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	// Convert to lightness using luminance (perceived brightness)
	float brightness = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));

	COLOR = brightness >= threshold ? color_on : color_off;
}
