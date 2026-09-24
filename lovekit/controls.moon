import Controller from require "lovekit.input"

-- the controller the player holds, shared by every scene and menu in a game.
-- hot-plugging a pad rebuilds it in place, so anything holding the instance
-- keeps working
--
--   controls = require "lovekit.controls"
--   controls.setup keys: {...}, gamepad: {...}
--   controls.bind love
--   controls.get!\downed "confirm"

local config, current, refresh

-- joysticks with a gamepad mapping. keyboards and other HID devices show up
-- as joysticks too, and raw buttons on them cause phantom input
find_pads = ->
  [j for j in *love.joystick.getJoysticks! when j\isGamepad!]

-- opts:
--   keys: action -> keyboard key or list of keys, the Controller default
--     mapping when left out
--   gamepad: action -> gamepad button name or list, mapped when a pad is
--     found. a name given in both mappings adds the buttons to the keys
--   pad: which gamepad to take, 1 by default
--   on_build: (controller, pad) runs after the mappings, for anything the
--     game decides by looking at the pad
setup = (opts={}) ->
  config = opts
  refresh!

-- into replaces every field of an existing instance, so a pad that's gone is
-- forgotten along with any keys it was holding
build = (into) ->
  opts = config or {}
  pad = find_pads![opts.pad or 1]
  controller = Controller opts.keys or Controller.default_mapping, pad

  if pad and opts.gamepad
    controller\add_mapping {name, {joystick: btns} for name, btns in pairs opts.gamepad}

  if into
    for k in pairs into
      into[k] = nil
    for k, v in pairs controller
      into[k] = v
    controller = into

  opts.on_build controller, pad if opts.on_build
  controller

get = ->
  current or= build!
  current

refresh = ->
  return unless current
  build current

has_pad = ->
  get!.joystick != nil

-- a label that follows what the player holds, for button prompts. returns a
-- function so it can be checked every frame
prompt = (pad_label, key_label) ->
  -> if has_pad! then pad_label else key_label

-- refresh on hot-plug, keeping any handlers the game already installed
bind = (love) ->
  for event in *{"joystickadded", "joystickremoved"}
    previous = love[event]
    love[event] = (...) ->
      refresh!
      previous ... if previous

{ :setup, :get, :refresh, :has_pad, :prompt, :bind, :find_pads }
