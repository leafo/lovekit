
require "moon"

require "lovekit.all"
reloader = require "lovekit.reloader"
require "lovekit.screen_snap"

import graphics, keyboard from love

snapper = nil

love.load = ->
  viewport = Viewport scale: 4

  for k,v in pairs love.graphics
    print "*", k

  sprite = Spriter "scrap/tileset.png", 16, 16
  map = TileMap.from_image "scrap/map.png", sprite, {
    ["0,0,0"]: { tid: 0 }
    ["255,255,255"]: { tid: 1 }
    ["0,0,255"]: animated_tile { 2, 3, layer: 0 }
  }


  ui_sprite = Spriter "scrap/ui.png", 4, 4, 4
  window = lui.Window ui_sprite

  b = Box 0,0, 30, 30

  world =
    collides: (...) => map\collides ...

  speed = 150
  me = Entity world, 0,0

  speed_i = 0
  love.keypressed = (name, code) ->
    switch name
      when " "
        speed_i = (speed_i + 1) % 4
        print "speed index", speed_i
        speed = 50 + speed_i * 50
      when "escape" then os.exit!
      when "s"
        snapper = if snapper then nil else ScreenSnap!

  seq = Sequence ->
    tween b, 1, x: 80, y: 50
    tween b, 1, x: 0, y: 0
    again!

  love.update = (dt) ->
    reloader\update!

    me.velocity\update unpack movement_vector speed

    me\update dt
    map\update dt

    seq\update dt

  love.mousepressed = (x, y) ->
    x,y = viewport\unproject x, y
    x, y = math.floor(x), math.floor(y)
    b\set_pos x,y
    print "CLICK", x, y

  love.draw = ->
    viewport\center_on me
    viewport\apply!


    v = viewport\pad 20
    map\draw box: v
    v\outline!

    graphics.setColor 255,255,255, 64
    graphics.rectangle "fill", b\unpack!
    graphics.setColor 255,255,255

    map\show_touching me

    me\draw!

    viewport\pop!

    -- window\draw 10, 10, 100, 100
    graphics.print love.timer.getFPS!, 10, 10
    -- window\draw b\unpack!

    snapper\tick! if snapper

    -- show_grid viewport

