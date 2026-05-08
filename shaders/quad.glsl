@vs vs
layout(binding=0) uniform vs_globals { mat4 view_projection; };

in vec2 position;
in vec4 color0;

out vec4 v_color;

void main() {
    gl_Position = view_projection * vec4(position, 0.0, 1.0);
    v_color = color0;
}
@end

@fs fs
in vec4 v_color;
out vec4 frag_color;

void main() {
    frag_color = v_color;
}
@end

@program quad vs fs
