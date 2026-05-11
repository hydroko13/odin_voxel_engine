package voxel_engine

import "../rendering"
import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"
import "core:math/rand"
import "core:os"
import "core:path/filepath"
import "core:slice"
import "core:sync"
import "core:sync/chan"
import "core:thread"
import "core:time"
import "vendor:glfw"


import gl "vendor:OpenGL"

Application :: struct {
	glfw_window:    glfw.WindowHandle,
	shader_program: rendering.ShaderProgram,
	camera:         Camera,
	projection:     glsl.mat4,
	chunks:         [dynamic]Chunk,
	block_texture_packer: TexturePacker,
	blocks_texture: rendering.Texture,
}

ChunkWorkerArgs :: struct {
	send_chan: chan.Chan(Chunk, .Send),
	recv_chan: chan.Chan(glsl.ivec2, .Recv),
	packer_ptr: ^TexturePacker
}

ChunkPosWithDist :: struct {
	pos: glsl.ivec2,
	dist: int
}


chunk_gen_worker :: proc(args: ChunkWorkerArgs) {

	send_chan := args.send_chan
	recv_chan := args.recv_chan
	packer_ptr := args.packer_ptr

	for {

		pos, _ := chan.recv(recv_chan)

		chunk: Chunk = create_chunk(pos.x, pos.y)

		generate_chunk(&chunk)
		update_chunk(&chunk, packer_ptr)


		chan.send(send_chan, chunk)

		chunk.chunk_data_ptr = nil
		chunk.index_data = nil
		chunk.vertex_data = nil

	}
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

	app.chunks = make([dynamic]Chunk, 0, 10)

	app.shader_program = rendering.create_shader_program(
		transmute(string)vert_dat,
		transmute(string)frag_dat,
	)

	rendering.use_shader_program(&app.shader_program)
	gl.Enable(gl.DEPTH_TEST)

	app.block_texture_packer = create_texture_packer("block_textures")

	texture_packer_add_file(&app.block_texture_packer, "dirt.png")
	fmt.println(texture_packer_add_file(&app.block_texture_packer, "grass_side.png"))
	texture_packer_add_file(&app.block_texture_packer, "grass_top.png")


	app.blocks_texture = rendering.create_texture()

	rendering.write_texture(&app.blocks_texture, app.block_texture_packer.atlas_image_data, 1600, 1600)


	

	
	//gl.Enable(gl.CULL_FACE)


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

	app.camera = Camera{90.0, -90, glsl.vec3{0.0, 130, 0.0}}

	app.projection = glsl.mat4Perspective(
		glsl.radians(f32(45.0)),
		1280.0 / 720.0,
		0.01,
		10000000.0,
	)

	// app.chunk = create_chunk(0, 0)

	// generate_chunk(&app.chunk)
	// init_chunk(&app.chunk)

	// update_chunk(&app.chunk)

	// upload_chunk(&app.chunk)

	return app
}

run_game :: proc(app: ^Application) {

	gl.ClearColor(0.363, 0.837, 0.861, 1.0)

	viewLoc := gl.GetUniformLocation(app.shader_program.program_handle, "view")
	projLoc := gl.GetUniformLocation(app.shader_program.program_handle, "proj")
	texLoc := gl.GetUniformLocation(app.shader_program.program_handle, "block_tex")

	lastMouseX, lastMouseY := glfw.GetCursorPos(app.glfw_window)
	lastTime := glfw.GetTime()

	newlyGeneratedChunks, _ := chan.create_buffered(chan.Chan(Chunk), 32, context.allocator)
	chunkPositionsToGenerate, _ := chan.create_buffered(
		chan.Chan(glsl.ivec2),
		64,
		context.allocator,
	)


	chunksPositionsAlreadyGenerated := make([dynamic]glsl.ivec2, 0, 250)

	defer delete(chunksPositionsAlreadyGenerated)

	last_chunk_origin_x := 0
	last_chunk_origin_y := 0

	gen_radius := 8

	defer chan.destroy(newlyGeneratedChunks)

	workerThreads := make([dynamic]^thread.Thread, 0, 10)

	defer delete(workerThreads)

	for thread_id in 0 ..< 8 {
		chunkGenThread := thread.create_and_start_with_poly_data(
			ChunkWorkerArgs {
				chan.as_send(newlyGeneratedChunks),
				chan.as_recv(chunkPositionsToGenerate),
				&app.block_texture_packer
			},
			chunk_gen_worker,
			init_context = context,
		)
		
		append(&workerThreads, chunkGenThread)


	}

	for !glfw.WindowShouldClose(app.glfw_window) {

		time := glfw.GetTime()
		deltaTime := f32(time - lastTime)
		lastTime = time


		for {
			new_chunk, ok := chan.try_recv(newlyGeneratedChunks)

			if ok {
				init_chunk(&new_chunk)
				upload_chunk(&new_chunk)

				append(&app.chunks, new_chunk)

				new_chunk.index_data = nil
				new_chunk.vertex_data = nil
				new_chunk.chunk_data_ptr = nil


			} else {
				break
			}

		}


		if glfw.GetKey(app.glfw_window, glfw.KEY_ESCAPE) == 1 {
			glfw.SetWindowShouldClose(app.glfw_window, true)
		}

		if glfw.GetKey(app.glfw_window, glfw.KEY_W) == 1 {
			camera_move_forward(&app.camera, deltaTime * 45)
		}

		if glfw.GetKey(app.glfw_window, glfw.KEY_S) == 1 {
			camera_move_forward(&app.camera, deltaTime * -45)
		}

		chunk_origin_x := int(math.floor(app.camera.pos.x / 16.0))
		chunk_origin_y := int(math.floor(app.camera.pos.z / 16.0))


		positions_to_send := make([dynamic]ChunkPosWithDist, 0, 64)

		for x in -gen_radius..=gen_radius {
			for z in -gen_radius..=gen_radius {

				dist := x * x + z * z
				if dist < gen_radius * gen_radius {
					append(&positions_to_send, ChunkPosWithDist{glsl.ivec2{i32(x), i32(z)}, dist})
				}


			}
		}

		slice.sort_by(positions_to_send[:], proc(i, j : ChunkPosWithDist) -> bool {
			return i.dist < j.dist
		})

		for cp in positions_to_send {
			p := cp.pos
			pos := glsl.ivec2{p.x + i32(chunk_origin_x), p.y + i32(chunk_origin_y)}

			if !slice.contains(chunksPositionsAlreadyGenerated[:], pos) {

				ok := chan.try_send(chunkPositionsToGenerate, pos)
				if ok {
					append(&chunksPositionsAlreadyGenerated, pos)
				}
			}

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

		gl.ActiveTexture(gl.TEXTURE0)

		gl.Uniform1i(texLoc, 0)


		for &chunk in app.chunks {
			draw_chunk(&chunk, &app.shader_program)
		}


		glfw.SwapBuffers(app.glfw_window)

		glfw.PollEvents()
	}
}

cleanup_game :: proc(app: ^Application) {

	for &chunk in app.chunks {
		destroy_chunk(&chunk)
	}

	delete(app.chunks)
	rendering.delete_texture(&app.blocks_texture)
	delete_texture_packer(&app.block_texture_packer)

	rendering.delete_shader_program(&app.shader_program)


	glfw.DestroyWindow(app.glfw_window)
	glfw.Terminate()

}
