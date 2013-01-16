
punct = "[%^$()%.%[%]*+%-?]"
{min: _min, max: _max} = math

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

approach = (val, target, amount) ->
  return val if val == target
  if val > target
    _max target, val - amount
  else
    _min target, val + amount

-- go to zero
dampen = (val, amount, min=0) ->
  if val > min
    math.max min, val - amount
  elseif val < -min
    math.min -min, val + amount
  else
    val

dampen_vector = (vec, amount, min) ->
  vec[1] = dampen vec[1], amount, min
  vec[2] = dampen vec[2], amount, min
  ved

lazy_key = {}
lazy_value = (cls, key, fn) ->
  base = cls.__base
  old_meta = getmetatable base

  -- reuse the old metatable if it's already lazy
  if old_meta
    if lazy_values = old_meta[lazy_key]
      lazy_values[key] = fn
      return

  eigen = setmetatable {}, old_meta
  lazy_values = { [key]: fn }
  meta = {
    [lazy_key]: lazy_values
    __index: (name) =>
      if fn = lazy_values[name]
        lazy_values[name] = nil
        val = fn base, cls
        base[name] = val
        if next(lazy_values) == nil
          setmetatable base, old_meta
        val
      else
        eigen[name]
  }

  setmetatable base, meta

pick_one = (...) ->
  num = select "#", ...
  select math.random(1,num), ...

if ... == "test"
  class Base
    what: "world"

  class Test extends Base
    real: "hello"
    lazy_value @, "hello", -> "world"
    lazy_value @, "eat", -> "me"

  t = Test!
  print t.real
  print t.what
  print t.hello
  print t.hello
  print t.real, t.what
  print t.eat

