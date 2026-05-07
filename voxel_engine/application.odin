package voxel_engine

import "core:fmt"
import "core:path/filepath"
import "core:os"
import "core:math/linalg/glsl"
import "vendor:glfw"
import "../rendering"

import gl "vendor:OpenGL"

Application :: struct {
    glfw_window: glfw.WindowHandle,
    shader_program: rendering.ShaderProgram,
    camera: Camera,
    projection: glsl.mat4,
    chunk: Chunk
}

init_game :: proc() -> Application {
    app := Application{}


    glfw.Init()

    glfw.WindowHint(glfw.RESIZABLE, 0)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    app.glfw_window = glfw.CreateWindow(1280, 720, "Odin Voxel Engine", nil, nil)

    
    glfw.SetInputMode(app.glfw_window, glfw.CURSOR, glfw.CURSOR_DISABLED)

    glfw.MakeContextCurrent(app.glfw_window)

    gl.load_up_to(3, 3, glfw.gl_set_proc_address)

    gl.Viewport(0, 0, 1280, 720)

    full_frag_path, frag_path_err := filepath.join({"resources", "frag.glsl"}, context.allocator)
    full_vert_path, vert_path_err := filepath.join({"resources", "vert.glsl"}, context.allocator)


    frag_dat, frag_err := os.read_entire_file(full_frag_path, context.allocator)
    vert_dat, vert_err := os.read_entire_file(full_vert_path, context.allocator)

    defer delete(frag_dat)
    defer delete(vert_dat)

    vertices := [?]f32{
        -0.5, -0.5, 0.0,   1.0, 0.0, 0.0,
        -0.5, 0.5, 0.0,   1.0, 1.0, 0.0,
        0.5, -0.5, 0.0,   0.0, 1.0, 0.0,
        0.5, 0.5, 0.0,   1.0, 1.0, 0.0,
    }

    indices := [?]u32{
        2, 0, 1,
        2, 3, 1
    }

    app.shader_program = rendering.create_shader_program(transmute(string)vert_dat, transmute(string)frag_dat)

    rendering.use_shader_program(&app.shader_program)

    gl.Enable(gl.DEPTH_TEST)
    gl.Enable(gl.CULL_FACE)

    // app.vao = rendering.create_vertex_array()

    

    // app.vbo = rendering.create_vertex_buffer()
    // app.ebo = rendering.create_element_buffer()

    // rendering.bind_vertex_array(&app.vao)
    
    // rendering.write_vertex_buffer(&app.vbo, len(vertices) * size_of(f32), &vertices[0])
    // rendering.write_element_buffer(&app.ebo, len(indices) * size_of(u32), &indices[0])

    // rendering.vertex_array_attrib(&app.vao, 0, gl.FLOAT, 3, size_of(f32) * 6, 0)
    // rendering.vertex_array_attrib(&app.vao, 1, gl.FLOAT, 3, size_of(f32) * 6, 3 * size_of(f32))

    // rendering.unbind_vertex_buffer()

    // rendering.unbind_vertex_array()

    app.camera = Camera{90.0, 0.0, glsl.vec3{0.0, 0.0, -3.0}}
    
    app.projection = glsl.mat4Perspective(glsl.radians(f32(45.0)), 1280.0 / 720.0, 0.01, 1000.0)
 
    app.chunk = create_chunk(0, 0)

    generate_chunk(&app.chunk)
    init_chunk(&app.chunk)

    update_chunk(&app.chunk)

    upload_chunk(&app.chunk)

    return app
}

run_game :: proc(app: ^Application) {

    gl.ClearColor(0.363, 0.837, 0.861, 1.0)

    viewLoc := gl.GetUniformLocation(app.shader_program.program_handle, "view")
    projLoc := gl.GetUniformLocation(app.shader_program.program_handle, "proj")

    lastMouseX, lastMouseY := glfw.GetCursorPos(app.glfw_window)
    lastTime := glfw.GetTime()

    for !glfw.WindowShouldClose(app.glfw_window) { 

        time := glfw.GetTime()
        deltaTime := f32(time - lastTime)
        lastTime = time
        
        if glfw.GetKey(app.glfw_window, glfw.KEY_ESCAPE) == 1 {
            glfw.SetWindowShouldClose(app.glfw_window, true)
        }

        if glfw.GetKey(app.glfw_window, glfw.KEY_W) == 1 {
            camera_move_forward(&app.camera, deltaTime * 45)
        }

        if glfw.GetKey(app.glfw_window, glfw.KEY_S) == 1 {
            camera_move_forward(&app.camera, deltaTime * -45)
        }



        mouseX, mouseY := glfw.GetCursorPos(app.glfw_window)

        relX, relY := f32(mouseX - lastMouseX), f32(mouseY - lastMouseY)

        lastMouseX = mouseX
        lastMouseY = mouseY

        app.camera.yaw += relX * deltaTime * 19
        app.camera.pitch -= relY * deltaTime * 19    

        app.camera.pitch = glsl.clamp(app.camera.pitch, -89, 89)

        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
        
        rendering.use_shader_program(&app.shader_program)

        viewMat := camera_get_view_matrix(&app.camera)

        gl.UniformMatrix4fv(viewLoc, 1, gl.FALSE, raw_data(&viewMat))

        gl.UniformMatrix4fv(projLoc, 1, gl.FALSE, raw_data(&app.projection))

        draw_chunk(&app.chunk, &app.shader_program)


        
        glfw.SwapBuffers(app.glfw_window)

        glfw.PollEvents()
    }   
}

cleanup_game :: proc(app: ^Application) {

    destroy_chunk(&app.chunk)
    
    rendering.delete_shader_program(&app.shader_program)


    glfw.DestroyWindow(app.glfw_window)
    glfw.Terminate()

}