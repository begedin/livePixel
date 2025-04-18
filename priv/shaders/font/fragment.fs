#version 410 core

in vec2 v_uv;

uniform sampler2D u_font;    // Texture to sample from
uniform vec3 u_color;        // Font tint color (e.g., white, red, yellow)

out vec4 frag_color;

void main() {
    vec3 tex = texture(u_font, v_uv).rgb;
    float brightness = 1.0 - tex.r;     // Invert: white → black, black → white
    frag_color = vec4(u_color * brightness, brightness);
}