
-- collision stuff

import rectangle, setColor from love.graphics
import rad, atan2, cos, sin from math

export *

_floor, _ceil = math.floor, math.ceil

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

  angle: =>
    math.deg atan2 self[2], self[1]

  new: (x=0, y=0) =>
    self[1] = x
    self[2] = y

  len: =>
    n = self[1]^2 + self[2]^2
    return 0 if n == 0
    math.sqrt n

  is_zero: => self[1] == 0 and self[2] == 0

  left: => return self[1] < 0
  right: => return self[1] > 0

  update: (x, y) =>
    self[1], self[2] = x, y

  normalized: =>
    len = @len!
    if len == 0
      Vec2d!
    else
      Vec2d self[1] / len, self[2] / len

  truncate: (max_len) =>
    l = @len!
    if l > max_len
      self[1] = self[1] / l * max_len
      self[2] = self[2] / l * max_len

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

  __tostring: =>
    ("box<(%d, %d), (%d, %d)>")\format @unpack!

hash_pt = (x,y) ->
  tostring(x)..":"..tostring(y)

class SetList
  new: => @contains = {}
  add: (item) =>
    return if @contains[item]
    @contains[item] = true
    self[#self+1] = item

class UniformGrid
  new: (@cell_size=10) =>
    @buckets = {}

  add: (box) =>
    for bucket, key in @buckets_for_box box, true
      table.insert bucket, box

  get_candidates: (query) =>
    with SetList!
      for bucket in @buckets_for_box query
        for box in *bucket
          \add box

  bucket_for_pt: (x,y, insert=false) =>
    x = math.floor x / @cell_size
    y = math.floor y / @cell_size
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

