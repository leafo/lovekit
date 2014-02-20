
require "lovekit.geometry"

import keyboard from love
import insert from require "table"

table_table = ->
  setmetatable {}, __index: (key) =>
    with new = {}
      @[key] = new

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

-- c = Controller {
--   confirm: "x"
--   confirm: {"x", "y"}
--
--   confirm: {
--     keyboard: "x"
--   }
--
--   confirm: {
--     keyboard: {"x", "y"}
--   }
--
--
-- }, joystick

class Controller
  @next_joystick: 1

  new: (mapping, @joystick) =>
    if @joystick == "auto"
      error "automatically get joystick"

    @add_mapping mapping

  add_mapping: (mapping) =>
    @key_mapping or= table_table!
    @joy_mapping or= table_table!

    for name, inputs in pairs mapping
      if type(inputs) == "string"
        table.insert @key_mapping[name], inputs
        continue

      for key in *inputs
        insert @key_mapping[name], key

      if extra_keys = inputs.keyboard
        if type(extra_keys) == "table"
          for key in *extra_keys
            insert @key_mapping[name], key
        else
          insert @key_mapping[name], extra_keys

      if joy_buttons = inputs.joystick
        if type(joy_buttons) == "table"
          for btn in *joy_buttons
            insert @joy_mapping[name], btn
        else
          insert @joy_mapping[name], joy_buttons

    @joy_mapping = nil unless next @joy_mapping

  is_down: (name, ...) =>
    if keys = @key_mapping[name]
      pressed = keyboard.isDown unpack keys
      return true if pressed

    if btns = @joy_mapping and @joy_mapping[name]
      pressed = @joystick\isDown unpack btns
      return true if pressed

    if ...
      @is_down ...
    else
      false

  movement_vector: =>
  wait_for: =>

