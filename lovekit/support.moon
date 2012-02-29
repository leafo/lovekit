
export *

lovekit = lovekit or {}

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

