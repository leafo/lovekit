
{graphics: g} = love

export *

class Emitter extends Sequence
  y: 0 -- so it can be sorted *_*
  alive: true

  new: (@world, x, y, duration=0.2, count=5, @make_particle, callback) =>
    dt = duration / count
    super ->
      while count > 0
        count -= 1
        @world.particles\add @make_particle x,y
        wait dt

      callback! if callback

  draw: =>
  make_particle: => error "implement me"


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

  draw: =>

class PixelParticle extends Particle
  size: 2
  draw: =>
    half = @size/2
    g.setColor @r, @g, @b, @a * 255
    g.rectangle "fill", @x - half, @y - half, @size, @size
