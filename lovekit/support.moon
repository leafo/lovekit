
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

