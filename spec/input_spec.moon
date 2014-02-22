
import restore from require "spec.helpers"

DOWN_KEYS = setmetatable {}, __index: => false

local Controller

describe "lovekit.input", ->
  setup ->
    export love = {
      keyboard: {
        isDown: (first, ...) ->
          return false unless first
          DOWN_KEYS[first] or love.keyboard.isDown ...

      }
      graphics: {}
    }

    import
      Controller
      from require "lovekit.input"

  teardown restore

  it "should work with stubbed keys", ->
    DOWN_KEYS.up = true
    DOWN_KEYS.down = false

    assert.truthy love.keyboard.isDown "up"
    assert.falsy love.keyboard.isDown "down"
    assert.truthy love.keyboard.isDown "down", "up"

  it "should create controller", ->
    c = Controller {
      confirm: "return"
      cancel: {"x", "y"}

      shoot: {
        keyboard: "b"
      }

      special: {
        keyboard: {"z", "c"}
        joystick: 1
      }

      quit: {
        joystick: {1,2}
      }

    }

    assert.same {
      confirm: {"return"}
      cancel: {"x", "y"}
      shoot: {"b"}
      special: {"z", "c"}
    }, c.key_mapping

    assert.same {
      quit: {1,2}
      special: {1}
    }, c.joy_mapping


  it "should not create joy_mapping with no btns", ->
    c = Controller {
      confirm: "return"
    }

    assert.falsy c.joy_mapping

  describe "key press", ->
    local c

    before_each ->
      for key in pairs DOWN_KEYS
        DOWN_KEYS[key] = nil

      c = Controller {
        single: "return"
        double: {"x", "y"}
      }
    

    it "should should detect key press", ->
      assert.falsy c\is_down "single"

      DOWN_KEYS.return = true
      assert.truthy c\is_down "single"

    it "should detect key press with multiple keys", ->
      assert.falsy c\is_down "double"

      DOWN_KEYS.y = true

      assert.truthy c\is_down "double"


    it "should detect one of many input groups", ->
      assert.falsy c\is_down "double", "single"

      DOWN_KEYS.return = true
      assert.truthy c\is_down "double", "single"


