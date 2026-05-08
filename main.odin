package main

import "core:fmt"
import "voxel_engine"




main :: proc() {

    app := voxel_engine.init_game()

    defer voxel_engine.cleanup_game(&app)

    voxel_engine.run_game(&app)

}