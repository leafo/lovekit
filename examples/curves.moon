
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
      graphics.points x * @w, y * @h

    graphics.pop!

  update: (dt) => true

class Thing extends Box
  new: (@walker, ...) =>
    super ...

  update: (dt) =>
    @x, @y = @walker\update dt

  draw: =>
    super { 100, 255, 100, 128 }

->
  path = CatmullRomPath!
  thing = nil

  love.draw = ->
    path\draw!
    if thing
      thing\draw!

  love.update = (dt) ->
    if thing
      thing\update dt

  love.mousepressed = (x,y) ->
    path\add x,y
    if #path >= 4
      thing = Thing path\walker(200), 0,0, 10, 10

  love.keypressed = (key) ->
    if key == "escape"
      love.event.quit!

    if key == "backspace"
      path\pop!
      thing = nil


