
import graphics, timer from love

import Sequence from require "lovekit.sequence"
import COLOR from require "lovekit.color"

class Effect
  new: (@duration, @callback) =>
    @time = 0

  -- return true if alive
  update: (dt) =>
    @time += dt
    with alive = @time < @duration
      if not alive and @callback
        @callback @
        @callback = nil

  p: => math.min 1, @time / @duration

  -- called when effect is replaced by new one of same type
  replace: (other) =>

  -- implement these in subclasses
  before: =>
  after: =>

class ShakeEffect extends Effect
  new: (duration, @speed=5, @amount=1, ...) =>
    @start = timer.getTime!
    @rand = math.random! * math.pi
    super duration, ...

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
  replace: (other) =>

  before: =>
    if @color
      COLOR\push unpack @color

  after: =>
    if @color
      COLOR\pop!

  update: (...) =>
    with alive = super ...
      if not alive and @callback
        @callback @
        @callback = nil

class FlashEffect extends ColorEffect
  new: (duration=0.2, color={255,100,100}, @callback) =>
    half = duration/2
    super ->
      start = {graphics.getColor!}
      @color = {unpack start}
      tween @color, half, color
      tween @color, half, start


{ :Effect, :ShakeEffect, :ColorEffect, :FlashEffect }
