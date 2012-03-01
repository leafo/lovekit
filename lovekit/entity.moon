
require "lovekit.geometry"

floor = (n) ->
  if n < 0
    -math.floor -n
  else
    math.floor n

export *

class Entity
  w: 20
  h: 20

  loc: => Vec2d @box.x, @box.y

  new: (@world, x, y) =>
    @facing = "right"
    @box = Box x, y, @w, @h
    @velocity = Vec2d 0, 0

  draw: =>
    @box\draw!

  update: (dt) =>
    @fit_move unpack @velocity * dt

  fit_move: (dx, dy) =>
    collided_x = false
    collided_y = false

    -- x
    if dx > 0
      start = @box.x
      @box.x += dx
      while @world\collides self
        collided_x = true
        @box.x -= 1
        if @box.x <= start
          @box.x = start
          break
    elseif dx < 0
      start = @box.x
      @box.x += dx
      while @world\collides self
        collided_x = true
        @box.x += 1
        if @box.x >= start
          @box.x = start
          break
 
    if dy > 0
      start = @box.y
      @box.y += dy
      while @world\collides self
        collided_y = true
        @box.y -= 1
        if @box.y <= start
          @box.y = start
          break
    elseif dy < 0
      start = @box.y
      @box.y += dy
      while @world\collides self
        collided_y = true
        @box.y += 1
        if @box.y >= start
          @box.y = start
          break

    collided_x, collided_y

-- something with a @box that moves around in the world
class PlatformEntity extends Entity
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

