
import restore from require "spec.helpers"

local Vec2d, Box

describe "Vec2d", ->
  setup ->
    export love = { graphics: { } }
    import Vec2d from require "lovekit.geometry"

  teardown restore

  it "should create a vector", ->
    v = Vec2d 10, 20
    assert.same {10, 20}, v

    assert.equal 10, v.x
    assert.equal 20, v.y


  it "should do vector arithmetic", ->
    v1 = Vec2d 10, 20
    v2 = Vec2d 2, 4

    assert.same {12,24}, v1 + v2
    assert.same {8,16}, v1 - v2
    assert.same {20, 40}, v1 * 2
    assert.same {20, 40}, 2 * v1
    assert.same 100, v1 * v2 -- dot

  it "should get direction name", ->
    up = Vec2d 0, -1
    down = Vec2d 0, 1
    left = Vec2d -1, 0
    right = Vec2d 1, 0

    assert.equal "up", up\direction_name!
    assert.equal "down", down\direction_name!
    assert.equal "left", left\direction_name!
    assert.equal "right", right\direction_name!

describe "Box", ->
  setup ->
    export love = { graphics: { } }
    import Box from require "lovekit.geometry"

  teardown restore

  it "should add box to null box", ->
    b1 = Box 0,0,0,0
    b1\add_box Box 10, 10, 15,15
    assert.same {
      x: 10, y: 10
      w: 15, h: 15
    }, b1

  it "should add box to existing box", ->
    b1 = Box 5,5,10,10
    b1\add_box Box -10, 4, 15, 3

    assert.same {
      x: -10
      y: 4
      w: 25
      h: 11
    }, b1


