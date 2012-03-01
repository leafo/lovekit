
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
    ["0,0,255"]: animated_tile { 2, 3 }
  }

  b = Box 0,0, 30, 30
  thing = Box 0,0, 10,10

  love.keypressed = (name, code) ->
    switch name
      when "escape" then os.exit!

  love.update = (dt) ->
    reloader\update!
    speed = 100

    if keyboard.isDown "left"
      thing\move -speed*dt, 0
    elseif keyboard.isDown "right"
      thing\move speed*dt, 0

    if keyboard.isDown "down"
      thing\move 0, speed*dt
    elseif keyboard.isDown "up"
      thing\move 0, -speed*dt

    map\update dt


  love.mousepressed = (x, y) ->
    x,y = viewport\unproject x, y
    b\set_pos x,y

  love.draw = ->
    viewport\center_on box:thing
    viewport\apply!

    map\draw!
    graphics.rectangle "line", b\unpack!

    -- map\highlight_region b

    thing\draw!

