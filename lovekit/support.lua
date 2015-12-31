local punct = "[%^$()%.%[%]*+%-?]"
local _min, _max
do
  local _obj_0 = math
  _min, _max = _obj_0.min, _obj_0.max
end
local COLOR
COLOR = require("lovekit.color").COLOR
local _random, rand, chance, random_normal, smoothstep, sqrt_step, pow_step, lerp, cubic_bez, ad_curve, pop_in, escape_patt, split, mixin_object, bench, hash_color, extend, merge, show_grid, approach, smooth_approach, dampen, dampen_vector, lazy_key, lazy_value, lazy_tbl, lazy, pick_one, pick_dist, duty_on, shuffle, reverse, instance_of, all_values, count_garbage_collections, get_local, find_local
if love and love.math then
  _random = love.math.random
else
  _random = math.random
end
rand = function(min, max)
  return _random() * (max - min) + min
end
chance = function(p)
  return love.math.random() <= p
end
random_normal = function()
  return (_random() + _random() + _random() + _random() + _random() + _random() + _random() + _random() + _random() + _random() + _random() + _random()) / 12
end
smoothstep = function(a, b, t)
  t = t * t * t * (t * (t * 6 - 15) + 10)
  return a + (b - a) * t
end
sqrt_step = function(a, b, t)
  return a + (b - a) * math.sqrt(t)
end
pow_step = function(a, b, t)
  return a + (b - a) * (t ^ 2)
end
lerp = function(a, b, t)
  return a + (b - a) * t
end
cubic_bez = function(p0, p1, p2, p3, t)
  local nt = (1 - t)
  local nt2 = nt * nt
  local nt3 = nt2 * nt
  local t2 = t * t
  local t3 = t2 * t
  return (nt3 * p0) + (3 * nt2 * t * p1) + (3 * nt * t2 * p2) + (t3 * p3)
end
ad_curve = function(t, start, attack, decay, stop)
  if stop == nil then
    stop = 1
  end
  if t < start then
    return 0
  end
  if t > stop then
    return 0
  end
  if t < attack then
    return (t - start) / (attack - start)
  end
  if t > decay then
    return 1 - (t - decay) / (stop - decay)
  end
  return 1
end
pop_in = function(t, time, amount, decay)
  if time == nil then
    time = 0.1
  end
  if amount == nil then
    amount = 1.1
  end
  if decay == nil then
    decay = 1
  end
  local pop_out_time = time * decay
  if t < time then
    return lerp(0, amount, t / time)
  elseif t < time + pop_out_time then
    return lerp(amount, 1, (t - time) / pop_out_time)
  else
    return 1
  end
end
escape_patt = function(str)
  return (str:gsub(punct, function(p)
    return "%" .. p
  end))
end
split = function(str, delim)
  str = str .. delim
  local _accum_0 = { }
  local _len_0 = 1
  for part in str:gmatch("(.-)" .. escape_patt(delim)) do
    _accum_0[_len_0] = part
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
mixin_object = function(self, object, methods)
  for _index_0 = 1, #methods do
    local name = methods[_index_0]
    self[name] = function(parent, ...)
      return object[name](object, ...)
    end
  end
end
bench = function(name, fn)
  local start = love.timer.getTime()
  fn()
  return print("++ Benchmark:", name, love.timer.getTime() - start)
end
hash_color = function(r, g, b, a)
  return table.concat({
    r,
    g,
    b
  }, ",")
end
extend = function(...)
  local tbls = {
    ...
  }
  if #tbls < 2 then
    return 
  end
  for i = 1, #tbls - 1 do
    local a = tbls[i]
    local b = tbls[i + 1]
    setmetatable(a, {
      __index = b
    })
  end
  return tbls[1]
end
merge = function(first, second, ...)
  if not (first and second) then
    return first
  end
  for k, v in pairs(second) do
    first[k] = v
  end
  return merge(first, ...)
end
show_grid = function(v, step)
  if step == nil then
    step = 1
  end
  if v.scale == 1 and step == 1 then
    return 
  end
  love.graphics.setLineWidth(1 / v.scale)
  COLOR:pusha(128)
  local line
  line = love.graphics.line
  local w, h = v.w + 1, v.h + 1
  local sx = math.floor(v.x)
  local sy = math.floor(v.y)
  sx = sx - sx % step
  sy = sy - sy % step
  for y = sy, sy + h, step do
    line(sx, y, sx + w + step, y)
  end
  for x = sx, sx + w, step do
    line(x, sy, x, sy + h + step)
  end
  return COLOR:pop()
end
approach = function(val, target, amount)
  if val == target then
    return val
  end
  if val > target then
    return _max(target, val - amount)
  else
    return _min(target, val + amount)
  end
end
smooth_approach = function(val, target, amount)
  return approach(val, target, amount * (1 + math.abs(val - target) ^ 1.1))
end
dampen = function(val, amount, min)
  if min == nil then
    min = 0
  end
  if val > min then
    return _max(min, val - amount)
  elseif val < -min then
    return _min(-min, val + amount)
  else
    return val
  end
end
dampen_vector = function(vec, amount, min)
  local len = vec:len()
  if len == 0 then
    return 
  end
  local new_len = dampen(len, amount, min)
  vec[1] = vec[1] / len * new_len
  vec[2] = vec[2] / len * new_len
  return vec
end
lazy_key = { }
lazy_value = function(cls, key, fn)
  local base = cls.__base
  local old_meta = getmetatable(base)
  if old_meta then
    do
      local lazy_values = old_meta[lazy_key]
      if lazy_values then
        lazy_values[key] = fn
        return 
      end
    end
  end
  local eigen = setmetatable({ }, old_meta)
  local lazy_values = {
    [key] = fn
  }
  local meta = {
    [lazy_key] = lazy_values,
    __index = function(self, name)
      do
        fn = lazy_values[name]
        if fn then
          lazy_values[name] = nil
          local val = fn(base, cls)
          base[name] = val
          if next(lazy_values) == nil then
            setmetatable(base, old_meta)
          end
          return val
        else
          return eigen[name]
        end
      end
    end
  }
  return setmetatable(base, meta)
end
lazy_tbl = function(tbl)
  return setmetatable({ }, {
    __index = function(self, name)
      self[name] = tbl[name]()
      return self[name]
    end
  })
end
lazy = function(props)
  local cls = get_local("self", 2)
  for k, v in pairs(props) do
    lazy_value(cls, k, v)
  end
end
pick_one = function(...)
  local num = select("#", ...)
  return (select(_random(1, num), ...))
end
pick_dist = function(t)
  local sum = 0
  local dist
  do
    local _accum_0 = { }
    local _len_0 = 1
    for k, v in pairs(t) do
      do
        local _with_0 = {
          sum + v,
          k
        }
        sum = sum + v
        _accum_0[_len_0] = _with_0
      end
      _len_0 = _len_0 + 1
    end
    dist = _accum_0
  end
  local r = _random() * sum
  for _index_0 = 1, #dist do
    local _des_0 = dist[_index_0]
    local prob, v
    prob, v = _des_0[1], _des_0[2]
    if r <= prob then
      return v
    end
  end
  return error("got nothing!")
end
duty_on = function(rate, duty, start_time)
  if rate == nil then
    rate = 1.2
  end
  if duty == nil then
    duty = 0.6
  end
  if start_time == nil then
    start_time = 0
  end
  local t = love.timer.getTime() - start_time
  t = t / rate
  t = t - math.floor(t)
  return t <= duty
end
shuffle = function(array)
  for i = #array, 2, -1 do
    local j = _random(i)
    array[i], array[j] = array[j], array[i]
  end
  return array
end
reverse = function(array)
  local len = #array
  for i = 1, math.floor(len / 2) do
    array[i], array[len - i + 1] = array[len - i + 1], array[i]
  end
  return array
end
instance_of = function(object, cls)
  if not (type(object) == "table") then
    return false
  end
  local ocls = object.__class
  while true do
    if ocls == cls then
      return true
    end
    ocls = type(ocls) == "table" and ocls.__parent
    if not (ocls) then
      break
    end
  end
end
do
  local free = setmetatable({ }, {
    __mode = "k"
  })
  local fill_t
  fill_t = function(t, i, first, ...)
    if first then
      t[i] = first
      return fill_t(t, i + 1, ...)
    else
      return t
    end
  end
  local each
  each = function(s)
    local val = s[s.outer][s.inner]
    if val == nil then
      s[s.outer] = nil
      s.outer = s.outer + 1
      local outer = s[s.outer]
      if outer == nil then
        s[s.outer] = nil
        free[s] = true
        return nil
      end
      s.inner = 1
      val = outer[s.inner]
    end
    s.inner = s.inner + 1
    return val
  end
  all_values = function(...)
    local s
    do
      s = next(free)
      if s then
        free[s] = nil
        s.inner = 1
        s.outer = 1
        fill_t(s, 1, ...)
      else
        s = {
          inner = 1,
          outer = 1,
          ...
        }
      end
    end
    return each, s
  end
end
count_garbage_collections = function()
  GARBAGE_COLLECTIONS = 0
  local count_gc
  count_gc = function()
    GARBAGE_COLLECTIONS = GARBAGE_COLLECTIONS + 1
    getmetatable(newproxy(true)).__gc = count_gc
  end
  getmetatable(newproxy(true)).__gc = count_gc
end
get_local = function(search_name, level)
  if level == nil then
    level = 1
  end
  level = level + 1
  local i = 1
  while true do
    local name, val = debug.getlocal(level, i)
    if not (name) then
      break
    end
    if name == search_name then
      return val, true, i
    end
    i = i + 1
  end
  return nil, false, i
end
find_local = function(name, level)
  if level == nil then
    level = 1
  end
  while true do
    local val, found, idx = get_local(name, level + 1)
    if found then
      return val, level
    end
    level = level + 1
  end
end
return {
  rand = rand,
  random_normal = random_normal,
  smoothstep = smoothstep,
  pow_step = pow_step,
  sqrt_step = sqrt_step,
  lerp = lerp,
  ad_curve = ad_curve,
  escape_patt = escape_patt,
  split = split,
  mixin_object = mixin_object,
  bench = bench,
  hash_color = hash_color,
  extend = extend,
  merge = merge,
  show_grid = show_grid,
  approach = approach,
  smooth_approach = smooth_approach,
  dampen = dampen,
  dampen_vector = dampen_vector,
  lazy_value = lazy_value,
  get_local = get_local,
  lazy_tbl = lazy_tbl,
  lazy = lazy,
  pick_one = pick_one,
  pick_dist = pick_dist,
  duty_on = duty_on,
  shuffle = shuffle,
  instance_of = instance_of,
  all_values = all_values,
  count_garbage_collections = count_garbage_collections,
  find_local = find_local,
  chance = chance,
  reverse = reverse,
  cubic_bez = cubic_bez,
  pop_in = pop_in
}
