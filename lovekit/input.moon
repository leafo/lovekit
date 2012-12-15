
require "lovekit.geometry"

import keyboard from love

export *

make_mover = (up, down, left, right) ->
  (speed) ->
    vel = Vec2d 0, 0

    vel[1] = if keyboard.isDown left
      -1
    elseif keyboard.isDown right
      1
    else
      0

    vel[2] = if keyboard.isDown down
      1
    elseif keyboard.isDown up
      -1
    else
      0

    out = vel\normalized!
    out = out * speed if speed
    out

movement_vector = make_mover "up", "down", "left", "right"
