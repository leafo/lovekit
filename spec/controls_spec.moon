import restore from require "spec.helpers"

-- a joystick as love reports it, is_pad false for a keyboard that shows up
-- in the list
fake_joystick = (name, is_pad=true) ->
  {
    getName: -> name
    isGamepad: -> is_pad
    getHatCount: -> 0
    getGamepadAxis: -> 0
    isGamepadDown: -> false
    isDown: -> false
  }

local controls, joysticks

describe "lovekit.controls", ->
  setup ->
    joysticks = {}
    _G.love = {
      keyboard: {
        isDown: -> false
      }
      joystick: {
        getJoysticks: -> joysticks
        setGamepadMapping: ->
        loadGamepadMappings: ->
      }
      graphics: {}
    }

    controls = require "lovekit.controls"

  teardown restore

  before_each ->
    joysticks = {}
    controls.setup!

  it "builds a keyboard controller from the default mapping", ->
    c = controls.get!
    assert.same {"x"}, c.key_mapping.confirm
    assert.nil c.joystick
    assert.false controls.has_pad!

  it "returns the same controller every time", ->
    assert.equal controls.get!, controls.get!

  it "keeps the instance when setup runs again", ->
    c = controls.get!
    controls.setup keys: {confirm: "return"}
    assert.equal c, controls.get!
    assert.same {"return"}, c.key_mapping.confirm

  it "skips joysticks without a gamepad mapping", ->
    table.insert joysticks, fake_joystick "keyboard", false
    table.insert joysticks, fake_joystick "pad"
    controls.setup!
    assert.same {"pad"}, [j\getName! for j in *controls.find_pads!]
    assert.equal "pad", controls.get!.joystick\getName!

  it "maps gamepad buttons when a pad is found", ->
    table.insert joysticks, fake_joystick "pad"
    controls.setup {
      keys: {confirm: "return"}
      gamepad: {confirm: {"a", "x"}}
    }
    c = controls.get!
    assert.same {"return"}, c.key_mapping.confirm
    assert.same {"a", "x"}, c.joy_mapping.confirm

  it "leaves out gamepad buttons without a pad", ->
    controls.setup {
      keys: {confirm: "return"}
      gamepad: {confirm: "a"}
    }
    assert.nil controls.get!.joy_mapping

  it "runs on_build with the pad", ->
    table.insert joysticks, fake_joystick "pad"
    seen = nil
    controls.setup on_build: (c, pad) -> seen = {c, pad}
    c = controls.get!
    assert.equal c, seen[1]
    assert.equal "pad", seen[2]\getName!

  it "refreshes in place when a pad is plugged in", ->
    controls.setup gamepad: {confirm: "a"}
    c = controls.get!
    assert.nil c.joystick

    table.insert joysticks, fake_joystick "pad"
    controls.refresh!
    assert.equal c, controls.get!
    assert.equal "pad", c.joystick\getName!
    assert.same {"a"}, c.joy_mapping.confirm

  it "forgets a pad that was pulled", ->
    table.insert joysticks, fake_joystick "pad"
    controls.setup gamepad: {confirm: "a"}
    c = controls.get!
    assert.truthy c.joystick

    joysticks[1] = nil
    controls.refresh!
    assert.nil c.joystick
    assert.nil c.joy_mapping

  it "picks the prompt for what the player holds", ->
    label = controls.prompt "a", "x"
    assert.equal "x", label!
    table.insert joysticks, fake_joystick "pad"
    controls.refresh!
    assert.equal "a", label!

  it "binds hot-plug handlers around existing ones", ->
    calls = {}
    love.joystickadded = -> table.insert calls, "game"
    controls.bind love
    controls.get!
    table.insert joysticks, fake_joystick "pad"
    love.joystickadded!
    assert.same {"game"}, calls
    assert.true controls.has_pad!
    love.joystickadded = nil
    love.joystickremoved = nil
