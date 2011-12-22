
require "geometry"

export *

-- something with a @box that moves around in the world
class Entity
  w: 20
  h: 20

  new: (@world, x, y) =>
    @facing = "right"
    @on_ground = false
    @velocity = Vec2d 0, 0
    @box = Box x, y, @w, @h

  update: (dt) =>
    @velocity += @world.gravity * dt
    cx, cy = @fit_move unpack @velocity * dt

    -- platformer physics
    if cy
      if @velocity[2] > 0
        @on_ground = true
      @velocity[2] = 0
    else
      if math.floor(@velocity[2] * dt) != 0
        @on_ground = false

    true

  loc: => Vec2d @box.x, @box.y

  fit_move: (dx, dy) =>
    collided_x = false
    collided_y = false

    @facing = "right" if dx > 0
    @facing = "left" if dx < 0

    dx = math.floor dx
    dy = math.floor dy
    if dx != 0
      ddx = dx < 0 and -1 or 1
      @box.x += dx
      while @world\collides self
        collided_x = true
        @box.x -= ddx

    if dy != 0
      ddy = dy < 0 and -1 or 1
      @box.y += dy
      while @world\collides self
        collided_y = true
        @box.y -= ddy

    collided_x, collided_y


