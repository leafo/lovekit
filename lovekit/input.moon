
require "lovekit.geometry"

import keyboard, timer from love
import insert from table
import unpack from _G

import Vec2d from require "lovekit.geometry"

-- mapping for pink thing
if love and love.joystick
  with guid = "030000006f0e00001f01000000010000"
    love.joystick.setGamepadMapping guid, "leftx", "axis", 1
    love.joystick.setGamepadMapping guid, "lefty", "axis", 2

table_table = ->
  setmetatable {}, __index: (key) =>
    with new = {}
      @[key] = new

make_mover = (up, down, left, right) ->
  up = {up} unless type(up) == "table"
  down = {down} unless type(down) == "table"
  left = {left} unless type(left) == "table"
  right = {right} unless type(right) == "table"

  (speed) ->
    vel = Vec2d 0, 0

    vel[1] = if keyboard.isDown unpack left
      -1
    elseif keyboard.isDown unpack right
      1
    else
      0

    vel[2] = if keyboard.isDown unpack down
      1
    elseif keyboard.isDown unpack up
      -1
    else
      0

    out = vel\normalized!
    out = out * speed if speed
    out

movement_vector = make_mover "up", "down", "left", "right"

joystick_deadzone_normalize = (vec, min_amount=.2, max_amount=0.95) ->
  x, y = unpack vec
  len = vec\len!

  new_len = if len < min_amount
    0
  elseif len > max_amount
    1
  else
    math.min 1, (len - min_amount) / (max_amount - min_amount)

  out = Vec2d x/len * new_len, y/len * new_len

  -- snap to a near angle
  -- TODO: support 45 degree angles as well
  if new_len != 0
    primary = out\primary_direction!
    dot = primary * out
    -- close enough, lock to axis aligned direction
    if dot > 0.95
      if new_len == 1
        out = primary
      else
        out = primary * new_len

  out


make_joystick_mover = (joystick=1, xaxis="leftx", yaxis="lefty") ->
  if type(joystick) == "number"
    joystick = assert love.joystick.getJoysticks![joystick], "Missing joystick"

  (speed) ->
    hat_dir = joystick\getHat 1
    vec = if hat_dir != "c"
      switch hat_dir
        when "u"
          Vec2d 0, -1
        when "d"
          Vec2d 0, 1
        when "l"
          Vec2d -1, 0
        when "r"
          Vec2d 1, 0
        when "ld"
          Vec2d(-1, 1)\normalized!
        when "lu"
          Vec2d(-1, -1)\normalized!
        when "rd"
          Vec2d(1, 1)\normalized!
        when "ru"
          Vec2d(1, -1)\normalized!
    else
      x = joystick\getGamepadAxis xaxis
      y = joystick\getGamepadAxis yaxis
      Vec2d(x,y)

    vec = joystick_deadzone_normalize vec
    vec = vec * speed if speed
    vec

class Controller
  @next_joystick: 1

  @default: =>
    @ {
      left: "left"
      right: "right"
      up: "up"
      down: "down"

      confirm: "x"
      cancel: "c"
    }, "auto"

  tap_delay: 0.2
  axis_button: {
    left: true
    right: true
    up: true
    down: true
  }

  new: (mapping, @joystick) =>
    if @joystick == "auto"
      @joystick = love.joystick.getJoysticks![@@next_joystick]
      if @joystick
        @@next_joystick += 1

    @add_mapping mapping
    @tapper = {}
    @dtapper = {}
    @downer = {}

    @make_mover!

  make_mover: =>
    left = rawget @key_mapping, "left"
    right = rawget @key_mapping, "right"
    down = rawget @key_mapping, "down"
    up = rawget @key_mapping, "up"

    keyboard_mover = if left and right and down and up
      make_mover up, down, left, right

    joystick_mover = if @joystick
      make_joystick_mover @joystick

    if keyboard_mover and joystick_mover
      @movement_vector = (...) =>
        kv = keyboard_mover ...
        jv = joystick_mover ...

        -- mix together the vectors
        x = if kv[1] != 0
          if jv[1] != 0
            (kv[1] + jv[1]) / 2
          else
            kv[1]
        else
          jv[1]

        y = if kv[2] != 0
          if jv[2] != 0
            (kv[2] + jv[2]) / 2
          else
            kv[2]
        else
          jv[2]

        kv[1] = x
        kv[2] = y
        kv
    elseif keyboard_mover
      @movement_vector = (...) =>
        keyboard_mover ...
    elseif joystick_mover
      @movement_vector = (...) =>
        joystick_mover ...

  add_mapping: (mapping) =>
    @key_mapping or= table_table!
    @joy_mapping or= table_table!

    for name, inputs in pairs mapping
      if type(inputs) == "string"
        insert @key_mapping[name], inputs
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

  -- first down
  downed: (key) =>
    if @is_down key
      was_down = @downer[key]
      @downer[key] = true
      unless was_down
        true
    else
      @downer[key] = nil

  -- down then up
  tapped: (key, ...) =>
    if @is_down key
      @tapper[key] = true
    elseif @tapper[key] == true
      @tapper[key] = nil
      return true

  -- must be called every frame
  double_tapped: (key, ...) =>
    if @is_down key
      tap = @dtapper[key]
      if type(tap) == "number"
        if timer.getTime! - tap < @tap_delay
          @dtapper[key] = false
          if ...
            return true, @double_tapped ...
          else
            return true

      unless tap == false
        @dtapper[key] = true
    elseif @dtapper[key] == false
      @dtapper[key] = nil
    elseif @dtapper[key] == true
      @dtapper[key] = love.timer.getTime!

    if ...
      false, @double_tapped ...
    else
      false

  is_down: (name, ...) =>
    if keys = @key_mapping[name]
      pressed = keyboard.isDown unpack keys
      return true if pressed

    if @joystick_is_down name
      return true

    if ...
      @is_down ...
    else
      false

  -- detects a more intentional directional press
  -- having the keybaord key down will return true
  -- having the joystick primary direction match will return true
  direction_is_down: (name) =>
    return nil unless @axis_button[name]

    if keys = @key_mapping[name]
      return true if keyboard.isDown unpack keys

    if @joystick
      x = @joystick\getGamepadAxis "leftx"
      y = @joystick\getGamepadAxis "lefty"
      vec = joystick_deadzone_normalize Vec2d(x,y)
      vec = vec\primary_direction!

      yes = switch name
        when "left"
          vec[1] < 0
        when "right"
          vec[1] > 0
        when "up"
          vec[2] < 0
        when "down"
          vec[2] > 0

      return true if yes

  -- detects if joystick button is down
  -- also detects if joystick is pointed in direction slightest amount
  joystick_is_down: (name) =>
    return false unless @joystick

    -- left, right, etc map to axis instead
    if @axis_button[name]
      x = @joystick\getGamepadAxis "leftx"
      y = @joystick\getGamepadAxis "lefty"
      vec = joystick_deadzone_normalize Vec2d(x,y)


      hat_dir = @joystick\getHat 1
      if hat_dir != "c"
        return switch name
          when "left"
            hat_dir\match "l"
          when "right"
            hat_dir\match "r"
          when "up"
            hat_dir\match "u"
          when "down"
            hat_dir\match "d"

      return switch name
        when "left"
          vec[1] < 0
        when "right"
          vec[1] > 0
        when "up"
          vec[2] < 0
        when "down"
          vec[2] > 0


    return false unless @joy_mapping
    btns = @joy_mapping[name]
    return false unless btns and next btns

    @joystick\isDown unpack btns

  movement_vector: =>
    error "don't know how to make movement vector"

  wait_for: =>


{
  :make_mover
  :movement_vector
  :make_joystick_mover
  :Controller
}
