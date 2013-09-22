
require "lovekit.all"

import graphics from love

local *

class Graph extends Box
  new: (@fn, opts={}) =>
    @min_t = opts.min_t or 0
    @max_t = opts.max_t or 1

    @x = opts.x or 10
    @y = opts.y or 10

    @w = opts.w or 200
    @h = opts.h or 200

  draw: (x, y) =>
    @x = x if x
    @y = y if y

    graphics.push!
    graphics.translate @x, @y + @h
    graphics.scale 1, -1
    
    COLOR\push 100, 100, 100
    graphics.line 0,0, 0, @h
    graphics.line 0,0, @w, 0
    COLOR\pop!

    fn = @fn
    step = (@max_t - @min_t) / (@w / 2)

    for t = @min_t, @max_t, step
      y = fn(t)
      x = t / @max_t
      graphics.point x * @w, y * @h

    graphics.pop!

  update: (dt) => true

h00 = (t, t2, t3) ->
  2 * t3 - 3 * t2 + 1

h10 = (t, t2, t3) ->
  t3 - 2 * t2 + t

h01 = (t, t2, t3) ->
  -2 * t3 + 3 * t2

h11 = (t, t2, t3) ->
  t3 - t2

hermite_interpolate = (p1, p2, m1, m2, t) ->
  t2 = t * t
  t3 = t2 * t

  p1 * h00(t, t2, t3) + m1 * h10(t, t2, t3) + p2 * h01(t, t2, t3) + m2 * h11(t, t2, t3)


-- follows a point list
class PathWalker
  new: (@points, @speed) =>
    @reset!

  reset: (@i=1, @t=0) =>
    return false unless @points[@i + 3]

    @p1 = Vec2d unpack @points[@i + 1]
    @p2 = Vec2d unpack @points[@i + 2]

    @duration = math.abs((@p2 - @p1)\len!)
    @x, @y = unpack @p1
    true

  update: (dt) =>
    @t += dt * @speed

    local p
    while true
      p = @t / @duration
      break if p <= 1
      unless @reset @i + 1, @t - @duration
        print "Finished"
        @reset!

    @x, @y = unpack @points\interpolate @i + 1, p
    @x, @y

class PointList
  new: =>

  add: (x,y) =>
    table.insert @, {x,y}

  pop: =>
    @[#@] = nil

  -- draw pair with catmull-rom
  -- draw p(i) -> p(i+1), p(i-1) and p(i+2) must be defined
  draw_pair: (i) =>
    p1,p2, m1,m2 = @interpolation_parts(i)
    d = math.abs (p2 - p1)\len! / 10

    for t=0, 1, 1/d
      graphics.point unpack hermite_interpolate(p1, p2, m1, m2, t)

  -- calculate the parts needed for hermite interpolation using catmull-rom
  interpolation_parts: (i) =>
    p0 = Vec2d unpack @[i - 1]
    p1 = Vec2d unpack @[i]
    p2 = Vec2d unpack @[i + 1]
    p3 = Vec2d unpack @[i + 2]

    -- calcualte tangent
    m1 = (p2 - p0) * 0.5
    m2 = (p3 - p1) * 0.5

    p1, p2, m1, m2

  -- returns vec2
  interpolate: (i, t) =>
    p1, p2, m1, m2 = @interpolation_parts(i)
    hermite_interpolate(p1, p2, m1, m2, t)

  walker: (speed) =>
    PathWalker @, speed

  draw: =>
    pt = graphics.getPointSize!

    graphics.setPointSize 4

    if #@ >= 4
      COLOR\push 255,100,100
      for i=2,#@ - 2
        @draw_pair(i)
      COLOR\pop!

    for {x,y} in *@
      graphics.point x, y

    graphics.setPointSize pt



class Thing extends Box
  new: (@walker, ...) =>
    super ...

  update: (dt) =>
    @x, @y = @walker\update dt

  draw: =>
    super { 100, 255, 100, 128 }

->
  wrap = (h) ->
    (t) ->
      t2 = t * t
      t3 = t2 * t
      h t, t2, t3

  g1 = Graph wrap(h00)
  g2 = Graph wrap(h10)

  g3 = Graph wrap(h01)
  g4 = Graph wrap(h11)

  points = PointList!
  thing = nil

  love.draw = ->
    g1\draw 10, 10
    g2\draw 10, 10 + 210

    g3\draw 10 + 210, 10
    g4\draw 10 + 210, 10 + 210

    points\draw!
    if thing
      thing\draw!

  love.update = (dt) ->
    if thing
      thing\update dt

  love.mousepressed = (x,y) ->
    points\add x,y
    if #points >= 4
      thing = Thing points\walker(200), 0,0, 10, 10

  love.keypressed = (key) ->
    if key == "escape"
      love.event.quit!

    if key == "backspace"
      points\pop!
      thing = nil


