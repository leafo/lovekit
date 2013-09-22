
require "lovekit.all"

import graphics from love

class Graph extends Box

  new: (@fn, opts={}) =>
    @min_t = opts.min_t or 0
    @max_t = opts.max_t or 1

    @x = opts.x or 10
    @y = opts.y or 10

    @w = opts.w or 200
    @h = opts.h or 200

  draw: =>
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

->
  -- g = Graph (t) ->
  --   t2 = t * t
  --   t3 = t2 * t
  --   h00 t, t2, t3

  g = Graph ((t) -> math.sin(t)), max_t: math.pi*2, w: 400

  love.draw = ->
    g\draw!

