package voxel_engine

import "core:image/png"
import "core:image"
import "core:path/filepath"


PackedTextureData :: struct {
    x1: f32,
    x2: f32,
    y1: f32,
    y2: f32  
}

TexturePacker :: struct {
    atlas_image_data: ^[1600 * 1600 * 4]u8,
    packed_textures: map[u32]PackedTextureData,
    texture_directory: string,
    texture_id_next: u32
}



create_texture_packer :: proc(texture_directory: string) -> TexturePacker {
    packer: TexturePacker

    packer.atlas_image_data = new([1600 * 1600 * 4]u8)
    packer.texture_id_next = 0
    
    packer.packed_textures = make(map[u32]PackedTextureData)
    packer.texture_directory, _ = filepath.join({"resources", texture_directory}, context.allocator)

    for x in 0..<1600 {
        for y in 0..<1600 {
            pix_idx := 1600 * y + x

            packer.atlas_image_data[0 + pix_idx*4] = 0
            packer.atlas_image_data[1 + pix_idx*4] = 0
            packer.atlas_image_data[2 + pix_idx*4] = 0
            packer.atlas_image_data[3 + pix_idx*4] = 0
            

        }
    }
    
    return packer
}

texture_packer_add_file :: proc(packer: ^TexturePacker, image_name: string) -> u32 {
    texture_path, _ := filepath.join({packer.texture_directory, image_name}, context.allocator)

    tex_img, _ := image.load_from_file(texture_path)

    add_x: int = 0
    add_y: int = 0

    

    outer2: for x in 0..<1600 {
        for y in 0..<1600 {
            
            if (tex_img.width-1)+x >= 1600 {
                continue
            }
            if (tex_img.height-1)+y >= 1600 {
                continue
            }

            found_nonblank_pixel := false

            outer: for offset_x in 0..<tex_img.width {
                for offset_y in 0..<tex_img.height {
                
                    pix_idx := 1600 * (y + offset_y) + (x + offset_x)

                    if (packer.atlas_image_data[pix_idx*4 + 0] != 0) || (packer.atlas_image_data[pix_idx*4 + 1] != 0) || (packer.atlas_image_data[pix_idx*4 + 2] != 0) || (packer.atlas_image_data[pix_idx*4 + 3] != 0) {
                        found_nonblank_pixel = true
                        break outer
                    }

                }
            }

            if !found_nonblank_pixel {
                add_x = x
                add_y = y
                break outer2
            }
            
        } 
    }
    
    for offset_x in 0..<tex_img.width {
        for offset_y in 0..<tex_img.height {
        
            pix_idx := 1600 * (add_y + offset_y) + (add_x + offset_x)
            tex_idx := tex_img.width * offset_y + offset_x

            packer.atlas_image_data[pix_idx * 4 + 0] = tex_img.pixels.buf[tex_idx * 4 + 0]
            packer.atlas_image_data[pix_idx * 4 + 1] = tex_img.pixels.buf[tex_idx * 4 + 1]
            packer.atlas_image_data[pix_idx * 4 + 2] = tex_img.pixels.buf[tex_idx * 4 + 2]
            packer.atlas_image_data[pix_idx * 4 + 3] = tex_img.pixels.buf[tex_idx * 4 + 3]

        }
    }

    map_insert(&packer.packed_textures, packer.texture_id_next, PackedTextureData{f32(add_x) / 1600, f32(add_x) / 1600 + f32(tex_img.width) / 1600, f32(add_y) / 1600, f32(add_y) / 1600 + f32(tex_img.height) / 1600})
    imgi := packer.texture_id_next
    packer.texture_id_next += 1

    image.destroy(tex_img)
    
    delete(texture_path, context.allocator)

    return imgi
}


delete_texture_packer :: proc(texture_packer: ^TexturePacker) {
    free(texture_packer.atlas_image_data)
    delete(texture_packer.texture_directory, context.allocator)
    delete(texture_packer.packed_textures)

}