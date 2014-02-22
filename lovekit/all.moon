
-- require module, put into global
for mod in *{
  "support"
  "image"
  "geometry"
  "tilemap"
  "spriter"
  "viewport"
  "entity"
  "input"
  "sequence"
  "lists"
  "state"
  "color"
  "effects"
  "audio"
  "particles"
  "mixins"
  "paths"
}
  tbl = require "lovekit.#{mod}"
  for k,v in pairs tbl
    _G[k] = v

