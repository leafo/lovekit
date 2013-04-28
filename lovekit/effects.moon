
require "lovekit.sequence"

module "lovekit.effects", package.seeall

import graphics from love

{:timer} = love

export ^

class Effect
  new: (@duration) =>
    @time = 0

  -- return true if alive
  update: (dt) =>
    @time += dt
    @time < @duration

  p: => math.min 1, @time / @duration

  -- called when effect is replaced by new one of same type
  replace: (other) =>

  -- implement these in subclasses
  before: =>
  after: =>

-- for the viewport
class ViewportShake extends Effect
  new: (duration, @speed=5, @amount=1) =>
    @start = timer.getTime!
    @rand = math.random! * math.pi
    super duration

  before: =>
    p = @p!
    t = (timer.getTime! - @start) * @speed

    graphics.push!
    decay = (1 - p) * 2
    graphics.translate @amount * decay * math.sin(t*10 + @rand),
      @amount * decay * math.cos(t*11 + @rand)

  after: =>
    graphics.pop!

class ColorEffect extends Sequence
  new: (...) =>
    super ...
    @tmp_color = {}

  replace: (other) =>

  before: =>
    @tmp_color[1], @tmp_color[2], @tmp_color[3] = graphics.getColor!
    graphics.setColor unpack @color if @color

  after: =>
    graphics.setColor @tmp_color

class Flash extends ColorEffect
  new: (duration=0.2, color={255,100,100}) =>
    half = duration/2
    super ->
      start = {graphics.getColor!}
      @color = {unpack start}
      tween @color, half, color
      tween @color, half, start

nil

