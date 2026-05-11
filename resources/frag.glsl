#version 330 core

in vec2 outTexCoord;

out vec4 FragColor;

uniform sampler2D block_tex;

void main() {
    FragColor = texture(block_tex, outTexCoord);
}