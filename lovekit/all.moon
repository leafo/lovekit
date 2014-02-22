
-- require module, put into global
r = (mod) ->
  tbl = require mod
  for k,v in pairs tbl
    _G[k] = v

r "lovekit.support"
r
r "lovekit.geometry"
r "lovekit.tilemap"
r "lovekit.spriter"
r "lovekit.viewport"
r "lovekit.entity"
r "lovekit.input"
r "lovekit.sequence"
r "lovekit.lists"
r "lovekit.state"
r "lovekit.color"
r "lovekit.effects"
r "lovekit.audio"
r "lovekit.particles"
r "lovekit.mixins"
r "lovekit.paths"

