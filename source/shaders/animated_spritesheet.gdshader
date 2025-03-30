shader_type canvas_item;

uniform int frame_columns = 8;
uniform int frame_rows = 8;
uniform float fps = 8.0;

void fragment() {
    int total_frames = frame_columns * frame_rows;
    float time = TIME;
    int current_frame = int(mod(time * fps, float(total_frames)));

    int x_frame = current_frame % frame_columns;
    int y_frame = current_frame / frame_columns;

    vec2 frame_size = vec2(1.0 / float(frame_columns), 1.0 / float(frame_rows));
    vec2 uv_offset = vec2(float(x_frame), float(y_frame)) * frame_size;

    vec2 new_uv = UV * frame_size + uv_offset;
    COLOR = texture(TEXTURE, new_uv);
}
