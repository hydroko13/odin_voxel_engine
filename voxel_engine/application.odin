package voxel_engine

import "core:fmt"
import "core:path/filepath"
import "core:os"
import "vendor:glfw"
import "../rendering"

import gl "vendor:OpenGL"

Application :: struct {
    glfw_window: glfw.WindowHandle,
    shader_program: rendering.ShaderProgram

}

init_game :: proc() -> Application {
    app := Application{}


    glfw.Init()

    glfw.WindowHint(glfw.RESIZABLE, 0)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    app.glfw_window = glfw.CreateWindow(1280, 720, "Odin Voxel Engine", nil, nil)

    


    glfw.MakeContextCurrent(app.glfw_window)

    gl.load_up_to(3, 3, glfw.gl_set_proc_address)

    full_frag_path, frag_path_err := filepath.join({"resources", "frag.glsl"}, context.allocator)
    full_vert_path, vert_path_err := filepath.join({"resources", "vert.glsl"}, context.allocator)


    frag_dat, frag_err := os.read_entire_file(full_frag_path, context.allocator)
    vert_dat, vert_err := os.read_entire_file(full_vert_path, context.allocator)

    defer delete(frag_dat)
    defer delete(vert_dat)

    app.shader_program = rendering.create_shader_program(transmute(string)vert_dat, transmute(string)frag_dat)

    rendering.use_shader_program(&app.shader_program)

    return app
}

run_game :: proc(app: ^Application) {

    gl.ClearColor(0.363, 0.837, 0.861, 1.0)

    for !glfw.WindowShouldClose(app.glfw_window) {
        

        

        gl.Clear(gl.COLOR_BUFFER_BIT)
        

        
        glfw.SwapBuffers(app.glfw_window)

        glfw.PollEvents()
    }   
}

cleanup_game :: proc(app: ^Application) {

    rendering.delete_shader_program(&app.shader_program)

    glfw.DestroyWindow(app.glfw_window)
    glfw.Terminate()

}