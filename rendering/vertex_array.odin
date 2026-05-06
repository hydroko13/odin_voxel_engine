package rendering

import gl "vendor:OpenGL"

VertexArray :: struct {
    vertex_array_handle: u32
}

create_vertex_array :: proc() -> VertexArray {
    vertex_array: VertexArray

    gl.GenVertexArrays(1, &vertex_array.vertex_array_handle)


    return vertex_array
}



bind_vertex_array :: proc(vertex_array: ^VertexArray) {
    gl.BindVertexArray(vertex_array.vertex_array_handle)
}



delete_vertex_array :: proc(vertex_array: ^VertexArray) {
    gl.DeleteVertexArrays(1, &vertex_array.vertex_array_handle)
}
