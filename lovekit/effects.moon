
import graphics, timer from love

import Sequence from require "lovekit.sequence"
import COLOR from require "lovekit.color"

class Effect
  new: (@duration=1, @callback) =>
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
  before: (object) =>
  after: (object) =>

class ScaleEffect extends Sequence
  before: (object) =>
    tx, ty = object\center!

    graphics.push!
    graphics.translate tx, ty
    graphics.scale @scale, @scale
    graphics.translate -tx, -ty

  after: (object) =>
    graphics.pop!

class PopinEffect extends ScaleEffect
  scale: 0
  new: (duration, callback) =>
    super ->
      tween @, duration * 0.8, scale: 1.2
      tween @, duration * 0.2, scale: 1
      callback and callback @

class BlowOutEffect extends Sequence
  scale: 1
  alpha: 255

  new: (duration, callback) =>
    super ->
      tween @, duration, scale: 2.0, alpha: 0
      callback and callback @

  before: (object) =>
    COLOR\pusha @alpha
    ScaleEffect.before @, object

  after: (object) =>
    ScaleEffect.after @, object
    COLOR\pop!

class ShakeEffect extends Effect
  new: (duration, @speed=5, @amount=1, ...) =>
    @start = timer.getTime!
    @rand = love.math.random! * math.pi
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


class FadeInEffect extends Effect
  before: =>
    COLOR\pusha @p! * 255

  after: =>
    COLOR\pop!

class FadeOutEffect extends Effect
  before: =>
    COLOR\pusha (1 - @p!) * 255

  after: =>
    COLOR\pop!

{ :Effect, :ShakeEffect, :ColorEffect, :FlashEffect, :PopinEffect, :FadeInEffect, :FadeOutEffect, :BlowOutEffect }
