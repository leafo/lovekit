
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

joystick_deadzone_normalize = (vec, amount=.2) ->
  x, y = unpack vec
  len = vec\len!
  new_len = if len < amount
    0
  else
    math.min 1, (len - amount) / (1 - amount)

  Vec2d x/len * new_len, y/len * new_len


make_joystick_mover = (i=1, xaxis="leftx", yaxis="lefty") ->
  joystick = assert love.joystick.getJoysticks![i], "Missing joystick"

  (speed) ->
    x = joystick\getGamepadAxis xaxis
    y = joystick\getGamepadAxis yaxis
    vec = joystick_deadzone_normalize Vec2d(x,y)
    vec = vec * speed if speed
    vec


