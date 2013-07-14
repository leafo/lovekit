
punct = "[%^$()%.%[%]*+%-?]"
{min: _min, max: _max, random: _random} = math

export *

lovekit = lovekit or {}

rand = (min, max) ->
  _random! * (max - min) + min

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
    _max min, val - amount
  elseif val < -min
    _min -min, val + amount
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


get_local = (search_name, level=1) ->
  level += 1
  i = 1
  while true
    name, val = debug.getlocal level, i
    break unless name
    if name == search_name
      return val
    i += 1

lazy = (props) ->
  cls = get_local "self", 2
  for k,v in pairs props
    lazy_value cls, k, v

pick_one = (...) ->
  num = select "#", ...
  select _random(2,num), ...

shuffle = (array) ->
  for i=#array, 2, -1
    j = _random 2, i
    array[i], array[j] = array[j], array[i]
  array

instance_of = (object, cls) ->
  return false unless type(object) == "table"
  ocls = object.__class
  while true
    return true if ocls == cls
    ocls = type(ocls) == "table" and ocls.__parent
    break unless ocls

