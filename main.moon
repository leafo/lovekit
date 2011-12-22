
require "moon"

require "geometry"
require "tilemap"
require "spriter"

import graphics from love

love.load = ->

  sprite = Spriter "scrap/tileset.png", 16, 16
  map = TileMap.from_image "scrap/map.png", sprite, {
    ["0,0,0"]: { tid: 0 }
    ["255,255,255"]: { tid: 1 }
  }

  b = Box 0,0, 30, 30

  love.keypressed = (name, code) ->
    os.exit! if name == "escape"

  love.mousepressed = (x, y) ->
    x /= 3
    y /= 3

    b\set_pos x,y

  love.draw = ->
    graphics.scale 3, 3

    map\draw!
    graphics.rectangle "line", b\unpack!

    map\highlight_region b
