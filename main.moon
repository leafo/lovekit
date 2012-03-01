
require "moon"

require "lovekit.all"
reloader = require "lovekit.reloader"

import graphics, keyboard from love

love.load = ->
  viewport = Viewport scale: 4

  sprite = Spriter "scrap/tileset.png", 16, 16
  map = TileMap.from_image "scrap/map.png", sprite, {
    ["0,0,0"]: { tid: 0 }
    ["255,255,255"]: { tid: 1 }
    ["0,0,255"]: animated_tile { 2, 3, layer: 0 }
  }

  b = Box 0,0, 30, 30

  world =
    collides: => false

  me = Entity world, 0,0

  love.keypressed = (name, code) ->
    switch name
      when "escape" then os.exit!

  love.update = (dt) ->
    reloader\update!
    speed = 100

    me.velocity[1] = if keyboard.isDown "left"
      -speed
    elseif keyboard.isDown "right"
      speed
    else
      0

    me.velocity[2] = if keyboard.isDown "down"
      speed
    elseif keyboard.isDown "up"
      -speed
    else
      0

    me\update dt
    map\update dt

  love.mousepressed = (x, y) ->
    x,y = viewport\unproject x, y
    b\set_pos x,y

  love.draw = ->
    viewport\center_on me
    viewport\apply!

    map\draw!
    graphics.rectangle "line", b\unpack!

    map\highlight_region me.box

    me\draw!

