
punct = "[%^$()%.%[%]*+%-?]"

export *

lovekit = lovekit or {}

smoothstep = (a, b, t) ->
  t = t*t*t*(t*(t*6 - 15) + 10)
  a + (b - a)*t

escape_patt = (str) ->
  (str\gsub punct, (p) -> "%"..p)

split = (str, delim using nil) ->
  str ..= delim
  [part for part in str\gmatch "(.-)" .. escape_patt(delim)]

-- TODO move these elsewhere
mixin_object = (object, methods) =>
  for name in *methods
    self[name] = (parent, ...) ->
      object[name](object, ...)

bench = (name, fn) ->
  start = love.timer.getTime!
  fn!
  print "++ Benchmark:", name, love.timer.getTime! - start

hash_color = (r,g,b,a) ->
  table.concat {r,g,b}, ","

-- chain together tables by __index metatables
extend = (...) ->
  tbls = {...}
  return if #tbls < 2

  for i = 1, #tbls - 1
    a = tbls[i]
    b = tbls[i + 1]

    setmetatable a, __index: b

  tbls[1]

-- takes viewport
-- draws grid on scaled pixel boundaries
show_grid = (v) ->
  return if v.screen.scale == 1
  graphics.setLineWidth 1/v.screen.scale
  graphics.setColor 255,255,255, 128

  w, h = v.w + 1, v.h + 1
  sx = math.floor v.x
  sy = math.floor v.y

  for y = sy, sy + h
    graphics.line sx, y, sx + w, y

  for x = sx, sx + w
    graphics.line x, sy, x, sy + h

  graphics.setColor 255,255,255


