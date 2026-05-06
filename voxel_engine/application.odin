package voxel_engine

import "core:fmt"
import "vendor:glfw"
import gl "vendor:OpenGL"

Application :: struct {
    glfw_window: glfw.WindowHandle

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

    return app
}

run_game :: proc(app: ^Application) {

    

    for !glfw.WindowShouldClose(app.glfw_window) {
        glfw.PollEvents()
        glfw.SwapBuffers(app.glfw_window)
    }   
}

cleanup_game :: proc(app: ^Application) {
    glfw.Terminate()
}