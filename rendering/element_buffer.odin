package rendering

import gl "vendor:OpenGL"

ElementBuffer :: struct {
    element_buffer_handle: u32
}

create_element_buffer :: proc() -> ElementBuffer {
    element_buffer: ElementBuffer

    gl.GenBuffers(1, &element_buffer.element_buffer_handle)

    return element_buffer

}

write_element_buffer :: proc(element_buffer: ^ElementBuffer, data_size: int, data_ptr: rawptr) {
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, element_buffer.element_buffer_handle)

    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, data_size, data_ptr, gl.STATIC_DRAW)
}

bind_element_buffer :: proc(element_buffer: ^ElementBuffer) {
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, element_buffer.element_buffer_handle)
}

delete_element_buffer :: proc(element_buffer: ^ElementBuffer) {
    gl.DeleteBuffers(1, &element_buffer.element_buffer_handle)
}

unbind_element_buffer :: proc() {
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
}