package voxel_engine

import "core:math/linalg/glsl"


Camera :: struct {
    yaw: f32,
    pitch: f32,
    pos: glsl.vec3
}

camera_move_forward :: proc(cam: ^Camera, delta: f32) {

    rad_yaw := glsl.radians(cam.yaw)
    rad_pitch := glsl.radians(cam.pitch)

    cam.pos.x = cam.pos.x + ((glsl.cos(rad_yaw) * glsl.cos(rad_pitch)) * delta)

    cam.pos.y = cam.pos.y + (glsl.sin(rad_pitch) * delta)

    cam.pos.z = cam.pos.z + ((glsl.sin(rad_yaw) * glsl.cos(rad_pitch)) * delta)

}

camera_get_view_matrix :: proc(cam: ^Camera) -> glsl.mat4 {

    centre: glsl.vec3

    rad_yaw := glsl.radians(cam.yaw)
    rad_pitch := glsl.radians(cam.pitch)

    centre.x = cam.pos.x + (glsl.cos(rad_yaw) * glsl.cos(rad_pitch))

    centre.y = cam.pos.y + glsl.sin(rad_pitch)

    centre.z = cam.pos.z + (glsl.sin(rad_yaw) * glsl.cos(rad_pitch))


    

    return glsl.mat4LookAt(cam.pos, centre, glsl.vec3{0.0, 1.0, 0.0})
}