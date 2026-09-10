
import restore from require "spec.helpers"

-- what love.graphics.setColor last received, in love 11's 0-1 range
current_color = { 1,1,1,1 }

-- compares a 0-255 color against the 0-1 color sent to love
assert_current_color = (expected) ->
  assert.same 4, #current_color
  for i, v in ipairs expected
    assert.near v / 255, current_color[i], 0.0001

local ColorStack, hash_string, hash_to_color

describe "color", ->
  setup ->
    _G.love = {
      graphics: {
        setColor: (r,g,b,a) ->
          current_color = {r,g,b,a}
      }
    }

    import
      ColorStack
      hash_string
      hash_to_color
      from require "lovekit.color"

  teardown restore

  it "should hash colors", ->
    for n in *{"Arkeus", "Leafo", "Adam D."}
      hash_string n
      hash_to_color n

  it "should make a color stack", ->
    colors = ColorStack!
    assert.same { colors\current! }, { 255,255,255,255 }

    colors\push 50,50,50

    assert_current_color { 50,50,50,255 }
    assert_current_color { colors\current! }

    colors\pop!

    assert_current_color { 255,255,255,255 }
    assert.same colors.length, 1

    colors\pusha 128

    assert_current_color { 255,255,255,128 }

    colors\pusha 128

    assert_current_color { 255,255,255, 128 * 128 / 255 }
    assert.same colors.length, 3

    colors\pop!
    colors\pop!

    assert_current_color { 255,255,255,255 }
    assert.same colors.length, 1

    colors\push 255,0,0

    assert_current_color { 255,0,0,255 }

    colors\push 128,128,128

    assert_current_color { 128,0,0,255 }

    before = colors.length
    colors\set 123,123,123,123

    assert.same colors.length, before
    assert_current_color { 123,0,0,123 }

