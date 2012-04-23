
require "lovekit.geometry"

export *

class Entity
  w: 20
  h: 20

  loc: => Vec2d @box.x, @box.y

  new: (@world, x, y) =>
    @box = Box x, y, @w, @h
    @velocity = Vec2d 0, 0

  draw: =>
    @box\draw!

  update: (dt) =>
    @fit_move unpack @velocity * dt
    -- @box\move unpack @velocity * dt

  on_stuck: => print "on_stuck: " .. @@__name

  fit_move: (dx, dy) =>
    collided_x = false
    collided_y = false

    -- if you are collided before you move then the world changed, PANIC
    if @world\collides self
      return @on_stuck!

    -- x
    if dx > 0
      start = @box.x
      @box.x += dx
      if @world\collides self
        @box.x = floor @box.x
        while @world\collides self
          collided_x = true
          @box.x -= 1
    elseif dx < 0
      start = @box.x
      @box.x += dx
      if @world\collides self
        @box.x = ceil @box.x
        while @world\collides self
          collided_x = true
          @box.x += 1
 
    -- y
    if dy > 0
      start = @box.y
      @box.y += dy
      if @world\collides self
        @box.y = floor @box.y
        while @world\collides self
          collided_y = true
          @box.y -= 1
    elseif dy < 0
      start = @box.y
      @box.y += dy
      if @world\collides self
        @box.y = ceil @box.y
        while @world\collides self
          collided_y = true
          @box.y += 1

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

