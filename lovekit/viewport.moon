
require "lovekit.geometry"
require "lovekit.effects"

import graphics from love
import effects from lovekit

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
    graphics.push!
    @scale! if scale
    graphics.translate -@x, -@y

  pop: =>
    graphics.pop!

  unproject: (x,y) =>
    x, y = x / @screen.scale, y / @screen.scale
    @x + x, @y + y

  project: (x,y) =>
    x, y = x * @screen.scale, y * @screen.scale
    x - @x, y - @y

  center_on_pt: (cx, cy, map_box) =>
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


  center_on: (thing, map_box) =>
    @center_on_pt thing\center!

  on_bottom: (size, margin=0) =>
    @h - (size + margin)

  on_right: (size, margin=0) =>
    @w - (size + margin)

class EffectViewport extends Viewport
  new: (...) =>
    @effects = EffectList!
    super ...

  shake: (dur=0.4) =>
    @effects\add effects.ViewportShake dur

  update: (dt) => @effects\update dt

  apply: =>
    super!
    e\before @obj for e in *@effects

  pop: =>
    e\after @obj for e in *@effects
    super!

class TiledBackground
  new: (image, viewport) =>
    @ox = 0
    @oy = 0

    @img = with imgfy image
      \set_wrap "repeat", "repeat"

    @tile_w, @tile_h = @img\width!, @img\height!
    @quad = graphics.newQuad 0,0,
      viewport.screen.w + @tile_w,
      viewport.screen.h + @tile_h,
      @tile_w, @tile_h

  draw: (ox, oy)=>
    @ox = ox if ox
    @oy = oy if oy

    ox = @ox % @tile_w
    oy = @oy % @tile_h
    @img\drawq @quad, -ox, -oy

nil

