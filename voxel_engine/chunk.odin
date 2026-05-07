package voxel_engine

import "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import "../rendering"


ChunkData :: struct {
    block_data: [16][16][256]u16
}

Chunk :: struct {
    chunk_x: i32,
    chunk_y: i32,
    chunk_data_ptr: ^ChunkData
}

create_chunk :: proc(chunk_x: i32, chunk_y: i32) -> Chunk {
    chunk: Chunk

    chunk.chunk_x = chunk_x
    chunk.chunk_y = chunk_y

    chunk.chunk_data_ptr = new(ChunkData)

    return chunk

}


destroy_chunk :: proc(chunk: ^Chunk) {
    free(chunk.chunk_data_ptr)
}