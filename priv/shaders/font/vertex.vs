#version 410 core

layout(location = 0) in vec3 a_pos;     // Position: x, y, z
layout(location = 1) in vec2 a_uv;      // UV: u, v

uniform mat4 u_projection;              // 2D orthographic projection

out vec2 v_uv;

void main() {
    gl_Position = u_projection * vec4(a_pos, 1.0);
    v_uv = a_uv;
}