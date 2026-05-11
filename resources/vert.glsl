#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aUv;

out vec2 outTexCoord;

uniform mat4 proj;
uniform mat4 view;
uniform mat4 model;

void main() {
    outTexCoord = aUv;
    gl_Position = proj * view * model * vec4(aPos, 1.0);
}