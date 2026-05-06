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

vertex_array_attrib :: proc(vertex_array: ^VertexArray, location: u32, attribute_type: u32, attribute_value_count: i32, stride: i32, offset: i32) {
    bind_vertex_array(vertex_array)

    gl.VertexAttribPointer(location, attribute_value_count, attribute_type, gl.FALSE, stride, uintptr(offset))
    gl.EnableVertexAttribArray(location)

}

delete_vertex_array :: proc(vertex_array: ^VertexArray) {
    gl.DeleteVertexArrays(1, &vertex_array.vertex_array_handle)
}

unbind_vertex_array :: proc() {
    gl.BindVertexArray(0)
}