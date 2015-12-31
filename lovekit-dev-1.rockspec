package = "lovekit"
version = "dev-1"

source = {
  url = "git://github.com/leafo/lovekit.git"
}

description = {
   homepage = "http://github.com/leafo/lovekit",
   license = "MIT"
}

dependencies = {
   "lua ~> 5.1"
}

build = {
   type = "builtin",
   modules = {
    ["lovekit"] = "lovekit/init.lua",
    ["lovekit.all"] = "lovekit/all.lua",
    ["lovekit.audio"] = "lovekit/audio.lua",
    ["lovekit.color"] = "lovekit/color.lua",
    ["lovekit.effects"] = "lovekit/effects.lua",
    ["lovekit.entity"] = "lovekit/entity.lua",
    ["lovekit.geometry"] = "lovekit/geometry.lua",
    ["lovekit.image"] = "lovekit/image.lua",
    ["lovekit.input"] = "lovekit/input.lua",
    ["lovekit.lists"] = "lovekit/lists.lua",
    ["lovekit.mixins"] = "lovekit/mixins.lua",
    ["lovekit.particles"] = "lovekit/particles.lua",
    ["lovekit.paths"] = "lovekit/paths.lua",
    ["lovekit.profile"] = "lovekit/profile.lua",
    ["lovekit.reloader"] = "lovekit/reloader.lua",
    ["lovekit.screen_snap"] = "lovekit/screen_snap.lua",
    ["lovekit.sequence"] = "lovekit/sequence.lua",
    ["lovekit.shaders"] = "lovekit/shaders.lua",
    ["lovekit.spriter"] = "lovekit/spriter.lua",
    ["lovekit.state"] = "lovekit/state.lua",
    ["lovekit.support"] = "lovekit/support.lua",
    ["lovekit.tilemap"] = "lovekit/tilemap.lua",
    ["lovekit.ui"] = "lovekit/ui.lua",
    ["lovekit.viewport"] = "lovekit/viewport.lua",
   }
}
