package rendering

import gl "vendor:OpenGL"

VertexBuffer :: struct {
    vertex_buffer_handle: u32
}

create_vertex_buffer :: proc() -> VertexBuffer {
    vertex_buffer: VertexBuffer

    gl.GenBuffers(1, &vertex_buffer.vertex_buffer_handle)

    return vertex_buffer

}

write_vertex_buffer :: proc(vertex_buffer: ^VertexBuffer, data_size: int, data_ptr: rawptr) {
    gl.BindBuffer(gl.ARRAY_BUFFER, vertex_buffer.vertex_buffer_handle)

    gl.BufferData(gl.ARRAY_BUFFER, data_size, data_ptr, gl.STATIC_DRAW)
}

bind_vertex_buffer :: proc(vertex_buffer: ^VertexBuffer) {
    gl.BindBuffer(gl.ARRAY_BUFFER, vertex_buffer.vertex_buffer_handle)
}

delete_vertex_buffer :: proc(vertex_buffer: ^VertexBuffer) {
    gl.DeleteBuffers(1, &vertex_buffer.vertex_buffer_handle)
}

unbind_vertex_buffer :: proc() {
    gl.BindBuffer(gl.ARRAY_BUFFER, 0)
}