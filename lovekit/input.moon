
require "lovekit.geometry"

import keyboard from love

export *

movement_vector = (speed) ->
  vel = Vec2d 0, 0

  vel[1] = if keyboard.isDown "left"
    -1
  elseif keyboard.isDown "right"
    1
  else
    0

  vel[2] = if keyboard.isDown "down"
    1
  elseif keyboard.isDown "up"
    -1
  else
    0

  vel\normalized! * speed

