package voxel_engine

import "../rendering"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"


ChunkData :: struct {
	block_data: [16][16][256]u16,
}

Chunk :: struct {
	chunk_x:        i32,
	chunk_y:        i32,
	chunk_data_ptr: ^ChunkData,
	vertex_data:    [dynamic]f32,
	index_data:     [dynamic]u32,
	vbo:            rendering.VertexBuffer,
	vao:            rendering.VertexArray,
	ebo:            rendering.ElementBuffer,
    model: glsl.mat4,
}

create_chunk :: proc(chunk_x: i32, chunk_y: i32) -> Chunk {
	chunk: Chunk

	chunk.chunk_x = chunk_x
	chunk.chunk_y = chunk_y

	chunk.chunk_data_ptr = new(ChunkData)
	chunk.vertex_data = make([dynamic]f32)
	chunk.index_data = make([dynamic]u32)
    chunk.model = glsl.mat4Translate(glsl.vec3{16.0 * f32(chunk_x), 0.0, 16.0 * f32(chunk_y)})

    

	return chunk

}

generate_chunk :: proc(chunk: ^Chunk) {

	for x in 0 ..< 16 {
		for z in 0 ..< 16 {
			for y in 0 ..< 256 {
				if y > 64 {
					chunk.chunk_data_ptr.block_data[x][z][y] = 0
				} else {
					chunk.chunk_data_ptr.block_data[x][z][y] = 1
				}

			}
		}
	}

}

init_chunk :: proc(chunk: ^Chunk) {
    chunk.vao = rendering.create_vertex_array()


	chunk.vbo = rendering.create_vertex_buffer()
	chunk.ebo = rendering.create_element_buffer()



}

upload_chunk :: proc(chunk: ^Chunk) {


	rendering.bind_vertex_array(&chunk.vao)

	rendering.write_vertex_buffer(&chunk.vbo, len(chunk.vertex_data) * size_of(f32), &chunk.vertex_data[0])
	rendering.write_element_buffer(&chunk.ebo, len(chunk.index_data) * size_of(u32), &chunk.index_data[0])

	rendering.vertex_array_attrib(&chunk.vao, 0, gl.FLOAT, 3, size_of(f32) * 6, 0)
	rendering.vertex_array_attrib(&chunk.vao, 1, gl.FLOAT, 3, size_of(f32) * 6, 3 * size_of(f32))

	rendering.unbind_vertex_buffer()

	rendering.unbind_vertex_array()

}

update_chunk :: proc(chunk: ^Chunk) {

	clear(&chunk.vertex_data)
	clear(&chunk.index_data)

	indices_idx := 0

	for x in 0 ..< 16 {
		for z in 0 ..< 16 {
			for y in 0 ..< 256 {
				block_id := chunk.chunk_data_ptr.block_data[x][z][y]

				if block_id != 0 {

					append(&chunk.vertex_data, 0.0 + f32(x))
					append(&chunk.vertex_data, 0.0 + f32(y))
					append(&chunk.vertex_data, 0.0 + f32(z))

					append(&chunk.vertex_data, 1.0)
					append(&chunk.vertex_data, 0.0)
					append(&chunk.vertex_data, 0.0)


					append(&chunk.vertex_data, 1.0 + f32(x))
					append(&chunk.vertex_data, 0.0 + f32(y))
					append(&chunk.vertex_data, 0.0 + f32(z))

					append(&chunk.vertex_data, 1.0)
					append(&chunk.vertex_data, 1.0)
					append(&chunk.vertex_data, 0.0)


					append(&chunk.vertex_data, 1.0 + f32(x))
					append(&chunk.vertex_data, 1.0 + f32(y))
					append(&chunk.vertex_data, 0.0 + f32(z))

					append(&chunk.vertex_data, 1.0)
					append(&chunk.vertex_data, 0.0)
					append(&chunk.vertex_data, 0.0)


					append(&chunk.vertex_data, 0.0 + f32(x))
					append(&chunk.vertex_data, 1.0 + f32(y))
					append(&chunk.vertex_data, 0.0 + f32(z))

					append(&chunk.vertex_data, 1.0)
					append(&chunk.vertex_data, 1.0)
					append(&chunk.vertex_data, 0.0)


					append(&chunk.index_data, u32(0 + indices_idx))
					append(&chunk.index_data, u32(1 + indices_idx))
					append(&chunk.index_data, u32(2 + indices_idx))
					append(&chunk.index_data, u32(0 + indices_idx))
					append(&chunk.index_data, u32(3 + indices_idx))
					append(&chunk.index_data, u32(2 + indices_idx))

					indices_idx += 4


				}

			}
		}
	}

}


draw_chunk :: proc(chunk: ^Chunk, shader_program: ^rendering.ShaderProgram) {

    rendering.bind_element_buffer(&chunk.ebo)
    rendering.bind_vertex_array(&chunk.vao)

    modelLoc := gl.GetUniformLocation(shader_program.program_handle, "model")

    gl.UniformMatrix4fv(modelLoc, 1, gl.FALSE, raw_data(&chunk.model))

    gl.DrawElements(gl.TRIANGLES, i32(len(chunk.index_data)), gl.UNSIGNED_INT, rawptr(uintptr(0)))

}

destroy_chunk :: proc(chunk: ^Chunk) {
	free(chunk.chunk_data_ptr)
    rendering.delete_vertex_array(&chunk.vao)
    rendering.delete_vertex_buffer(&chunk.vbo)
    rendering.delete_element_buffer(&chunk.ebo)

}
