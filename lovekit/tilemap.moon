
require "lovekit.support"
require "lovekit.geometry"
require "lovekit.spriter"

import getMicroTime from love.timer
import setColor, rectangle from love.graphics

export *

animated_tile = (frames=error"expecting table") ->
  frames.animated = true
  frames.delay = frames.delay or 0.5
  frames

class Tile extends Box
  new: (@tid, ...) => super ...
  draw: (sprite, map) => sprite\draw_cell @tid, @x, @y

-- frames a array of tids
class AnimatedTile extends Box
  new: (@frames, @delay, ...) =>
    super ...
  draw: (sprite, map) =>
    fid = math.floor(map.time / @delay % #@frames) + 1
    sprite\draw_cell @frames[fid], @x, @y


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

        if not tile and a > 0
          error "Got unexpected map tile color: " .. hash_color r,g,b,a

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

        position = {
          x * @cell_size, y * @cell_size
          @cell_size, @cell_size
        }

        @layers[t.layer or 1][i] = if tid
          Tile tid, unpack position
        elseif t.animated
          AnimatedTile t, t.delay, unpack position

  update_collision: =>
    new_layer = -> UniformGrid @cell_size * 3

    @collision_layers = {}
    for l=@min_layer,@max_layer
      tiles = @layers[l]
      grid = new_layer!

      for x,y,t in @each_xyt tiles
        grid\add t if t

      @collision_layers[l] = grid

    mixin_object self, @collision_layers[@solid_layer], {"get_candidates"}

  new: (@width, @height, tiles=nil) =>
    @count = @width * @height
    @min_layer, @max_layer = nil
    @time = 0 -- time used for animating tiles

    -- pixel size of the map
    @real_width = @width * @cell_size
    @real_height = @height * @cell_size

    -- automatically creates layer when we access it
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
      tile\draw @sprite, self

    setColor 255,255,255
    rectangle "line", box\unpack!

  update: (dt) =>
    @time += dt

  draw: (viewport) =>
    if not viewport
      for i=@min_layer,@max_layer
        for x,y, tile in @each_xyt @layers[i]
          tile\draw @sprite, self if tile
    else
      for i=@min_layer,@max_layer
        for tile in *@collision_layers[i]\get_candidates viewport
          tile\draw @sprite, self


