-- Support for rendering tilemaps and doing tile collision. A tile map holds
-- many layers where each layer is an array of tile instances. Each tile knows
-- up to draw itself.
-- Two ways to create a new tile map:
-- * From a pixel image, where colors associate with tiles
-- * Creating the tiles objects manually

require "lovekit.support"
require "lovekit.geometry"
require "lovekit.spriter"

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

        if type(tile) == "function"
          tile = tile x * tile_sprite.cell_w, y * tile_sprite.cell_w, len

        if type(tile) == "number"
          tile = tid: tile

        -- if not tile and a > 0
        --   error "Got unexpected map tile color: " .. hash_color r,g,b,a

        tiles[len] = tile if tile
        len += 1

    with TileMap width, height
      .sprite = if type(tile_sprite) == "string"
        tile_sprite = Spriter tile_sprite, .cell_size, .cell_size
      else
        .cell_size = tile_sprite.cell_w
        tile_sprite

      \add_tiles tiles

  -- adds Tile objects into @layers from tile description tables
  add_tiles: (tiles) =>
    for x,y,t,i in @each_xyt tiles
      if t
        tid = if t.auto
          t.auto tiles, x,y,t,i
        else
          t.tid

        @layers[t.layer or 1][i] = if tid
          Tile tid, @pos_for_xy x, y
        elseif t.animated
          AnimatedTile t, t.delay, @pos_for_xy x, y
        else
          t

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
  
  to_box: => Box 0,0, @real_width, @real_height

  to_xy: (i) =>
    i -= 1
    x = i % @width
    y = math.floor(i / @width)
    x, y

  to_i: (x,y) =>
    return false if x < 0 or x >= @width
    return false if y < 0 or y >= @height
    y * @width + x + 1

  pos_for_xy: (x, y) =>
    x * @cell_size, y * @cell_size, @cell_size, @cell_size

  pos_for_i: (i) =>
    @pos_for_xy @to_xy i

  -- final x,y coord
  each_xyt: (tiles=@tiles)=>
    coroutine.wrap ->
      for i=1,@count
        t = tiles[i]
        i -= 1
        x = i % @width
        y = math.floor(i / @width)
        coroutine.yield x, y, t, i + 1

  update: (dt) =>
    @time += dt

  draw: (viewport) =>
    box = viewport and viewport.box or Box 0,0, @real_width, @real_height
    for tid in @tiles_for_box box
      for i=@min_layer, @max_layer
        tile = @layers[i][tid]
        tile\draw @sprite, self if tile

  draw_layer: (l, viewport) =>
    count = 0
    if viewport
      for tid in @tiles_for_box viewport
        tile = @layers[l][tid]
        if tile
          tile\draw @sprite, self
          count += 1
    else
      for _, tile in pairs @layers[l]
        tile\draw @sprite, self
        count += 1

  collides: (thing) =>
    import width, cell_size from self
    import floor from math
    solid = @layers[@solid_layer]

    x1,y1, x2,y2 = thing.box\unpack2!

    x1,y1 = floor(x1 / cell_size), floor(y1 / cell_size)
    x2,y2 = floor(x2 / cell_size), floor(y2 / cell_size)

    y = y1
    -- TODO does not work for things outside of the map
    while y <= y2
      x = x1
      while x <= x2
        return true if solid[y * width + x + 1]
        x += 1
      y += 1

    false

  -- tests every tile, don't use this unless you have a good reason
  collides_all: (thing) =>
    solid = @layers[@solid_layer]
    for x, y, t, i in @each_xyt solid
      return true if solid[i] and solid[i]\touches_box thing.box

    false

  -- tiles for box is bugged, see main.moon example
  show_touching: (thing) =>
    solid = @layers[@solid_layer]
    for tid in @tiles_for_box thing.box
      tile = solid[tid]
      if tile
        Box.draw tile, {255, 128, 128, 128}
      else -- show candidates
        x, y = @to_xy tid
        b = Box x * @cell_size, y * @cell_size, @cell_size, @cell_size
        b = b\pad 10
        b\draw {255, 128, 128, 128}


    -- get all tile id touching box
  tiles_for_box: (box) =>
    xy_to_i = (x,y) ->
      col = math.floor x / @cell_size
      row = math.floor y / @cell_size
      col + @width * row + 1 -- 1 indexed

    coroutine.wrap ->
      x1, y1, x2, y2 = box\unpack2!
      x, y = x1, y1

      max_x = x2
      rem_x = max_x % @cell_size
      max_x += @cell_size - rem_x if rem_x != 0

      max_y = y2
      rem_y = max_y % @cell_size
      max_y += @cell_size - rem_y if rem_y != 0

      while y <= max_y
        x = x1
        while x <= max_x
          coroutine.yield xy_to_i x, y
          x += @cell_size
        y += @cell_size


