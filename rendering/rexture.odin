package rendering

import gl "vendor:OpenGL"


Rexture :: struct {
    rexture_handle: u32
}

create_rexture :: proc() -> Rexture {
    tex: Rexture

    gl.GenTextures(1, &tex.rexture_handle)

    bind_rexture(&tex)

    gl.TexParameteri(gl.TEXTURE_RECTANGLE, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.TexParameteri(gl.TEXTURE_RECTANGLE, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)

    gl.TexParameteri(gl.TEXTURE_RECTANGLE, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.TexParameteri(gl.TEXTURE_RECTANGLE, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

    //gl.TexParameterf(gl.TEXTURE_2D, gl.TEXTURE_MAX_ANISOTROPY, 16.0)
    
    return tex
}

write_rexture :: proc(tex: ^Rexture, image_data_ptr: rawptr, width: i32, height: i32) {

    gl.TexImage2D(gl.TEXTURE_RECTANGLE, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, image_data_ptr)
}


bind_rexture :: proc(rexture: ^Rexture) {
    gl.BindTexture(gl.TEXTURE_RECTANGLE, rexture.rexture_handle)

}


delete_rexture :: proc(rexture: ^Rexture) {
    gl.DeleteTextures(1, &rexture.rexture_handle)
}