
-- geometric primitives
import rectangle, line from love.graphics
import atan2, cos, sin, random, abs from math
import type, pairs, ipairs from _G

{ floor: _floor, ceil: _ceil, deg: _deg, rad: _rad } = math

import COLOR from require "lovekit.color"

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
  base = @__base
  @__base.__index = (name) =>
    if name == "x"
      @[1]
    elseif name == "y"
      @[2]
    else
      base[name]

  getmetatable(@).__call = do
    import __base from @
    (cls, x,y) -> setmetatable {x or 0, y or 0}, __base

  @from_angle: (deg) ->
    theta = _rad deg
    Vec2d cos(theta), sin(theta)

  @from_radians: (rads) ->
    Vec2d cos(rads), sin(rads)

  @random: (mag=1) ->
    vec = Vec2d.from_angle random! * 360
    vec * mag

  angle: => _deg atan2 self[2], self[1]
  radians: => atan2 @[2], @[1]

  len: =>
    n = self[1]^2 + self[2]^2
    return 0 if n == 0
    math.sqrt n

  -- shink to len if longer
  cap: (len) =>
    _len = @len!
    if _len > len
      @[1] = @[1] / _len * len
      @[2] = @[2] / _len * len

    @

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

  direction_name: do
    _direction_names = {"up", "right", "down", "left"}
    (names=_direction_names) =>
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

  -- rotate randomly -spread/2 to spread/2 degrees
  random_heading: (spread=10, r=random!) =>
    offset = (r - 0.5) * spread
    @rotate _rad offset

  -- converts to closest axis aligned unit vector
  primary_direction: =>
    {x, y} = @
    if x == 0 and y == 0
      return Vec2d 0, 0

    xx = math.abs x
    yy = math.abs y

    if xx > yy
      if x < 0
        Vec2d -1, 0
      else
        Vec2d 1, 0
    else
      if y < 0
        Vec2d 0, -1
      else
        Vec2d 0, 1


  __mul: (left, right) ->
    if type(left) == "number"
      Vec2d left * right[1], left * right[2]
    else
      if type(right) != "number"
        left[1] * right[1] + left[2] * right[2]
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

  dup: => Box @unpack!

  pad: (amount) =>
    amount2 = amount * 2
    Box @x + amount, @y + amount, @w - amount2, @h - amount2

  pos: => @x, @y
  set_pos: (@x, @y) =>

  move: (x, y) =>
    @x += x
    @y += y
    @

  move_center: (x,y) =>
    @x = x - @w / 2
    @y = y - @h / 2
    @

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
    if color
      COLOR\push unpack color

    rectangle "fill", @unpack!

    if color
      COLOR\pop!

  outline: (color=nil) =>
    if color
      COLOR\push unpack color

    rectangle "line", @unpack!

    if color
      COLOR\pop!

  -- center to center vector
  vector_to: (other) =>
    x1, y1 = @center!
    x2, y2 = other\center!
    Vec2d x2 - x1, y2 - y1

  random_point: =>
    @x + random! * @w, @y + random! * @h

  -- make sure width and height aren't negative
  fix: =>
    x,y,w,h = @unpack!

    if w < 0
      x += w
      w = -w

    if h < 0
      y += h
      h = -h

    Box x,y,w,h

  scale: (sx=1, sy=sx, center=false) =>
    scaled = Box @x, @y, @w * sx, @h * sy
    scaled\move_center @center! if center
    scaled

  -- change size of w and h, preserving center
  shrink: (dx=1, dy=dx) =>
    hx = dx / 2
    hy = dy / 2

    w = @w - dx
    h = @h - dy

    error "box too small" if w < 0 or h < 0
    Box @x + hx, @y + hy, w, h

  -- make this box bigger such that the box now will contain both boxes
  add_box: (other) =>
    if @w == 0 or @h == 0
      @x,@y,@w,@h = other\unpack!
    else
      x1,y1,x2,y2 = @unpack2!
      ox1, oy1, ox2, oy2 = other\unpack2!
      x1 = math.min x1, ox1
      y1 = math.min y1, oy1
      x2 = math.max x2, ox2
      y2 = math.max x2, oy2

      @x = x1
      @y = y1
      @w = x2 - x1
      @h = y2 - y1

    nil

  -- create texture coordinate from two boxes
  __div: (left, right) ->
    assert left and left.__class == Box and right and right.__class == Box

    Box (left.x - right.x) / right.w,
      (left.y - right.y) / right.h,
      left.w / right.w,
      left.h / right.h

  __tostring: =>
    ("box<(%.2f, %.2f), (%.2f, %.2f)>")\format @unpack!

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

  draw: =>
    for box in pairs @values
      Box.draw box

  clear: =>
    for _, bucket in pairs @buckets
      for k,v in pairs bucket
        bucket[k] = nil

    for k,v in pairs @values
      @values[k] = nil

  add: (box, value=box) =>
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

  get_touching_pt: (x, y) =>
    bucket = @bucket_for_pt x, y
    return unless bucket

    values = @values
    list = with SetList!
      for box in *bucket
        if box\touches_pt x, y
          \add box, values[box]

    list if next list


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


class Selector
  cursor_size: 3
  color: {255,100,100, 100}

  new: (@viewport) =>

  update_mouse: =>
    @mx, @my = @viewport\unproject love.mouse.getPosition!

    @mx = math.floor @mx
    @my = math.floor @my

  draw_cursor: =>
    love.mouse.setVisible false
    x,y = @mx, @my
    return unless x and y

    --- draw curosr
    Box(x, y - @cursor_size, 1, @cursor_size)\draw {255,255,255}
    Box(x, y+1, 1, @cursor_size)\draw {255,255,255}

    Box(x - @cursor_size, y, @cursor_size, 1)\draw {255,255,255}
    Box(x+1, y, @cursor_size, 1)\draw {255,255,255}

class BoxSelector extends Selector
  draw: =>
    @draw_cursor!

    if @current
      @current\draw @color

  update: (dt) =>
    @update_mouse!

    if not @current and love.mouse.isDown "l"
      @current = Box @mx, @my, 1, 1

    if @current and not love.mouse.isDown "l"
      print @current\fix!
      @current = nil

    if @current
      @current.w = @mx - @current.x
      @current.h = @my - @current.y

    true


class VectorSelector extends Selector
  draw: =>
    @draw_cursor!

    if @origin
      COLOR\push unpack @color
      line @origin[1], @origin[2], @mx, @my
      COLOR\pop!

  update: (dt) =>
    @update_mouse!

    if not @origin and love.mouse.isDown "l"
      @origin = Vec2d(@mx, @my)

    if @origin and not love.mouse.isDown "l"
      v = Vec2d(@mx - @origin[1], @my - @origin[2])
      print "Vec:", v, "Dir:", v\normalized!
      @dest = nil
      @origin = nil

    true

{
  :floor, :ceil, :hash_pt

  :Vec2d
  :Box
  :UniformGrid
  :SetList

  :Selector
  :BoxSelector
  :VectorSelector
}

