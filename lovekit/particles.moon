
{graphics: g} = love

import Sequence from require "lovekit.sequence"
import COLOR from require "lovekit.color"
import Vec2d from require "lovekit.geometry"
import ad_curve from require "lovekit.support"

-- emits @count particles over the course of @duration seconds
class Emitter extends Sequence
  y: 0 -- so it can be sorted *_*
  alive: true
  duration: 0.2
  count: 5

  new: (@world, @x, @y, @duration, @count, @make_particle, callback) =>
    count = @count
    dt = @duration / count
    super ->
      while count > 0
        count -= 1
        @add_particle!
        wait dt

      callback! if callback

  attach: (fn) =>
    @attached_fn = fn

  update: (dt) =>
    @attached_fn dt if @attached_fn
    super dt

  draw: =>

  make_particle: => error "implement me"

  add_particle: =>
    @world.particles\add @make_particle @x, @y

-- emits particles forever at @rate, can turn it off by setting .alive to false
class ForeverEmitter extends Emitter
  rate: 0.05
  new: (@world, @x, @y, @rate, @make_particle) =>
    Sequence.__init @, ->
      while true
        @add_particle!
        wait @rate

-- a 2d point
class Particle
  life: 1.0

  r: 255
  g: 255
  b: 255
  a: 1

  new: (@x, @y, @vel=Vec2d(0,0), @accel=Vec2d(0,0)) =>
    @life = @@life

  update: (dt) =>
    @life -= dt
    @vel\adjust unpack @accel * dt
    @x += @vel.x * dt
    @y += @vel.y * dt
    @life > 0

  p: => 1 - @life / @@life

  -- returns value from 1 to 0 when p is past `after`
  fade_out: (after=0.5) =>
    p = @p!
    if p > after
      1 - (p - after) / (1 - after)
    else
      1

  fade_in: (before=0.5) =>
    p = @p!
    if p < before
      p / before
    else
      1

  draw: =>

class PixelParticle extends Particle
  size: 2
  draw: =>
    half = @size/2
    COLOR\push @r, @g, @b, @a * 255
    g.rectangle "fill", @x - half, @y - half, @size, @size
    COLOR\pop!

class ImageParticle extends Particle
  dspin: 0
  dscale: 0

  w: 0
  h: 0

  sprite: nil
  quad: nil

  new: (...) =>
    super ...
    @spin = 0
    @scale = 1

  update: (dt, ...) =>
    @spin += dt * @dspin
    @scale += dt * @dscale
    super dt, ...

  draw: =>
    COLOR\pusha ad_curve(@p!, 0, 0.1, 0.5) * (@a * 255)
    g.push!
    g.translate @x, @y
    g.rotate @spin
    g.scale @scale, @scale

    if @quad
      @sprite\draw @quad, -@w/2, -@h/2
    else
      @sprite\draw -@w/2, -@h/2

    g.pop!
    COLOR\pop!

class TextParticle extends Particle
  dspin: 0
  dscale: 0
  color: {255,255,255}

  new: (@str, ...) =>
    super ...

    @spin = 0
    @scale = 1

    font = g.getFont!
    @w = font\getWidth @str
    @h = font\getHeight!

  update: (dt, ...) =>
    @spin += dt * @dspin
    @scale += dt * @dscale
    super dt, ...

  draw: =>
    COLOR\push @color[1], @color[2], @color[3], ad_curve(@p!, 0, 0.1, 0.5) * 255
    g.push!
    g.translate @x, @y
    g.rotate @spin
    g.scale @scale, @scale
    g.print @str, -@w/2, -@h/2
    g.pop!
    COLOR\pop!

class TextEmitter extends Emitter
  count: 1
  new: (@str, ...) =>
    super ...

  make_particle: (...) =>
    TextParticle @str, ...


{
  :Emitter
  :Particle
  :PixelParticle
  :ImageParticle
  :TextParticle
  :TextEmitter
  :ForeverEmitter
}
