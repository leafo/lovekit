local _M = { }
local _list_0 = {
  "support",
  "image",
  "geometry",
  "tilemap",
  "spriter",
  "viewport",
  "entity",
  "input",
  "sequence",
  "lists",
  "state",
  "color",
  "effects",
  "audio",
  "particles",
  "mixins",
  "paths",
  "shaders"
}
for _index_0 = 1, #_list_0 do
  local mod = _list_0[_index_0]
  local tbl = require("lovekit." .. tostring(mod))
  for k, v in pairs(tbl) do
    _M[k] = v
  end
end
return _M
