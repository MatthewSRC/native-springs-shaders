#version 300 es
precision highp float;

layout(location = 0) in vec2 position;
layout(location = 1) in vec2 texCoord;

out vec2 v_TexCoord;
out vec2 vTexCoord;

void main() {
    gl_Position = vec4(position, 0.0, 1.0);
    v_TexCoord = texCoord;
    vTexCoord = texCoord;
}
