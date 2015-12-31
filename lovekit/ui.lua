local max
max = math.max
local g
g = love.graphics
local Box
Box = require("lovekit.geometry").Box
local COLOR
COLOR = require("lovekit.color").COLOR
local Sequence
Sequence = require("lovekit.sequence").Sequence
local EffectList
EffectList = require("lovekit.lists").EffectList
local extract_props
extract_props = function(self, items)
  if not (items) then
    return 
  end
  for k, v in pairs(items) do
    if type(k) == "string" then
      items[k] = nil
      self[k] = v
    end
  end
end
local border = {
  tl = 0,
  l = 1,
  t = 2,
  tr = 3,
  bl = 4,
  r = 5,
  b = 6,
  br = 7,
  back = 8
}
local Frame
do
  local _class_0
  local _parent_0 = Box
  local _base_0 = {
    shadow = true,
    draw = function(self)
      local x, y, w, h
      x, y, w, h = self.x, self.y, self.w, self.h
      w = max(w, self.border_size * 2)
      h = max(h, self.border_size * 2)
      local x2 = x + w - self.border_size
      local y2 = y + h - self.border_size
      local s = self.border_size
      local s2 = s * 2
      if self.shadow then
        COLOR:push(0, 0, 0, 64)
        g.rectangle("fill", x + 1, y + 1, w, h)
        COLOR:pop()
      end
      do
        local _with_0 = self.sprite
        _with_0:draw_cell(border.tl, x, y)
        _with_0:draw_cell(border.tr, x2, y)
        _with_0:draw_cell(border.bl, x, y2)
        _with_0:draw_cell(border.br, x2, y2)
        _with_0:draw_sized(border.t, x + s, y, w - s2, s)
        _with_0:draw_sized(border.b, x + s, y2, w - s2, s)
        _with_0:draw_sized(border.l, x, y + s, s, h - s2)
        _with_0:draw_sized(border.r, x2, y + s, s, h - s2)
        _with_0:draw_sized(border.back, x + s, y + s, w - s2, h - s2)
        return _with_0
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, sprite, ...)
      self.sprite = sprite
      self.border_size = self.sprite.cell_w
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Frame",
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
  Frame = _class_0
end
local Label
do
  local _class_0
  local _parent_0 = Box
  local _base_0 = {
    alive = true,
    align = "left",
    set_max_width = function(self, max_width, align)
      self.align = align
      if max_width == self.max_width then
        return 
      end
      self.max_width = max_width
      if not (self.is_func) then
        return self:_set_size(self.text)
      end
    end,
    set_text = function(self, text)
      self.text = text
      self.is_func = type(self.text) == "function"
      if not (self.is_func) then
        self:_set_size(self.text)
      end
      return self:_update_from_fun()
    end,
    _set_size = function(self, text)
      local font = g.getFont()
      self.w = font:getWidth(text)
      if self.max_width then
        self.w = math.min(self.max_width, self.w)
        local lines
        self.w, lines = font:getWrap(text, self.max_width)
        self.h = #lines * font:getHeight()
      else
        self.h = font:getHeight()
      end
    end,
    _update_from_fun = function(self)
      if self.is_func then
        self._text = self:text()
        return self:_set_size(self._text)
      end
    end,
    update = function(self, dt)
      self:_update_from_fun()
      return self.alive
    end,
    draw = function(self)
      if self.color then
        COLOR:push(unpack(self.color))
      end
      local text = self.is_func and self._text or self.text
      if self.max_width then
        g.printf(text, self.x, self.y, self.max_width, self.align)
      else
        g.print(text, self.x, self.y)
      end
      if self.color then
        return COLOR:pop()
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, text, x, y)
      if x == nil then
        x = 0
      end
      if y == nil then
        y = 0
      end
      self.x, self.y = x, y
      return self:set_text(text)
    end,
    __base = _base_0,
    __name = "Label",
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
  Label = _class_0
end
local AnimatedLabel
do
  local _class_0
  local _parent_0 = Label
  local _base_0 = {
    update = function(self, dt)
      self.effects:update(dt)
      return _class_0.__parent.__base.update(self, dt)
    end,
    draw = function(self)
      local text = self.is_func and self._text or self.text
      local hw = self.w / 2
      local hh = self.h / 2
      g.push()
      g.translate(self.x + hw, self.y + hh)
      self.effects:before()
      g.print(text, -hw, -hh)
      self.effects:after()
      return g.pop()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      _class_0.__parent.__init(self, ...)
      self.effects = EffectList()
    end,
    __base = _base_0,
    __name = "AnimatedLabel",
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
  AnimatedLabel = _class_0
end
local BlinkingLabel
do
  local _class_0
  local _parent_0 = Label
  local _base_0 = {
    rate = 1.2,
    duty = 0.8,
    elapsed = 0,
    update = function(self, dt)
      self.elapsed = self.elapsed + dt
      return _class_0.__parent.__base.update(self, dt)
    end,
    draw = function(self)
      local scaled = self.elapsed / self.rate
      local p = scaled - math.floor(scaled)
      if p <= self.duty then
        return _class_0.__parent.__base.draw(self)
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "BlinkingLabel",
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
  BlinkingLabel = _class_0
end
local RevealLabel
do
  local _class_0
  local _parent_0 = Label
  local _base_0 = {
    rate = 0.03,
    fixed_size = false,
    update = function(self, dt)
      if self.seq then
        self.seq:update(dt)
      end
      return _class_0.__parent.__base.update(self, dt)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, text, x, y, fn)
      self.x, self.y = x, y
      self.chr = 0
      self:set_text(function()
        return text:sub(1, self.chr)
      end)
      self.seq = Sequence(function()
        while self.chr < #text do
          self.chr = self.chr + 1
          wait(self.rate)
        end
        self.done = true
        self.seq = nil
        if fn then
          return fn(self)
        end
      end)
      if type(fn) == "table" then
        for k, v in pairs(fn) do
          if type(k) == "string" then
            self[k] = v
          end
        end
        fn = fn[1]
      end
      if self.fixed_size then
        self._set_size = function(self)
          return RevealLabel._set_size(self, text)
        end
      end
    end,
    __base = _base_0,
    __name = "RevealLabel",
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
  RevealLabel = _class_0
end
local BaseList
do
  local _class_0
  local _parent_0 = Box
  local _base_0 = {
    padding = 5,
    xalign = "left",
    yalign = "top",
    w = 0,
    h = 0,
    update_size = function()
      return error("override me")
    end,
    update = function(self, dt, ...)
      local _list_0 = self.items
      for _index_0 = 1, #_list_0 do
        local item = _list_0[_index_0]
        if item.update then
          item:update(dt, ...)
        end
      end
      self:update_size()
      return true
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y, items)
      if items == nil then
        items = { }
      end
      self.x, self.y, self.items = x, y, items
      if type(self.x) == "table" then
        self.items = self.x
        self.x = 0
        self.y = 0
      end
      return extract_props(self, self.items)
    end,
    __base = _base_0,
    __name = "BaseList",
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
  BaseList = _class_0
end
local VList
do
  local _class_0
  local _parent_0 = BaseList
  local _base_0 = {
    update_size = function(self)
      self.w, self.h = 0, 0
      local _list_0 = self.items
      for _index_0 = 1, #_list_0 do
        local item = _list_0[_index_0]
        self.h = self.h + (item.h + self.padding)
        if item.w > self.w then
          self.w = item.w
        end
      end
      if self.h > 0 then
        self.h = self.h - self.padding
      end
    end,
    draw = function(self)
      local x, y, w, xalign
      x, y, w, xalign = self.x, self.y, self.w, self.xalign
      local _list_0 = self.items
      for _index_0 = 1, #_list_0 do
        local item = _list_0[_index_0]
        if xalign == "right" then
          item.x = x + w - item.w
        elseif xalign == "center" then
          item.x = x + (w - item.w) / 2
        else
          item.x = x
        end
        item.y = y
        y = y + (self.padding + item.h)
        item:draw()
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "VList",
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
  VList = _class_0
end
local HList
do
  local _class_0
  local _parent_0 = BaseList
  local _base_0 = {
    update_size = function(self)
      self.w, self.h = 0, 0
      local _list_0 = self.items
      for _index_0 = 1, #_list_0 do
        local item = _list_0[_index_0]
        self.w = self.w + (item.w + self.padding)
        if item.h > self.h then
          self.h = item.h
        end
      end
      if self.w > 0 then
        self.w = self.w - self.padding
      end
    end,
    draw = function(self)
      local x, y, h, yalign
      x, y, h, yalign = self.x, self.y, self.h, self.yalign
      local _list_0 = self.items
      for _index_0 = 1, #_list_0 do
        local item = _list_0[_index_0]
        item.x = x
        if yalign == "bottom" then
          item.y = y + h - item.h
        elseif yalign == "center" then
          item.y = y + (h - item.h) / 2
        else
          item.y = y
        end
        x = x + (self.padding + item.w)
        item:draw()
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "HList",
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
  HList = _class_0
end
local Anchor
do
  local _class_0
  local _parent_0 = Box
  local _base_0 = {
    w = 0,
    h = 0,
    update = function(self, ...)
      do
        local _with_0 = self.item:update(...)
        local _exp_0 = self.xalign
        if "right" == _exp_0 then
          self.item.x = self.x - self.item.w
        elseif "center" == _exp_0 then
          self.item.x = self.x - self.item.w / 2
        else
          self.item.x = self.x
        end
        local _exp_1 = self.yalign
        if "bottom" == _exp_1 then
          self.item.y = self.y - self.item.h
        elseif "center" == _exp_1 then
          self.item.y = self.y - self.item.h / 2
        else
          self.item.y = self.y
        end
        return _with_0
      end
    end,
    draw = function(self)
      return self.item:draw()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y, item, xalign, yalign)
      if yalign == nil then
        yalign = xalign
      end
      self.x, self.y, self.item, self.xalign, self.yalign = x, y, item, xalign, yalign
    end,
    __base = _base_0,
    __name = "Anchor",
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
  Anchor = _class_0
end
local CenterAnchor
do
  local _class_0
  local _parent_0 = Anchor
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y, item)
      return _class_0.__parent.__init(self, x, y, item, "center")
    end,
    __base = _base_0,
    __name = "CenterAnchor",
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
  CenterAnchor = _class_0
end
local Bin
do
  local _class_0
  local _parent_0 = Box
  local _base_0 = {
    xalign = 0.5,
    yalign = 0.5,
    update = function(self, ...)
      do
        local _with_0 = self.item:update(...)
        self.item.x = math.floor(self.x + (self.w - self.item.w) * self.xalign)
        self.item.y = math.floor(self.y + (self.h - self.item.h) * self.yalign)
        return _with_0
      end
    end,
    draw = function(self)
      return self.item:draw()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y, w, h, item, xalign, yalign)
      self.item, self.xalign, self.yalign = item, xalign, yalign
      return _class_0.__parent.__init(self, x, y, w, h)
    end,
    __base = _base_0,
    __name = "Bin",
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
  Bin = _class_0
end
local Group
do
  local _class_0
  local _parent_0 = Box
  local _base_0 = {
    update = function(self, dt)
      self.x = 0
      self.y = 0
      self.w = 0
      self.h = 0
      local _list_0 = self.items
      for _index_0 = 1, #_list_0 do
        local item = _list_0[_index_0]
        item:update(dt)
        self:add_box(item)
      end
    end,
    draw = function(self, ...)
      local _list_0 = self.items
      for _index_0 = 1, #_list_0 do
        local item = _list_0[_index_0]
        item:draw(...)
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, items)
      if items == nil then
        items = { }
      end
      self.items = items
    end,
    __base = _base_0,
    __name = "Group",
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
  Group = _class_0
end
local Border
do
  local _class_0
  local _parent_0 = Box
  local _base_0 = {
    padding = 0,
    border = true,
    background = false,
    update = function(self, dt)
      self.w = self.item.w + self.padding * 2
      self.h = self.item.h + self.padding * 2
      if self.min_width then
        self.w = math.max(self.min_width, self.w)
      end
      return self.item:update(dt)
    end,
    draw = function(self)
      if self.border then
        g.rectangle("line", self:unpack())
      end
      if self.background then
        COLOR:push(unpack(self.background))
        g.rectangle("fill", self:unpack())
        COLOR:pop()
      end
      self.item.x = self.x + self.padding
      self.item.y = self.y + self.padding
      return self.item:draw()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, item, props)
      self.item = item
      extract_props(self, props)
      return _class_0.__parent.__init(self, self.item.x, self.item.y, self.item.w, self.item.h)
    end,
    __base = _base_0,
    __name = "Border",
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
  Border = _class_0
end
return {
  Frame = Frame,
  Label = Label,
  AnimatedLabel = AnimatedLabel,
  BlinkingLabel = BlinkingLabel,
  RevealLabel = RevealLabel,
  VList = VList,
  HList = HList,
  Anchor = Anchor,
  CenterAnchor = CenterAnchor,
  Bin = Bin,
  Group = Group,
  Border = Border
}
