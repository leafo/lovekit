
import graphics from love

import Vec2d from require "lovekit.geometry"
import COLOR from require "lovekit.color"

hermite_interpolate = do
  h00 = (t, t2, t3) ->
    2 * t3 - 3 * t2 + 1

  h10 = (t, t2, t3) ->
    t3 - 2 * t2 + t

  h01 = (t, t2, t3) ->
    -2 * t3 + 3 * t2

  h11 = (t, t2, t3) ->
    t3 - t2

  (p1, p2, m1, m2, t) ->
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

class CatmullRomPath
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

  each_pt: (rate=1) =>
    return unless #@ >= 4
    coroutine.wrap ->
      for i=2,#@ - 2
        p1,p2, m1,m2 = @interpolation_parts(i)
        d = math.abs (p2 - p1)\len! / 10
        for t=0, 1, 1/d * rate
          coroutine.yield unpack hermite_interpolate(p1, p2, m1, m2, t)

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


{
  :hermite_interpolate
  :PathWalker
  :CatmullRomPath
}
