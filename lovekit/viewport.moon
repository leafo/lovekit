
require "lovekit.geometry"

import graphics from love

export *

class Viewport extends Box
  self.build_screen = (scale=2) ->
    {
      w: graphics.getWidth! / scale
      h: graphics.getHeight! / scale
      scale: scale
    }

  -- screen is table with w, h, and scale
  new: (opts={}) =>
    @screen = if opts.screen
      opts.screen
    else
      Viewport.build_screen opts.scale

    super 0,0, @screen.w, @screen.h

  update: (dt) => -- animations: screen shake, screen zoom

  bigger: =>
    x,y,w,h = @unpack!
    Box x - w/2, y - h/2, w*2,h*2

  scale: =>
    s = @screen.scale
    graphics.scale s, s

  apply: (scale=true)=>
    @scale! if scale
    graphics.translate -@x, -@y

  pop: =>
    graphics.translate @x, @y -- go back to where we were

  unproject: (x,y) =>
    x, y = x / @screen.scale, y / @screen.scale
    @x + x, @y + y

  center_on: (thing, map_box) =>
    cx, cy = thing.box\center!

    @x = cx - @w / 2
    @y = cy - @h / 2

    if map_box
      x1, y1, x2, y2 = map_box\unpack2!

      @x = x1 if @x < x1
      @y = y1 if @y < y1

      max_x = x2 - @w
      max_y = y2 - @h

      @x = max_x if @x > max_x
      @y = max_y if @y > max_y

