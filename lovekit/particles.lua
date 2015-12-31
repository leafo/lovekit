local g
g = love.graphics
local Sequence
Sequence = require("lovekit.sequence").Sequence
local COLOR
COLOR = require("lovekit.color").COLOR
local Vec2d
Vec2d = require("lovekit.geometry").Vec2d
local ad_curve
ad_curve = require("lovekit.support").ad_curve
local Emitter
do
  local _class_0
  local _parent_0 = Sequence
  local _base_0 = {
    y = 0,
    alive = true,
    duration = 0.2,
    count = 5,
    attach = function(self, fn)
      self.attached_fn = fn
    end,
    update = function(self, dt)
      if self.attached_fn then
        self:attached_fn(dt)
      end
      return _class_0.__parent.__base.update(self, dt)
    end,
    draw = function(self) end,
    make_particle = function(self)
      return error("implement me")
    end,
    add_particle = function(self)
      return self.world.particles:add(self:make_particle(self.x, self.y))
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, world, x, y, duration, count, make_particle, callback)
      self.world, self.x, self.y, self.duration, self.count, self.make_particle = world, x, y, duration, count, make_particle
      count = self.count
      local dt = self.duration / count
      return _class_0.__parent.__init(self, function()
        while count > 0 do
          count = count - 1
          self:add_particle()
          wait(dt)
        end
        if callback then
          return callback()
        end
      end)
    end,
    __base = _base_0,
    __name = "Emitter",
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
  Emitter = _class_0
end
local ForeverEmitter
do
  local _class_0
  local _parent_0 = Emitter
  local _base_0 = {
    rate = 0.05
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, world, x, y, rate, make_particle)
      self.world, self.x, self.y, self.rate, self.make_particle = world, x, y, rate, make_particle
      return Sequence.__init(self, function()
        while true do
          self:add_particle()
          wait(self.rate)
        end
      end)
    end,
    __base = _base_0,
    __name = "ForeverEmitter",
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
  ForeverEmitter = _class_0
end
local Particle
do
  local _class_0
  local _base_0 = {
    life = 1.0,
    r = 255,
    g = 255,
    b = 255,
    a = 1,
    update = function(self, dt)
      self.life = self.life - dt
      self.vel:adjust(unpack(self.accel * dt))
      self.x = self.x + (self.vel.x * dt)
      self.y = self.y + (self.vel.y * dt)
      return self.life > 0
    end,
    p = function(self)
      return 1 - self.life / self.__class.life
    end,
    fade_out = function(self, after)
      if after == nil then
        after = 0.5
      end
      local p = self:p()
      if p > after then
        return 1 - (p - after) / (1 - after)
      else
        return 1
      end
    end,
    fade_in = function(self, before)
      if before == nil then
        before = 0.5
      end
      local p = self:p()
      if p < before then
        return p / before
      else
        return 1
      end
    end,
    draw = function(self) end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y, vel, accel)
      if vel == nil then
        vel = Vec2d(0, 0)
      end
      if accel == nil then
        accel = Vec2d(0, 0)
      end
      self.x, self.y, self.vel, self.accel = x, y, vel, accel
      self.life = self.__class.life
    end,
    __base = _base_0,
    __name = "Particle"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Particle = _class_0
end
local PixelParticle
do
  local _class_0
  local _parent_0 = Particle
  local _base_0 = {
    size = 2,
    draw = function(self)
      local half = self.size / 2
      COLOR:push(self.r, self.g, self.b, self.a * 255)
      g.rectangle("fill", self.x - half, self.y - half, self.size, self.size)
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
    __name = "PixelParticle",
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
  PixelParticle = _class_0
end
local ImageParticle
do
  local _class_0
  local _parent_0 = Particle
  local _base_0 = {
    dspin = 0,
    dscale = 0,
    w = 0,
    h = 0,
    sprite = nil,
    quad = nil,
    update = function(self, dt, ...)
      self.spin = self.spin + (dt * self.dspin)
      self.scale = self.scale + (dt * self.dscale)
      return _class_0.__parent.__base.update(self, dt, ...)
    end,
    draw = function(self)
      COLOR:pusha(ad_curve(self:p(), 0, 0.1, 0.5) * (self.a * 255))
      g.push()
      g.translate(self.x, self.y)
      g.rotate(self.spin)
      g.scale(self.scale, self.scale)
      if self.quad then
        self.sprite:draw(self.quad, -self.w / 2, -self.h / 2)
      else
        self.sprite:draw(-self.w / 2, -self.h / 2)
      end
      g.pop()
      return COLOR:pop()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      _class_0.__parent.__init(self, ...)
      self.spin = 0
      self.scale = 1
    end,
    __base = _base_0,
    __name = "ImageParticle",
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
  ImageParticle = _class_0
end
local TextParticle
do
  local _class_0
  local _parent_0 = Particle
  local _base_0 = {
    dspin = 0,
    dscale = 0,
    color = {
      255,
      255,
      255
    },
    update = function(self, dt, ...)
      self.spin = self.spin + (dt * self.dspin)
      self.scale = self.scale + (dt * self.dscale)
      return _class_0.__parent.__base.update(self, dt, ...)
    end,
    draw = function(self)
      COLOR:push(self.color[1], self.color[2], self.color[3], ad_curve(self:p(), 0, 0.1, 0.5) * 255)
      g.push()
      g.translate(self.x, self.y)
      g.rotate(self.spin)
      g.scale(self.scale, self.scale)
      g.print(self.str, -self.w / 2, -self.h / 2)
      g.pop()
      return COLOR:pop()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, str, ...)
      self.str = str
      _class_0.__parent.__init(self, ...)
      self.spin = 0
      self.scale = 1
      local font = g.getFont()
      self.w = font:getWidth(self.str)
      self.h = font:getHeight()
    end,
    __base = _base_0,
    __name = "TextParticle",
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
  TextParticle = _class_0
end
local TextEmitter
do
  local _class_0
  local _parent_0 = Emitter
  local _base_0 = {
    count = 1,
    make_particle = function(self, ...)
      return TextParticle(self.str, ...)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, str, ...)
      self.str = str
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "TextEmitter",
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
  TextEmitter = _class_0
end
return {
  Emitter = Emitter,
  Particle = Particle,
  PixelParticle = PixelParticle,
  ImageParticle = ImageParticle,
  TextParticle = TextParticle,
  TextEmitter = TextEmitter,
  ForeverEmitter = ForeverEmitter
}
