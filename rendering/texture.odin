package rendering

import gl "vendor:OpenGL"


Texture :: struct {
    texture_handle: u32
}

create_texture :: proc() -> Texture {
    tex: Texture

    gl.GenTextures(1, &tex.texture_handle)

    bind_texture(&tex)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

    //gl.TexParameterf(gl.TEXTURE_2D, gl.TEXTURE_MAX_ANISOTROPY, 16.0)
    
    return tex
}

write_texture :: proc(tex: ^Texture, image_data_ptr: rawptr, width: i32, height: i32) {

    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, image_data_ptr)
    gl.GenerateMipmap(gl.TEXTURE_2D)
}


bind_texture :: proc(texture: ^Texture) {
    gl.BindTexture(gl.TEXTURE_2D, texture.texture_handle)

}


delete_texture :: proc(texture: ^Texture) {
    gl.DeleteTextures(1, &texture.texture_handle)
}