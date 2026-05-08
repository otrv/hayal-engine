@vs vs
layout(binding=0) uniform vs_params {
  vec4 rect; // x, y, w, h
  vec4 color;
};

in vec2 position;

out vec4 v_color;

void main() {
    gl_Position = vec4(position * rect.zw + rect.xy, 0.0, 1.0);
    v_color = color;
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
