#version 330 core

in vec2 outTexCoord;

out vec4 FragColor;

uniform sampler2DRect block_rex;

void main() {
    FragColor = texture(block_rex, outTexCoord);
}