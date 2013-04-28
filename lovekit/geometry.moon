
-- collision stuff

import rectangle, setColor from love.graphics
import rad, atan2, cos, sin, random, abs from math

export *

_floor, _ceil, _deg = math.floor, math.ceil, math.deg

floor = (n) ->
  if n < 0
    -_floor -n
  else
    _floor n


ceil = (n) ->
  if n < 0
    -_ceil -n
  else
    _ceil n

class Vec2d
  base = self.__base
  self.__base.__index = (name) =>
    if name == "x"
      self[1]
    elseif name == "y"
      self[2]
    else
      base[name]

  self.from_angle = (deg) ->
    theta = rad deg
    Vec2d cos(theta), sin(theta)

  self.from_radians = (rads) ->
    Vec2d cos(rads), sin(rads)

  self.random = (mag=1) ->
    vec = Vec2d.from_angle math.random() * 360
    vec * mag

  angle: => _deg atan2 self[2], self[1]
  radians: => atan2 @[2], @[1]

  new: (x=0, y=0) =>
    self[1] = x
    self[2] = y

  len: =>
    n = self[1]^2 + self[2]^2
    return 0 if n == 0
    math.sqrt n

  dup: => Vec2d unpack @

  is_zero: => self[1] == 0 and self[2] == 0

  left: => return self[1] < 0
  right: => return self[1] > 0

  update: (x, y) =>
    self[1], self[2] = x, y
    @

  adjust: (dx, dy) =>
    self[1] += dx
    self[2] += dy
    @

  normalized: =>
    len = @len!
    if len == 0
      Vec2d!
    else
      Vec2d self[1] / len, self[2] / len

  -- rotates it 90 degress
  cross: =>
    Vec2d -@[2], @[1]

  -- mirrors around origin
  flip: =>
    Vec2d -@[1], -@[2]

  truncate: (max_len) =>
    l = @len!
    if l > max_len
      self[1] = self[1] / l * max_len
      self[2] = self[2] / l * max_len

  direction_name:(names={"up", "right", "down", "left"}) =>
    if abs(self[1]) > abs(self[2])
      if self[1] < 0
        names[4]
      else
        names[2]
    else
      if self[2] < 0
        names[1]
      else
        names[3]

  -- x' = x cos f - y sin f
  -- y' = y cos f + x sin f
  rotate: (rads) =>
    {x, y} = @
    c, s = cos(rads), sin(rads)
    Vec2d x*c - y*s, y*c + x*s

  __mul: (left, right) ->
    if type(left) == "number"
      if type(right) == "number"
        error "put dot product here!"
      else
        Vec2d left * right[1], left * right[2]
    else
      Vec2d left[1] * right, left[2] * right

  __div: (left, right) ->
    if type(left) == "number"
      error "vector division undefined"

    Vec2d left[1] / right, left[2] / right

  __add: (other) =>
    Vec2d self[1] + other[1], self[2] + other[2]

  __sub: (other) =>
    Vec2d self[1] - other[1], self[2] - other[2]

  __tostring: =>
    ("vec2d<%f, %f>")\format self[1], self[2]

class Box
  self.from_pt = (x1, y1, x2, y2) ->
    Box x1, y1, x2 - x1, y2 - y1

  new: (@x, @y, @w, @h) =>

  unpack: => @x, @y, @w, @h
  unpack2: => @x, @y, @x + @w, @y + @h

  pad: (amount) =>
    amount2 = amount * 2
    Box @x + amount, @y + amount, @w - amount2, @h - amount2

  pos: => @x, @y
  set_pos: (@x, @y) =>

  move: (x, y) =>
    @x += x
    @y += y

  move_center: (x,y) =>
    @x = x - @w / 2
    @y = y - @h / 2

  center: =>
    @x + @w / 2, @y + @h / 2

  touches_pt: (x, y) =>
    x1, y1, x2, y2 = @unpack2!
    x > x1 and x < x2 and y > y1 and y < y2

  touches_box: (o) =>
    x1, y1, x2, y2 = @unpack2!
    ox1, oy1, ox2, oy2 = o\unpack2!

    return false if x2 <= ox1
    return false if x1 >= ox2
    return false if y2 <= oy1
    return false if y1 >= oy2
    true

  contains_box: (o) =>
    x1, y1, x2, y2 = @unpack2!
    ox1, oy1, ox2, oy2 = o\unpack2!

    return false if ox1 <= x1
    return false if ox2 >= x2

    return false if oy1 <= y1
    return false if oy2 >= y2

    true

  -- is self left of box
  left_of: (box) =>
    self.x < box.x

  above_of: (box) =>
    self.y <= box.y + box.h

  draw: (color=nil) =>
    setColor color if color
    rectangle "fill", @unpack!

  outline: (color=nil) =>
    setColor color if color
    rectangle "line", @unpack!

  -- center to center vector
  vector_to: (other) =>
    x1, y1 = @center!
    x2, y2 = other\center!
    Vec2d x2 - x1, y2 - y1

  random_point: =>
    @x + random! * @w, @y + random! * @h

  shrink: (dx=1, dy=dx) =>
    hx = dx / 2
    hy = dy / 2

    w = @w - hx
    h = @h - hy

    error "box too small" if w < 0 or h < 0
    Box @x + hx, @y + hy, w, h

  __tostring: =>
    ("box<(%d, %d), (%d, %d)>")\format @unpack!

hash_pt = (x,y) -> "#{x}:#{y}"

class SetList
  new: => @contains = {}
  add: (item, value) =>
    return if @contains[item]
    @contains[item] = true
    self[#self+1] = value or item

class UniformGrid
  new: (@cell_size=10) =>
    @buckets = {}
    @values = {}

  clear: =>
    for _, bucket in pairs @buckets
      for k,v in pairs bucket
        bucket[k] = nil

    for k,v in pairs @values
      @values[k] = nil

  add: (box, value) =>
    for bucket, key in @buckets_for_box box, true
      bucket[#bucket + 1] = box

    @values[box] = value

  get_touching: (query_box) =>
    values = @values
    with SetList!
      for bucket in @buckets_for_box query_box
        for box in *bucket
          if query_box != box
            \add box, values[box] if box\touches_box query_box

  bucket_for_pt: (x,y, insert=false) =>
    x = _floor x / @cell_size
    y = _floor y / @cell_size
    key = hash_pt x, y
    b = @buckets[key]
    if not b and insert
      b = {}
      @buckets[key] = b
    b, key

  buckets_for_box: (box, insert=false) =>
    coroutine.wrap ->
      x1, y1, x2, y2 = box\unpack2!
      x, y = x1, y1
      while x < x2 + @cell_size
        y = y1
        while y < y2 + @cell_size
          b, k = @bucket_for_pt x, y, insert
          coroutine.yield b, k if b
          y += @cell_size
        x += @cell_size

