local hash_color
hash_color = require("lovekit.support").hash_color
local Spriter
Spriter = require("lovekit.spriter").Spriter
local imgfy
imgfy = require("lovekit.image").imgfy
local Box
Box = require("lovekit.geometry").Box
local rectangle, triangle
do
  local _obj_0 = love.graphics
  rectangle, triangle = _obj_0.rectangle, _obj_0.triangle
end
local type
type = _G.type
local g
g = love.graphics
local modf, floor, _min, _max
do
  local _obj_0 = math
  modf, floor, _min, _max = _obj_0.modf, _obj_0.floor, _obj_0.min, _obj_0.max
end
local animated_tile
animated_tile = function(frames)
  if frames == nil then
    frames = error("expecting table")
  end
  frames.animated = true
  frames.delay = frames.delay or 0.5
  return frames
end
local Tile
do
  local _class_0
  local _parent_0 = Box
  local _base_0 = {
    add = function(self, batch, sprite, map)
      return batch:add(sprite:quad_for(self.tid), self.x, self.y)
    end,
    draw = function(self, sprite, map)
      return sprite:draw_cell(self.tid, self.x, self.y)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, tid, ...)
      self.tid = tid
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Tile",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Tile = _class_0
end
local AnimatedTile
do
  local _class_0
  local _parent_0 = Box
  local _base_0 = {
    _get_tid = function(self, map)
      return self.frames[floor(map.time / self.delay % #self.frames) + 1]
    end,
    add = function(self, batch, sprite, map)
      return batch:add(sprite:quad_for(self:_get_tid(map)), self.x, self.y)
    end,
    draw = function(self, sprite, map)
      return sprite:draw_cell(self:_get_tid(map), self.x, self.y)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, frames, delay, ...)
      self.frames, self.delay = frames, delay
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "AnimatedTile",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  AnimatedTile = _class_0
end
local SlopeTopTile
do
  local _class_0
  local _parent_0 = Box
  local _base_0 = {
    collides = function(self, x1, y1, x2, y2)
      local left, right
      left, right = self.left, self.right
      local center = (x1 + x2) / 2
      local t = (center - self.x) / self.w
      if t < 0 or t > 1 then
        return false
      end
      if left < right then
        local p = t * (right - left) + left
        local min = floor((self.y + self.h) - p)
        return y2 > min
      else
        return error("not yet")
      end
    end,
    height_for_pt = function(self, x)
      local left
      left = self.left
      local t = (x - self.x) / self.w
      local p = t * (self.right - left) + left
      return floor((self.y + self.h) - p)
    end,
    fit_move = function(self, box, dx, dy, world)
      local x, y
      x, y = box.x, box.y
      local map
      map = world.map
      box.x = x + dx
      box.y = self:height_for_pt(box.x + box.w / 2) - box.h
      if map:collides(box) then
        box.x = x
        box.y = y
        return false
      end
      return true
    end,
    draw = Tile.draw,
    __tostring = function(self)
      return "Slope<" .. tostring(self.left) .. ", " .. tostring(self.right) .. ">"
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, tid, left, right, ...)
      self.tid, self.left, self.right = tid, left, right
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "SlopeTopTile",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  SlopeTopTile = _class_0
end
local TileMap
do
  local _class_0
  local _base_0 = {
    solid_layer = 0,
    cell_size = 16,
    invert_collision = false,
    batch_size = 1000,
    add_tiles = function(self, tiles)
      local width
      width = self.width
      for i, t in pairs(tiles) do
        local im1 = i - 1
        local x = im1 % width
        local y = floor(im1 / width)
        local tid
        if t.auto then
          tid = t.auto(tiles, x, y, t, i)
        else
          tid = t.tid
        end
        if tid then
          do
            local cls = t.type
            if cls then
              local k = #t
              t[k + 1], t[k + 2], t[k + 3], t[k + 4] = self:pos_for_xy(x, y)
              self.layers[t.layer or 1][i] = cls(tid, unpack(t))
            else
              self.layers[t.layer or 1][i] = Tile(tid, self:pos_for_xy(x, y))
            end
          end
        elseif t.animated then
          self.layers[t.layer or 1][i] = AnimatedTile(t, t.delay, self:pos_for_xy(x, y))
        else
          self.layers[t.layer or 1][i] = t
        end
      end
    end,
    to_box = function(self)
      return Box(0, 0, self.real_width, self.real_height)
    end,
    to_xy = function(self, i)
      i = i - 1
      local x = i % self.width
      local y = floor(i / self.width)
      return x, y
    end,
    to_i = function(self, x, y)
      if x < 0 or x >= self.width then
        return false
      end
      if y < 0 or y >= self.height then
        return false
      end
      return y * self.width + x + 1
    end,
    pos_for_xy = function(self, x, y)
      return x * self.cell_size, y * self.cell_size, self.cell_size, self.cell_size
    end,
    pos_for_i = function(self, i)
      return self:pos_for_xy(self:to_xy(i))
    end,
    each_xyt = function(self, tiles)
      if tiles == nil then
        tiles = self.tiles
      end
      return coroutine.wrap(function()
        for i = 1, self.count do
          local t = tiles[i]
          i = i - 1
          local x = i % self.width
          local y = floor(i / self.width)
          coroutine.yield(x, y, t, i + 1)
        end
      end)
    end,
    update = function(self, dt)
      self.time = self.time + dt
    end,
    draw = function(self, viewport, min_layer, max_layer)
      if min_layer == nil then
        min_layer = self.min_layer
      end
      if max_layer == nil then
        max_layer = self.max_layer
      end
      viewport = viewport or Box(0, 0, self.real_width, self.real_height)
      local batch = self.batch
      if batch then
        batch:clear()
      else
        batch = g.newSpriteBatch(self.sprite.img.tex, self.batch_size)
        self.batch = batch
      end
      local count = 0
      for i = min_layer, max_layer do
        local _continue_0 = false
        repeat
          if self.hidden_layers[i] then
            _continue_0 = true
            break
          end
          local _sprite = self.sprite
          local curr_layer = self.layers[i]
          do
            local bg = curr_layer.image
            if bg then
              bg:draw(0, 0)
            end
          end
          for tid in self:tiles_for_box(viewport) do
            do
              local tile = curr_layer[tid]
              if tile then
                tile:add(batch, _sprite, self)
                count = count + 1
              end
            end
          end
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      if count > self.batch_size then
        error("Added too many tiles to batch, " .. tostring(count) .. " > " .. tostring(self.batch_size))
      end
      return g.draw(batch, 0, 0)
    end,
    draw_layer = function(self, l, viewport)
      return self:draw(viewport, l, l)
    end,
    tile_for_point = function(self, x, y, layer)
      if layer == nil then
        layer = self.solid_layer
      end
      local tiles = self.layers[layer]
      x = floor(x / self.cell_size)
      y = floor(y / self.cell_size)
      return tiles[y * self.width + x + 1]
    end,
    collides_pt = function(self, x, y)
      local col = floor(x / self.cell_size)
      local row = floor(y / self.cell_size)
      local idx = col + self.width * row + 1
      local tile = self.layers[self.solid_layer][idx]
      if self.invert_collision then
        return not tile
      else
        return not not tile
      end
    end,
    collides = function(self, x1, y1, x2, y2)
      local width, cell_size, invert_collision
      width, cell_size, invert_collision = self.width, self.cell_size, self.invert_collision
      floor = math.floor
      if not (y1) then
        local box = x1.box or x1
        x1, y1, x2, y2 = box:unpack2()
      end
      local solid = self.layers[self.solid_layer]
      local tx1, ty1 = floor(x1 / cell_size), floor(y1 / cell_size)
      local tx2, tx2_fract = modf(x2 / cell_size)
      if tx2_fract == 0 then
        tx2 = tx2 - 1
      end
      local ty2, ty2_fract = modf(y2 / cell_size)
      if ty2_fract == 0 then
        ty2 = ty2 - 1
      end
      local touching = false
      local y = ty1
      while y <= ty2 do
        local x = tx1
        while x <= tx2 do
          local t = solid[y * width + x + 1]
          if invert_collision then
            if not (t) then
              return true
            end
          else
            if t then
              do
                local fn = t.collides
                if fn then
                  if fn(t, x1, y1, x2, y2) then
                    return true
                  end
                else
                  return true
                end
              end
            end
          end
          x = x + 1
        end
        y = y + 1
      end
      return false
    end,
    collides_all = function(self, thing)
      local solid = self.layers[self.solid_layer]
      for x, y, t, i in self:each_xyt(solid) do
        if solid[i] and solid[i]:touches_box(thing) then
          return true
        end
      end
      return false
    end,
    show_touching = function(self, thing)
      local solid = self.layers[self.solid_layer]
      for tid in self:tiles_for_box(thing) do
        local tile = solid[tid]
        if tile then
          Box.draw(tile, {
            255,
            200,
            200,
            200
          })
        else
          local x, y = self:to_xy(tid)
          local b = Box(x * self.cell_size, y * self.cell_size, self.cell_size, self.cell_size)
          b = b:pad(10)
          b:draw({
            255,
            200,
            200,
            200
          })
        end
      end
    end,
    tiles_for_box = function(self, box)
      local xy_to_i
      xy_to_i = function(x, y)
        local col = floor(x / self.cell_size)
        local row = floor(y / self.cell_size)
        return col + self.width * row + 1
      end
      return coroutine.wrap(function()
        local x1, y1, x2, y2 = box:unpack2()
        local x, y = x1, y1
        local max_x = x2
        local rem_x = max_x % self.cell_size
        if rem_x ~= 0 then
          max_x = max_x + (self.cell_size - rem_x)
        end
        local max_y = y2
        local rem_y = max_y % self.cell_size
        if rem_y ~= 0 then
          max_y = max_y + (self.cell_size - rem_y)
        end
        while y <= max_y do
          x = x1
          while x <= max_x do
            coroutine.yield(xy_to_i(x, y))
            x = x + self.cell_size
          end
          y = y + self.cell_size
        end
      end)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, width, height, tiles)
      if tiles == nil then
        tiles = nil
      end
      self.width, self.height = width, height
      self.count = self.width * self.height
      self.min_layer, self.max_layer = nil
      self.time = 0
      self.hidden_layers = { }
      self.real_width = self.width * self.cell_size
      self.real_height = self.height * self.cell_size
      self.layers = setmetatable({ }, {
        __index = function(layers, layer)
          local l = { }
          layers[layer] = l
          self.min_layer = not self.min_layer and layer or _min(self.min_layer, layer)
          self.max_layer = not self.max_layer and layer or _max(self.max_layer, layer)
          self.draw = nil
          return l
        end
      })
      if tiles then
        self:add_tiles(tiles)
      end
      self.draw = function()
        return error("map has no layers!")
      end
    end,
    __base = _base_0,
    __name = "TileMap"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.from_tiled = function(self, mod_name, callbacks)
    if callbacks == nil then
      callbacks = { }
    end
    local data = require(mod_name)
    local map = self(data.width, data.height)
    map.cell_size = data.tilewidth
    if data.properties.invert_collision then
      map.invert_collision = true
    end
    local fix_image_path
    fix_image_path = function(path)
      return path:gsub("^%.%./", "")
    end
    local tileset = data.tilesets[1]
    local first_tid = tileset.firstgid
    local image = fix_image_path(tileset.image)
    map.sprite = Spriter(image, map.cell_size, map.cell_size)
    if data.properties and next(data.properties) and callbacks.map_properties then
      callbacks.map_properties(data.properties)
    end
    local l = 1
    local _list_0 = data.layers
    for _index_0 = 1, #_list_0 do
      local _continue_0 = false
      repeat
        local layer = _list_0[_index_0]
        if layer.visible == false then
          _continue_0 = true
          break
        end
        if layer.objects then
          local _list_1 = layer.objects
          for _index_1 = 1, #_list_1 do
            local obj = _list_1[_index_1]
            do
              local fn = callbacks.object
              if fn then
                fn(obj, l)
              end
            end
          end
        end
        if layer.type == "imagelayer" then
          map.layers[l].image = imgfy(fix_image_path(layer.image))
        end
        if layer.data then
          local is_solid = layer.properties.solid
          local tiles = { }
          local i = 0
          local _list_1 = layer.data
          for _index_1 = 1, #_list_1 do
            local _continue_1 = false
            repeat
              local t = _list_1[_index_1]
              i = i + 1
              local tid = t - first_tid
              if tid < 0 then
                _continue_1 = true
                break
              end
              local tile = {
                tid = tid,
                layer = l
              }
              if callbacks.tile then
                tile = callbacks.tile(tile, layer, i)
              end
              if callbacks.solid_tile and is_solid then
                tile = callbacks.solid_tile(tile, layer, i)
              end
              tiles[i] = tile
              _continue_1 = true
            until true
            if not _continue_1 then
              break
            end
          end
          map:add_tiles(tiles)
          if layer.properties.hidden then
            map.hidden_layers[l] = true
          end
        end
        if layer.properties.solid then
          map.solid_layer = l
        end
        l = l + 1
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    return map
  end
  self.from_image = function(self, fname, tile_sprite, color_to_tile)
    local data = love.image.newImageData(fname)
    local width, height = data:getWidth(), data:getHeight()
    local call_map = type(color_to_tile) == "function"
    local tiles = { }
    local len = 1
    for y = 0, height - 1 do
      for x = 0, width - 1 do
        local _r, _g, _b, _a = data:getPixel(x, y)
        local tile
        if call_map then
          tile = color_to_tile(x, y, _r, _g, _b, _a)
        else
          tile = color_to_tile[hash_color(_r, _g, _b, _a)]
        end
        if type(tile) == "function" then
          tile = tile(x * tile_sprite.cell_w, y * tile_sprite.cell_w, len)
        end
        if type(tile) == "number" then
          tile = {
            tid = tile
          }
        end
        if tile then
          tiles[len] = tile
        end
        len = len + 1
      end
    end
    do
      local _with_0 = self(width, height)
      if type(tile_sprite) == "string" then
        tile_sprite = Spriter(tile_sprite, _with_0.cell_size, _with_0.cell_size)
      else
        _with_0.cell_size = tile_sprite.cell_w
        _with_0.sprite = tile_sprite
      end
      _with_0:add_tiles(tiles)
      return _with_0
    end
  end
  TileMap = _class_0
end
return {
  animated_tile = animated_tile,
  Tile = Tile,
  AnimatedTile = AnimatedTile,
  SlopeTopTile = SlopeTopTile,
  TileMap = TileMap
}
