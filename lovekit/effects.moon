
module "lovekit.effects", package.seeall

import graphics from love

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
  new: (duration, @amount) =>
    super duration

  before: =>
    t = @p!

    graphics.push!
    decay = (1 - t) * 2
    graphics.translate decay * math.sin(t*10), decay * math.cos(t*11)

  after: =>
    graphics.pop!


