local graphics, timer
do
  local _obj_0 = love
  graphics, timer = _obj_0.graphics, _obj_0.timer
end
local Sequence
Sequence = require("lovekit.sequence").Sequence
local COLOR
COLOR = require("lovekit.color").COLOR
local Effect
do
  local _class_0
  local _base_0 = {
    update = function(self, dt)
      self.time = self.time + dt
      do
        local alive = self.time < self.duration
        if not alive and self.callback then
          self:callback(self)
          self.callback = nil
        end
        return alive
      end
    end,
    p = function(self)
      return math.min(1, self.time / self.duration)
    end,
    replace = function(self, other) end,
    before = function(self, object) end,
    after = function(self, object) end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, duration, callback)
      if duration == nil then
        duration = 1
      end
      self.duration, self.callback = duration, callback
      self.time = 0
    end,
    __base = _base_0,
    __name = "Effect"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Effect = _class_0
end
local ScaleEffect
do
  local _class_0
  local _parent_0 = Sequence
  local _base_0 = {
    before = function(self, object)
      local tx, ty = object:center()
      graphics.push()
      graphics.translate(tx, ty)
      graphics.scale(self.scale, self.scale)
      return graphics.translate(-tx, -ty)
    end,
    after = function(self, object)
      return graphics.pop()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "ScaleEffect",
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
  ScaleEffect = _class_0
end
local PopinEffect
do
  local _class_0
  local _parent_0 = ScaleEffect
  local _base_0 = {
    scale = 0
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, duration, callback)
      return _class_0.__parent.__init(self, function()
        tween(self, duration * 0.8, {
          scale = 1.2
        })
        tween(self, duration * 0.2, {
          scale = 1
        })
        return callback and callback(self)
      end)
    end,
    __base = _base_0,
    __name = "PopinEffect",
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
  PopinEffect = _class_0
end
local BlowOutEffect
do
  local _class_0
  local _parent_0 = Sequence
  local _base_0 = {
    scale = 1,
    alpha = 255,
    before = function(self, object)
      COLOR:pusha(self.alpha)
      return ScaleEffect.before(self, object)
    end,
    after = function(self, object)
      ScaleEffect.after(self, object)
      return COLOR:pop()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, duration, callback)
      return _class_0.__parent.__init(self, function()
        tween(self, duration, {
          scale = 2.0,
          alpha = 0
        })
        return callback and callback(self)
      end)
    end,
    __base = _base_0,
    __name = "BlowOutEffect",
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
  BlowOutEffect = _class_0
end
local ShakeEffect
do
  local _class_0
  local _parent_0 = Effect
  local _base_0 = {
    before = function(self)
      local p = self:p()
      local t = (timer.getTime() - self.start) * self.speed
      graphics.push()
      local decay = (1 - p) * 2
      return graphics.translate(self.amount * decay * math.sin(t * 10 + self.rand), self.amount * decay * math.cos(t * 11 + self.rand))
    end,
    after = function(self)
      return graphics.pop()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, duration, speed, amount, ...)
      if speed == nil then
        speed = 5
      end
      if amount == nil then
        amount = 1
      end
      self.speed, self.amount = speed, amount
      self.start = timer.getTime()
      self.rand = love.math.random() * math.pi
      return _class_0.__parent.__init(self, duration, ...)
    end,
    __base = _base_0,
    __name = "ShakeEffect",
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
  ShakeEffect = _class_0
end
local ColorEffect
do
  local _class_0
  local _parent_0 = Sequence
  local _base_0 = {
    replace = function(self, other) end,
    before = function(self)
      if self.color then
        return COLOR:push(unpack(self.color))
      end
    end,
    after = function(self)
      if self.color then
        return COLOR:pop()
      end
    end,
    update = function(self, ...)
      do
        local alive = _class_0.__parent.__base.update(self, ...)
        if not alive and self.callback then
          self:callback(self)
          self.callback = nil
        end
        return alive
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
    __name = "ColorEffect",
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
  ColorEffect = _class_0
end
local FlashEffect
do
  local _class_0
  local _parent_0 = ColorEffect
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, duration, color, callback)
      if duration == nil then
        duration = 0.2
      end
      if color == nil then
        color = {
          255,
          100,
          100
        }
      end
      self.callback = callback
      local half = duration / 2
      return _class_0.__parent.__init(self, function()
        local start = {
          graphics.getColor()
        }
        self.color = {
          unpack(start)
        }
        tween(self.color, half, color)
        return tween(self.color, half, start)
      end)
    end,
    __base = _base_0,
    __name = "FlashEffect",
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
  FlashEffect = _class_0
end
local FadeInEffect
do
  local _class_0
  local _parent_0 = Effect
  local _base_0 = {
    before = function(self)
      return COLOR:pusha(self:p() * 255)
    end,
    after = function(self)
      return COLOR:pop()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "FadeInEffect",
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
  FadeInEffect = _class_0
end
local FadeOutEffect
do
  local _class_0
  local _parent_0 = Effect
  local _base_0 = {
    before = function(self)
      return COLOR:pusha((1 - self:p()) * 255)
    end,
    after = function(self)
      return COLOR:pop()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "FadeOutEffect",
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
  FadeOutEffect = _class_0
end
return {
  Effect = Effect,
  ShakeEffect = ShakeEffect,
  ColorEffect = ColorEffect,
  FlashEffect = FlashEffect,
  PopinEffect = PopinEffect,
  FadeInEffect = FadeInEffect,
  FadeOutEffect = FadeOutEffect,
  BlowOutEffect = BlowOutEffect
}
