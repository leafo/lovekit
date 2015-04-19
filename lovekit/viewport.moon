
require "lovekit.geometry"
require "lovekit.effects"

import graphics from love

import Box from require "lovekit.geometry"
import imgfy from require "lovekit.image"
import EffectList from require "lovekit.lists"
import ShakeEffect from require "lovekit.effects"

import smooth_approach from require "lovekit.support"

-- x,y,w,h are in game coordinate space
class Viewport extends Box
  x: 0
  y: 0
  scale: 1

  offset_x: 0
  offset_y: 0

  crop: false

  pixel_scale: false

  -- screen is table with w, h, and scale
  new: (opts={}) =>
    screen_w, screen_h = graphics.getWidth!, graphics.getHeight!
    @pixel_scale = opts.pixel_scale

    if opts.scale
      @scale = opts.scale
      @w = screen_w / @scale
      @h = screen_h / @scale
      return

    -- got size, figure out scale and offset
    if opts.w and opts.h
      @w = opts.w
      @h = opts.h

      margin = opts.margin or 0

      margin_x, margin_y = if margin > 0 and margin < 1
        math.floor(screen_w * margin), math.floor(screen_h * margin)
      else
        margin, margin

      scale_x = (screen_w - margin_x) / @w
      scale_y = (screen_h - margin_y) / @h

      @scale = math.min scale_x, scale_y

      real_w = @w * @scale
      real_h = @h * @scale

      @offset_x = math.floor (screen_w - real_w)/ 2
      @offset_y = math.floor (screen_h - real_h)/ 2

      @crop = true

      return

    error "don't know how to create viewport"

  update: (dt) => -- animations: screen shake, screen zoom

  bigger: =>
    x,y,w,h = @unpack!
    Box x - w/2, y - h/2, w*2,h*2

  apply: (scale=true)=>
    if @pixel_scale
      unless @canvas
        @canvas = graphics.newCanvas @w, @h
        @canvas\setFilter "nearest", "nearest"

      @last_canvas = graphics.getCanvas!
      graphics.setCanvas @canvas

      @canvas\clear 0,0,0,0
      graphics.push!
      graphics.translate -@x, -@y
      return

    if @crop
      s = @scale
      graphics.setScissor @offset_x, @offset_y, @w * s, @h * s

    graphics.push!

    graphics.translate @offset_x, @offset_y

    if s = @scale
      graphics.scale s, s

    graphics.translate -@x, -@y

  pop: =>
    if @pixel_scale
      graphics.pop!

      if @last_canvas
        graphics.setCanvas @last_canvas
      else
        graphics.setCanvas!

      graphics.push!
      graphics.setBlendMode "premultiplied"
      graphics.draw @canvas, 0, 0, 0, @scale, @scale
      graphics.setBlendMode "alpha"
      graphics.pop!
      return

    graphics.pop!

    if @crop
      graphics.setScissor!

  -- screen coords -> viewport coords
  unproject: (x,y) =>
    (x - @offset_x) / @scale + @x, (y - @offset_y) / @scale + @y

  -- viewport cords -> screen cords
  project: (x,y) =>
    (x - @x) * @scale + @offset_x, (y - @y) * @scale + @offset_y

  center_on_pt: (cx, cy, map_box, dt) =>
    tx = cx - @w / 2 -- target
    ty = cy - @h / 2

    if dt
      @x = smooth_approach @x, tx, dt * @w / 100
      @y = smooth_approach @y, ty, dt * @w / 100
    else -- go there instantly
      @x = tx
      @y = ty

    if map_box
      x1, y1, x2, y2 = map_box\unpack2!

      @x = x1 if @x < x1
      @y = y1 if @y < y1

      max_x = x2 - @w
      max_y = y2 - @h

      @x = max_x if @x > max_x
      @y = max_y if @y > max_y

  center_on: (thing, ...) =>
    dx, dy = if thing.looking_at
      thing\looking_at @
    else
      thing\center!

    @center_on_pt dx,dy, ...

  on_bottom: (size, margin=0) =>
    @h - (size + margin)

  on_right: (size, margin=0) =>
    @w - (size + margin)

  -- relative to viewport position
  left: (offset=0) =>
    offset

  right: (offset=0) =>
    @w - offset

  top: (offset=0) =>
    offset

  bottom: (offset=0) =>
    @h - offset

  __tostring: =>
    ("viewport<(%d, %d), (%d, %d)>")\format @unpack!

class EffectViewport extends Viewport
  __tostring: Viewport.__tostring

  new: (...) =>
    @effects = EffectList!
    super ...

  shake: (dur=0.4, ...) =>
    @effects\add ShakeEffect dur, ...

  update: (dt) => @effects\update dt

  apply: =>
    super!
    e\before! for e in *@effects

  pop: =>
    e\after! for e in *@effects
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
    @img\draw @quad, -ox, -oy


{
  :Viewport
  :EffectViewport
  :TiledBackground
}
