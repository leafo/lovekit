
require "support"
require "geometry"
require "spriter"

import getMicroTime from love.timer
import setColor, rectangle from love.graphics

export *

class Tile extends Box
  new: (@tid, ...) => super ...
  draw: (sprite, map) => sprite\draw_cell @tid, @x, @y

-- a grid of tiles with a preset map size (should be infinite soon)
class TileMap
  solid_layer: 0 -- the layer that we collide with
  cell_size: 16

  -- reads the pixels from image located at fname
  -- applies color_to_tile for each pixel of the image
  -- it can be either a function or a table. table keys
  -- are created by `hash_color`
  self.from_image = (fname, tile_sprite, color_to_tile) ->
    data = love.image.newImageData fname
    width, height = data\getWidth!, data\getHeight!

    call_map = type(color_to_tile) == "function"

    tiles = {}
    len = 1
    for y=0,height - 1
      for x=0,width - 1
        r,g,b,a = data\getPixel x, y
        tile = if call_map
          color_to_tile x,y,r,g,b,a
        elseif a == 255
          color_to_tile[hash_color r,g,b,a]

        tiles[len] = tile if tile
        len += 1

    with TileMap width, height
      .sprite = if type(tile_sprite) == "string"
        tile_sprite = Spriter tile_sprite, .cell_size, .cell_size
      else
        .cell_size = tile_sprite.cell_w
        tile_sprite

      \add_tiles tiles
      \update_collision!

  -- adds Tile objects into @layers from tile description tables
  add_tiles: (tiles) =>
    for x,y,t,i in @each_xyt tiles
      if t
        tid = if t.auto
          t.auto tiles, x,y,t,i
        else
          t.tid

        if tid
          @layers[t.layer or 0][i] = Tile tid,
            x * @cell_size, y * @cell_size,
            @cell_size, @cell_size

  update_collision: =>
    new_layer = -> UniformGrid @cell_size * 3

    @collision_layers = {}
    for l=@min_layer,@max_layer
      tiles = @layers[l]
      grid = new_layer!

      count = 0
      for x,y,t in @each_xyt tiles
        grid\add t if t

      print "added", count, "items"

      @collision_layers[l] = grid

    mixin_object self, @collision_layers[@solid_layer], {"get_candidates"}

  new: (@width, @height, tiles=nil) =>
    @count = @width * @height
    @min_layer, @max_layer = nil

    -- pixel size of the map
    @real_width = @width * @cell_size
    @real_height = @height * @cell_size

    @layers = setmetatable {}, {
      __index: (layers, layer) ->
        l = {}
        layers[layer] = l

        @min_layer = not @min_layer and layer or math.min @min_layer, layer
        @max_layer = not @max_layer and layer or math.max @max_layer, layer

        l
    }

    @add_tiles tiles if tiles

  to_xy: (i) =>
    i -= i
    x = i % @width
    y = math.floor(i / @width)
    x, y

  to_i: (x,y) =>
    return false if x < 0 or x >= @width
    return false if y < 0 or y >= @height
    y * @width + x + 1

  -- final x,y coord
  each_xyt: (tiles=@tiles)=>
    coroutine.wrap ->
      for i=1,@count
        t = tiles[i]
        i -= 1
        x = i % @width
        y = math.floor(i / @width)
        coroutine.yield x, y, t, i + 1

  highlight_region: (box, layer=@solid_layer) =>
    setColor 255,0,0,128
    for tile in *@collision_layers[layer]\get_candidates box
      Box.draw tile
      tile\draw @sprite

    setColor 255,255,255
    rectangle "line", box\unpack!


  draw: (viewport) =>
    if not viewport
      for i=@min_layer,@max_layer
        for x,y, tile in @each_xyt @layers[i]
          tile\draw @sprite if tile
    else
      for i=@min_layer,@max_layer
        for tile in *@collision_layers[i]\get_candidates viewport
          tile\draw @sprite


