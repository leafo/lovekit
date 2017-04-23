
punct = "[%^$()%.%[%]*+%-?]"
{min: _min, max: _max} = math

import COLOR from require "lovekit.color"

local *

_random = if love and love.math
  love.math.random
else
  math.random

rand = (min, max) ->
  _random! * (max - min) + min

chance = (p) ->
  love.math.random! <= p

random_normal = ->
  (_random! + _random! + _random! + _random! + _random! + _random! + _random! + _random! + _random! + _random! + _random! + _random!) / 12

smoothstep = (a, b, t) ->
  t = t*t*t*(t*(t*6 - 15) + 10)
  a + (b - a)*t

sqrt_step = (a, b, t) ->
  a + (b - a)*math.sqrt(t)

pow_step = (a, b, t) ->
  a + (b - a)*(t^2)

lerp = (a,b,t) -> a + (b - a)*t

cubic_bez = (p0, p1, p2, p3, t) ->
  nt = (1 - t)
  nt2 = nt * nt
  nt3 = nt2 *  nt
  t2 = t * t
  t3 = t2 * t

  (nt3 * p0) + (3 * nt2 * t * p1) + (3 * nt * t2 * p2) + (t3 * p3)

-- goes 0 to 1 from start to attack
-- goes 1 from 0 to decay to stop
ad_curve = (t, start, attack, decay, stop=1) ->
  if t < start
    return 0

  if t > stop
    return 0

  if t < attack
    return (t - start) / (attack - start)

  if t > decay
    return 1 - (t - decay) / (stop - decay)

  1

-- time: time to grow to enlarged size
-- amount: the enlarged size
-- decay: multiplied by time to calculate pop out time
pop_in = (t, time=0.1, amount=1.1, decay=1) ->
  pop_out_time = time * decay
  if t < time
    lerp 0, amount, t / time
  elseif t < time + pop_out_time
    lerp amount, 1, (t - time) / pop_out_time
  else
    1

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

-- merge tables by copying
merge = (first, second, ...) ->
  return first unless first and second
  for k,v in pairs second
    first[k] = v

  merge first, ...

-- takes viewport
-- draws grid on scaled pixel boundaries
-- call me after applying viewport please
show_grid = (v, step=1) ->
  return if v.scale == 1 and step == 1
  love.graphics.setLineWidth 1/v.scale
  COLOR\pusha 128

  import line from love.graphics

  w, h = v.w + 1, v.h + 1
  sx = math.floor(v.x)
  sy = math.floor(v.y)

  sx = sx - sx % step
  sy = sy - sy % step

  for y = sy, sy + h, step
    line sx, y, sx + w + step, y

  for x = sx, sx + w, step
    line x, sy, x, sy + h + step

  COLOR\pop!

approach = (val, target, amount) ->
  return val if val == target
  if val > target
    _max target, val - amount
  else
    _min target, val + amount

-- take into account distance between val and target
smooth_approach = (val, target, amount) ->
  approach val, target, amount * (1 + math.abs(val - target)^1.1)

-- go to zero
dampen = (val, amount, min=0) ->
  if val > min
    _max min, val - amount
  elseif val < -min
    _min -min, val + amount
  else
    val

dampen_vector = (vec, amount, min) ->
  len = vec\len!
  return if len == 0

  new_len = dampen len, amount, min
  vec[1] = vec[1] / len * new_len
  vec[2] = vec[2] / len * new_len
  vec

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


lazy_tbl = (tbl) ->
  setmetatable {}, __index: (name) =>
    @[name] = tbl[name]!
    @[name]

lazy = (props) ->
  cls = get_local "self", 2
  for k,v in pairs props
    lazy_value cls, k, v

pick_one = (...) ->
  num = select "#", ...
  (select _random(1,num), ...)

pick_dist = (t) ->
  sum = 0
  dist = for k, v in pairs t
    continue if v == 0 or not v
    with {sum + v, k}
      sum += v

  r = _random! * sum
  for {prob, v} in *dist
    if r <= prob
      return v

  error "got nothing!"

duty_on = (rate=1.2, duty=0.6, start_time=0) ->
  t = love.timer.getTime() - start_time
  t = t / rate
  t = t - math.floor t
  t <= duty

shuffle = (array) ->
  for i=#array, 2, -1
    j = _random i
    array[i], array[j] = array[j], array[i]
  array

reverse = (array) ->
  len = #array
  for i=1,math.floor len/2
    array[i], array[len - i + 1] = array[len - i + 1], array[i]
  array

instance_of = (object, cls) ->
  return false unless type(object) == "table"
  ocls = object.__class
  while true
    return true if ocls == cls
    ocls = type(ocls) == "table" and ocls.__parent
    break unless ocls

-- for thing in all_values {1,2,3}, {4,5,6}
all_values = do
  free = setmetatable {}, __mode: "k"

  fill_t = (t, i, first, ...) ->
    if first
      t[i] = first
      fill_t t, i + 1, ...
    else
      t

  each = (s) ->
    val = s[s.outer][s.inner]
    if val == nil
      s[s.outer] = nil
      s.outer += 1
      outer = s[s.outer]
      if outer == nil
        s[s.outer] = nil
        free[s] = true
        return nil

      s.inner = 1
      val = outer[s.inner]

    s.inner += 1

    val

  (...) ->
    local s
    if s = next free
      free[s] = nil
      s.inner = 1
      s.outer = 1
      fill_t s, 1, ...
    else
      s = { inner: 1, outer: 1, ... }

    each, s

count_garbage_collections = ->
  export GARBAGE_COLLECTIONS = 0
  count_gc = ->
    GARBAGE_COLLECTIONS += 1
    getmetatable(newproxy(true)).__gc = count_gc

  getmetatable(newproxy(true)).__gc = count_gc

get_local = (search_name, level=1) ->
  level += 1
  i = 1
  while true
    name, val = debug.getlocal level, i
    break unless name
    if name == search_name
      return val, true, i
    i += 1

  nil, false, i

find_local = (name, level=1) ->
  while true
    val, found, idx = get_local name, level + 1
    return val, level if found
    level += 1

{
  :rand
  :random_normal
  :smoothstep
  :pow_step
  :sqrt_step
  :lerp
  :ad_curve
  :escape_patt
  :split
  :mixin_object
  :bench
  :hash_color
  :extend
  :merge
  :show_grid
  :approach
  :smooth_approach
  :dampen
  :dampen_vector
  :lazy_value
  :get_local
  :lazy_tbl
  :lazy
  :pick_one
  :pick_dist
  :duty_on
  :shuffle
  :instance_of
  :all_values
  :count_garbage_collections
  :find_local
  :chance
  :reverse
  :cubic_bez
  :pop_in
}

