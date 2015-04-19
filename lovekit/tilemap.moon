-- Support for rendering tilemaps and doing tile collision. A tile map holds
-- many layers where each layer is an array of tile instances. Each tile knows
-- up to draw itself.
-- Two ways to create a new tile map:
-- * From a pixel image, where colors associate with tiles
-- * Creating the tiles objects manually

import hash_color from require "lovekit.support"
import Spriter from require "lovekit.spriter"
import imgfy from require "lovekit.image"

import Box from require "lovekit.geometry"


import rectangle, triangle from love.graphics
import type from _G

{ graphics: g } = love
{ :modf, :floor, min: _min, max: _max } = math

animated_tile = (frames=error"expecting table") ->
  frames.animated = true
  frames.delay = frames.delay or 0.5
  frames

class Tile extends Box
  new: (@tid, ...) => super ...

  add: (batch, sprite, map) =>
    batch\add sprite\quad_for(@tid), @x, @y

  draw: (sprite, map) =>
    sprite\draw_cell @tid, @x, @y
    -- love.graphics.print "#{@tid}", @x, @y
    -- Box.draw @, {100,100,255}

-- frames a array of tids
class AnimatedTile extends Box
  new: (@frames, @delay, ...) =>
    super ...

  _get_tid: (map) =>
    @frames[floor(map.time / @delay % #@frames) + 1]

  add: (batch, sprite, map) =>
    batch\add sprite\quad_for(@_get_tid(map)), @x, @y

  draw: (sprite, map) =>
    sprite\draw_cell @_get_tid(map), @x, @y

class SlopeTopTile extends Box
  new: (@tid, @left, @right, ...) => super ...
  collides: (x1,y1, x2,y2) =>
    import left, right from @

    center = (x1 + x2) / 2
    t = (center - @x) / @w
    return false if t < 0 or t > 1

    if left < right
      p = t * (right - left) + left
      min = floor (@y + @h) - p
      y2 > min
    else
      error "not yet"

  height_for_pt: (x) =>
    import left from @
    t = (x - @x) / @w
    p = t * (@right - left) + left
    floor (@y + @h) - p

  -- try to move box by dx,dy across tile
  fit_move: (box, dx, dy, world) =>
    import x,y from box
    import map from world

    box.x = x + dx
    box.y = @height_for_pt(box.x + box.w / 2) - box.h
    if map\collides box
      box.x = x
      box.y = y
      return false

    true

  draw: Tile.draw
  -- draw: =>
  --   y = _min @left, @right

  --   setColor 255,100,255

  --   unless y == 0
  --     rectangle "fill", @x, @y + @h - y, @w, y

  --   setColor 100,255,100
  --   triangle "fill",
  --     @x, @y + @h - @left,
  --     @x + @w, @y + @h - @right,
  --     @x + @w, @y + @h - @left

  __tostring: =>
    "Slope<#{@left}, #{@right}>"


-- a grid of tiles with a preset map size (should be infinite soon)
class TileMap
  solid_layer: 0 -- the layer that we collide with
  cell_size: 16
  invert_collision: false
  batch_size: 1000

  -- read map from a tiled export
  @from_tiled = (mod_name, callbacks={}) =>
    data = require mod_name
    map = @ data.width, data.height
    map.cell_size = data.tilewidth
    map.invert_collision = true if data.properties.invert_collision

    fix_image_path = (path) ->
      path\gsub "^%.%./", "" -- TODO: make better

    tileset = data.tilesets[1]
    first_tid = tileset.firstgid
    image = fix_image_path tileset.image
    map.sprite = Spriter image, map.cell_size, map.cell_size

    if data.properties and next(data.properties) and callbacks.map_properties
      callbacks.map_properties data.properties

    l = 1
    for layer in *data.layers
      continue if layer.visible == false

      if layer.objects
        for obj in *layer.objects
          if fn = callbacks.object
            fn obj, l

      if layer.type == "imagelayer"
        map.layers[l].image = imgfy fix_image_path layer.image

      if layer.data
        is_solid = layer.properties.solid
        tiles = {}
        i = 0
        for t in *layer.data
          i += 1
          tid = t - first_tid
          continue if tid < 0
          tile = tid: tid, layer: l

          if callbacks.tile
            tile = callbacks.tile tile, layer, i

          if callbacks.solid_tile and is_solid
            tile = callbacks.solid_tile tile, layer, i


          tiles[i] = tile

        map\add_tiles tiles
        if layer.properties.hidden
          map.hidden_layers[l] = true

      if layer.properties.solid
        map.solid_layer = l

      l += 1

    map

  -- reads the pixels from image located at fname
  -- applies color_to_tile for each pixel of the image
  -- it can be either a function or a table. table keys
  -- are created by `hash_color`
  @from_image = (fname, tile_sprite, color_to_tile) =>
    data = love.image.newImageData fname
    width, height = data\getWidth!, data\getHeight!

    call_map = type(color_to_tile) == "function"

    tiles = {}
    len = 1
    for y=0,height - 1
      for x=0,width - 1
        _r, _g, _b, _a = data\getPixel x, y

        tile = if call_map
          color_to_tile x,y,_r,_g,_b,_a
        else
          color_to_tile[hash_color _r,_g,_b,_a]

        if type(tile) == "function"
          tile = tile x * tile_sprite.cell_w, y * tile_sprite.cell_w, len

        if type(tile) == "number"
          tile = tid: tile

        -- if not tile and _a > 0
        --   error "Got unexpected map tile color: " .. hash_color r,g,b,a

        tiles[len] = tile if tile
        len += 1

    with @ width, height
      .sprite = if type(tile_sprite) == "string"
        tile_sprite = Spriter tile_sprite, .cell_size, .cell_size
      else
        .cell_size = tile_sprite.cell_w
        tile_sprite

      \add_tiles tiles


  -- takes an array of tiles
  -- the key is an index into them map (starting from 1)
  -- the value is a table that is used to construct the tile, or the tile
  -- object itself
  --
  -- value format:
  -- {
  --   tid: 0   -- Tile Id
  --   layer: 0 -- the layer tile goes into, optional
  --   auto: (x,y,t,i) -> -- optional, result of this function is tid
  --   type: cls -- class to instantiate with, numeric indices become args
  -- }
  add_tiles: (tiles) =>
    import width from @

    for i, t in pairs tiles
      im1 = i - 1
      x = im1 % width
      y = floor im1 / width

      tid = if t.auto
        t.auto tiles, x,y,t,i
      else
        t.tid

      @layers[t.layer or 1][i] = if tid
        if cls = t.type
          k = #t
          t[k+1], t[k+2], t[k+3], t[k+4] = @pos_for_xy x, y
          cls tid, unpack t
        else
          Tile tid, @pos_for_xy x, y
      elseif t.animated
        AnimatedTile t, t.delay, @pos_for_xy x, y
      else
        t

  new: (@width, @height, tiles=nil) =>
    @count = @width * @height
    @min_layer, @max_layer = nil
    @time = 0 -- time used for animating tiles
    @hidden_layers = {}

    -- pixel size of the map
    @real_width = @width * @cell_size
    @real_height = @height * @cell_size

    -- automatically creates layer and upates min/max when it's acessed
    @layers = setmetatable {}, {
      __index: (layers, layer) ->
        l = {}
        layers[layer] = l

        @min_layer = not @min_layer and layer or _min @min_layer, layer
        @max_layer = not @max_layer and layer or _max @max_layer, layer
        @draw = nil -- ready to draw

        l
    }

    @add_tiles tiles if tiles

    -- this is stripped when the first layer is added
    @draw = -> error "map has no layers!"

  to_box: => Box 0,0, @real_width, @real_height

  to_xy: (i) =>
    i -= 1
    x = i % @width
    y = floor(i / @width)
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
        y = floor(i / @width)
        coroutine.yield x, y, t, i + 1

  update: (dt) =>
    @time += dt

  -- draw some layers
  draw: (viewport, min_layer=@min_layer, max_layer=@max_layer) =>
    viewport or= Box 0,0, @real_width, @real_height

    batch = @batch
    if batch
      batch\clear!
    else
      batch = g.newSpriteBatch @sprite.img.tex, @batch_size
      @batch = batch

    count = 0
    for i=min_layer, max_layer
      continue if @hidden_layers[i]
      _sprite = @sprite
      curr_layer = @layers[i]

      if bg = curr_layer.image
        bg\draw 0, 0

      for tid in @tiles_for_box viewport
        if tile = curr_layer[tid]
          tile\add batch, _sprite, @
          count += 1

    if count > @batch_size
      error "Added too many tiles to batch, #{count} > #{@batch_size}"

    g.draw batch, 0, 0

  draw_layer: (l, viewport) =>
    @draw viewport, l, l

  tile_for_point: (x,y, layer=@solid_layer) =>
    tiles = @layers[layer]
    x = floor x / @cell_size
    y = floor y / @cell_size
    tiles[y * @width + x + 1]

  collides_pt: (x, y) =>
    col = floor x / @cell_size
    row = floor y / @cell_size
    idx = col + @width * row + 1 -- 1 indexed

    tile = @layers[@solid_layer][idx]
    if @invert_collision
      not tile
    else
      not not tile

  -- either takes all args, or first argument is a thing/box
  collides: (x1, y1, x2, y2) =>
    import width, cell_size, invert_collision from self
    import floor from math

    unless y1
      box = x1.box or x1
      x1,y1, x2,y2 = box\unpack2!

    solid = @layers[@solid_layer]

    tx1, ty1 = floor(x1 / cell_size), floor(y1 / cell_size)

    tx2, tx2_fract = modf x2 / cell_size
    tx2 -= 1 if tx2_fract == 0

    ty2, ty2_fract = modf y2 / cell_size
    ty2 -= 1 if ty2_fract == 0

    touching = false

    y = ty1
    -- TODO does not work for things outside of the map
    while y <= ty2
      x = tx1
      while x <= tx2
        t = solid[y * width + x + 1]

        if invert_collision
          return true unless t
        else
          if t
            if fn = t.collides
              return true if fn t, x1,y1, x2,y2
            else
              return true

        x += 1
      y += 1

    false

  -- tests every tile, don't use this unless you have a good reason
  collides_all: (thing) =>
    solid = @layers[@solid_layer]
    for x, y, t, i in @each_xyt solid
      return true if solid[i] and solid[i]\touches_box thing

    false

  -- tiles for box is bugged, see main.moon example
  show_touching: (thing) =>
    solid = @layers[@solid_layer]
    for tid in @tiles_for_box thing
      tile = solid[tid]
      if tile
        Box.draw tile, {255, 200, 200, 200}
      else -- show candidates
        x, y = @to_xy tid
        b = Box x * @cell_size, y * @cell_size, @cell_size, @cell_size
        b = b\pad 10
        b\draw {255, 200, 200, 200}

  -- get all tile id touching box
  tiles_for_box: (box) =>
    xy_to_i = (x,y) ->
      col = floor x / @cell_size
      row = floor y / @cell_size
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


{
  :animated_tile
  :Tile
  :AnimatedTile
  :SlopeTopTile
  :TileMap
}
