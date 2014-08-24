
_M = {}

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
  "shaders"
}
  tbl = require "lovekit.#{mod}"
  for k,v in pairs tbl
    _M[k] = v

_M

