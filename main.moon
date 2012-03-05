
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
    collides: (thing) =>
      box = thing.box
      for t in *map\get_candidates box
        return true if box\touches_box t

  speed = 50
  me = Entity world, 0,0

  speed_i = 0
  love.keypressed = (name, code) ->
    switch name
      when " "
        speed_i = speed_i + 1 % 4
        print "speed index", speed_i
        speed = 50 + speed_i * 50
      when "escape" then os.exit!

  love.update = (dt) ->
    reloader\update!

    me.velocity\update unpack movement_vector speed

    me\update dt
    map\update dt

  love.mousepressed = (x, y) ->
    x,y = viewport\unproject x, y
    x, y = math.floor(x), math.floor(y)
    b\set_pos x,y
    print "CLICK", x, y


  show_grid = (v) ->
    graphics.setLineWidth 1/v.screen.scale
    graphics.setColor 255,255,255, 128

    w, h = v.w + 1, v.h + 1
    sx = math.floor v.x
    sy = math.floor v.y

    for y = sy, sy + h
      graphics.line sx, y, sx + w, y

    for x = sx, sx + w
      graphics.line x, sy, x, sy + h

    graphics.setColor 255,255,255

  love.draw = ->
    viewport\center_on me
    viewport\apply!

    map\draw!
    graphics.setColor 255,255,255, 64
    graphics.rectangle "fill", b\unpack!
    graphics.setColor 255,255,255

    -- map\highlight_region me.box
    me\draw!

    graphics.print love.timer.getFPS!, 10, 10

    -- show_grid viewport

