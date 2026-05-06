package rendering

import "core:strings"
import "core:fmt"
import gl "vendor:OpenGL"

ShaderProgram :: struct {
    vertex_shader_handle: u32,
    fragment_shader_handle: u32,
    program_handle: u32
}

create_shader_program :: proc(vertex_shader_src: string, fragment_shader_source: string) -> ShaderProgram {
    shader_program := ShaderProgram{}

    shader_program.fragment_shader_handle = gl.CreateShader(gl.FRAGMENT_SHADER)
    shader_program.vertex_shader_handle = gl.CreateShader(gl.VERTEX_SHADER)

    vert_cstr := strings.clone_to_cstring(vertex_shader_src)
    frag_cstr := strings.clone_to_cstring(fragment_shader_source)

    vert_len: i32 = i32(len(vert_cstr))
    frag_len: i32 = i32(len(frag_cstr))

    defer delete(vert_cstr)
    defer delete(frag_cstr)
    

    gl.ShaderSource(shader_program.vertex_shader_handle, 1, &vert_cstr, &vert_len)
    gl.ShaderSource(shader_program.fragment_shader_handle, 1, &frag_cstr, &frag_len)

    vert_compile_status: i32
    frag_compile_status: i32

    gl.CompileShader(shader_program.vertex_shader_handle)


    gl.GetShaderiv(shader_program.vertex_shader_handle, gl.COMPILE_STATUS, &vert_compile_status)

    if vert_compile_status == 0 {

        vert_log_len: i32
        gl.GetShaderiv(shader_program.vertex_shader_handle, gl.INFO_LOG_LENGTH, &vert_log_len)

        vert_log_buf := make([]u8, vert_log_len)
        defer delete(vert_log_buf)

        gl.GetShaderInfoLog(shader_program.vertex_shader_handle, vert_log_len, nil,  &vert_log_buf[0])

        vert_log := transmute(string)vert_log_buf


        fmt.println("VERTEX SHADER COMPILE ERROR: ")
        fmt.println(vert_log)        
    }
    
    gl.CompileShader(shader_program.fragment_shader_handle)

    gl.GetShaderiv(shader_program.fragment_shader_handle, gl.COMPILE_STATUS, &frag_compile_status)

    if frag_compile_status == 0 {

        frag_log_len: i32
        gl.GetShaderiv(shader_program.fragment_shader_handle, gl.INFO_LOG_LENGTH, &frag_log_len)

        frag_log_buf := make([]u8, frag_log_len)
        defer delete(frag_log_buf)

        gl.GetShaderInfoLog(shader_program.fragment_shader_handle, frag_log_len, nil, &frag_log_buf[0])

        frag_log := transmute(string)frag_log_buf


        fmt.println("FRAGMENT SHADER COMPILE ERROR: ")
        fmt.println(frag_log)        
    }


    shader_program.program_handle = gl.CreateProgram()    
    
    gl.AttachShader(shader_program.program_handle, shader_program.vertex_shader_handle)
    gl.AttachShader(shader_program.program_handle, shader_program.fragment_shader_handle)

    gl.LinkProgram(shader_program.program_handle)

    program_link_status : i32

    gl.GetProgramiv(shader_program.program_handle, gl.LINK_STATUS, &program_link_status)

    
    if program_link_status == 0 {

        link_log_len: i32
        gl.GetProgramiv(shader_program.program_handle, gl.INFO_LOG_LENGTH, &link_log_len)

        link_log_buf := make([]u8, link_log_len)
        defer delete(link_log_buf)

        gl.GetProgramInfoLog(shader_program.program_handle, link_log_len, nil, &link_log_buf[0])

        link_log := transmute(string)link_log_buf


        fmt.println("SHADER PROGRAM LINK ERROR: ")
        fmt.println(link_log)        
    }


    gl.DeleteShader(shader_program.fragment_shader_handle)
    gl.DeleteShader(shader_program.vertex_shader_handle)

    return shader_program
}

use_shader_program :: proc(shader_program: ^ShaderProgram) {
    gl.UseProgram(shader_program.program_handle)
}

delete_shader_program :: proc(shader_program: ^ShaderProgram) {
    gl.DeleteProgram(shader_program.program_handle)
}
