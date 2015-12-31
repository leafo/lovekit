require("lovekit.geometry")
require("lovekit.effects")
local graphics
graphics = love.graphics
local Box
Box = require("lovekit.geometry").Box
local imgfy
imgfy = require("lovekit.image").imgfy
local EffectList
EffectList = require("lovekit.lists").EffectList
local ShakeEffect
ShakeEffect = require("lovekit.effects").ShakeEffect
local smooth_approach
smooth_approach = require("lovekit.support").smooth_approach
local Viewport
do
  local _class_0
  local _parent_0 = Box
  local _base_0 = {
    x = 0,
    y = 0,
    scale = 1,
    offset_x = 0,
    offset_y = 0,
    crop = false,
    pixel_scale = false,
    update = function(self, dt) end,
    bigger = function(self)
      local x, y, w, h = self:unpack()
      return Box(x - w / 2, y - h / 2, w * 2, h * 2)
    end,
    apply = function(self, scale)
      if scale == nil then
        scale = true
      end
      if self.pixel_scale then
        if not (self.canvas) then
          self.canvas = graphics.newCanvas(self.w, self.h)
          self.canvas:setFilter("nearest", "nearest")
        end
        self.last_canvas = graphics.getCanvas()
        graphics.setCanvas(self.canvas)
        self.canvas:clear(0, 0, 0, 0)
        graphics.push()
        graphics.translate(-self.x, -self.y)
        return 
      end
      if self.crop then
        local s = self.scale
        graphics.setScissor(self.offset_x, self.offset_y, self.w * s, self.h * s)
      end
      graphics.push()
      graphics.translate(self.offset_x, self.offset_y)
      do
        local s = self.scale
        if s then
          graphics.scale(s, s)
        end
      end
      return graphics.translate(-self.x, -self.y)
    end,
    pop = function(self)
      if self.pixel_scale then
        graphics.pop()
        if self.last_canvas then
          graphics.setCanvas(self.last_canvas)
        else
          graphics.setCanvas()
        end
        graphics.push()
        graphics.setBlendMode("premultiplied")
        graphics.draw(self.canvas, 0, 0, 0, self.scale, self.scale)
        graphics.setBlendMode("alpha")
        graphics.pop()
        return 
      end
      graphics.pop()
      if self.crop then
        return graphics.setScissor()
      end
    end,
    unproject = function(self, x, y)
      return (x - self.offset_x) / self.scale + self.x, (y - self.offset_y) / self.scale + self.y
    end,
    project = function(self, x, y)
      return (x - self.x) * self.scale + self.offset_x, (y - self.y) * self.scale + self.offset_y
    end,
    center_on_pt = function(self, cx, cy, map_box, dt)
      local tx = cx - self.w / 2
      local ty = cy - self.h / 2
      if dt then
        self.x = smooth_approach(self.x, tx, dt * self.w / 100)
        self.y = smooth_approach(self.y, ty, dt * self.w / 100)
      else
        self.x = tx
        self.y = ty
      end
      if map_box then
        local x1, y1, x2, y2 = map_box:unpack2()
        if self.x < x1 then
          self.x = x1
        end
        if self.y < y1 then
          self.y = y1
        end
        local max_x = x2 - self.w
        local max_y = y2 - self.h
        if self.x > max_x then
          self.x = max_x
        end
        if self.y > max_y then
          self.y = max_y
        end
      end
    end,
    center_on = function(self, thing, ...)
      local dx, dy
      if thing.looking_at then
        dx, dy = thing:looking_at(self)
      else
        dx, dy = thing:center()
      end
      return self:center_on_pt(dx, dy, ...)
    end,
    on_bottom = function(self, size, margin)
      if margin == nil then
        margin = 0
      end
      return self.h - (size + margin)
    end,
    on_right = function(self, size, margin)
      if margin == nil then
        margin = 0
      end
      return self.w - (size + margin)
    end,
    left = function(self, offset)
      if offset == nil then
        offset = 0
      end
      return offset
    end,
    right = function(self, offset)
      if offset == nil then
        offset = 0
      end
      return self.w - offset
    end,
    top = function(self, offset)
      if offset == nil then
        offset = 0
      end
      return offset
    end,
    bottom = function(self, offset)
      if offset == nil then
        offset = 0
      end
      return self.h - offset
    end,
    __tostring = function(self)
      return ("viewport<(%d, %d), (%d, %d)>"):format(self:unpack())
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, opts)
      if opts == nil then
        opts = { }
      end
      local screen_w, screen_h = graphics.getWidth(), graphics.getHeight()
      self.pixel_scale = opts.pixel_scale
      if opts.scale then
        self.scale = opts.scale
        self.w = screen_w / self.scale
        self.h = screen_h / self.scale
        return 
      end
      if opts.w and opts.h then
        self.w = opts.w
        self.h = opts.h
        local margin = opts.margin or 0
        local margin_x, margin_y
        if margin > 0 and margin < 1 then
          margin_x, margin_y = math.floor(screen_w * margin), math.floor(screen_h * margin)
        else
          margin_x, margin_y = margin, margin
        end
        local scale_x = (screen_w - margin_x) / self.w
        local scale_y = (screen_h - margin_y) / self.h
        self.scale = math.min(scale_x, scale_y)
        local real_w = self.w * self.scale
        local real_h = self.h * self.scale
        self.offset_x = math.floor((screen_w - real_w) / 2)
        self.offset_y = math.floor((screen_h - real_h) / 2)
        self.crop = true
        return 
      end
      return error("don't know how to create viewport")
    end,
    __base = _base_0,
    __name = "Viewport",
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
  Viewport = _class_0
end
local EffectViewport
do
  local _class_0
  local _parent_0 = Viewport
  local _base_0 = {
    __tostring = Viewport.__tostring,
    shake = function(self, dur, ...)
      if dur == nil then
        dur = 0.4
      end
      return self.effects:add(ShakeEffect(dur, ...))
    end,
    update = function(self, dt)
      return self.effects:update(dt)
    end,
    apply = function(self)
      _class_0.__parent.__base.apply(self)
      local _list_0 = self.effects
      for _index_0 = 1, #_list_0 do
        local e = _list_0[_index_0]
        e:before()
      end
    end,
    pop = function(self)
      local _list_0 = self.effects
      for _index_0 = 1, #_list_0 do
        local e = _list_0[_index_0]
        e:after()
      end
      return _class_0.__parent.__base.pop(self)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      self.effects = EffectList()
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "EffectViewport",
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
  EffectViewport = _class_0
end
local TiledBackground
do
  local _class_0
  local _base_0 = {
    draw = function(self, ox, oy)
      if ox then
        self.ox = ox
      end
      if oy then
        self.oy = oy
      end
      ox = self.ox % self.tile_w
      oy = self.oy % self.tile_h
      return self.img:draw(self.quad, -ox, -oy)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, image, viewport)
      self.ox = 0
      self.oy = 0
      do
        local _with_0 = imgfy(image)
        _with_0:set_wrap("repeat", "repeat")
        self.img = _with_0
      end
      self.tile_w, self.tile_h = self.img:width(), self.img:height()
      self.quad = graphics.newQuad(0, 0, viewport.screen.w + self.tile_w, viewport.screen.h + self.tile_h, self.tile_w, self.tile_h)
    end,
    __base = _base_0,
    __name = "TiledBackground"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  TiledBackground = _class_0
end
return {
  Viewport = Viewport,
  EffectViewport = EffectViewport,
  TiledBackground = TiledBackground
}
