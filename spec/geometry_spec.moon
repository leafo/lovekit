
import restore from require "spec.helpers"

describe "Vec2d", ->
  setup ->
    export love = { graphics: { } }
    require "lovekit.geometry"

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


