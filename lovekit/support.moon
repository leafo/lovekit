
export *

lovekit = lovekit or {}

smoothstep = (a, b, t) ->
  t = t*t*t*(t*(t*6 - 15) + 10)
  a + (b - a)*t


-- TODO move these elsewhere
mixin_object = (object, methods) =>
  for name in *methods
    self[name] = (parent, ...) ->
      object[name](object, ...)

bench = (name, fn) ->
  start = getMicroTime!
  fn!
  print "++ Benchmark:", name, getMicroTime! - start

hash_color = (r,g,b,a) ->
  table.concat {r,g,b}, ","


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


