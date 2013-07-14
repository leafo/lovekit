
current_color = { 255,255,255,255 }

export love = {
  setColor: (r=255,g=255,b=255,a=255) ->
    current_color = {r,g,b,a}
}

require "lovekit.color"

describe "color", ->
  it "should hash colors", ->
    for n in *{"Arkeus", "Leafo", "Adam D."}
      hash_string n
      hash_to_color n

  it "should make a color stack", ->
    colors = ColorStack!
    assert.same { colors\current! }, { 255,255,255,255 }

    colors\push 50,50,50

    assert.same current_color, { 50,50,50,255 }
    assert.same current_color, { colors\current! }

    colors\pop!

    assert.same current_color, { 255,255,255,255 }
    assert.same colors.length, 1

    colors\pusha 128

    assert.same current_color, { 255,255,255,128 }

    colors\pusha 128

    assert.same current_color, { 255,255,255, 128 * 128 / 255 }
    assert.same colors.length, 3

    colors\pop!
    colors\pop!

    assert.same current_color, { 255,255,255,255 }
    assert.same colors.length, 1

    colors\push 255,0,0

    assert.same current_color, { 255,0,0,255 }

    colors\push 128,128,128

    assert.same current_color, { 128,0,0,255 }

