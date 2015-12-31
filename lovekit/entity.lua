local Box, Vec2d, ceil, floor
do
  local _obj_0 = require("lovekit.geometry")
  Box, Vec2d, ceil, floor = _obj_0.Box, _obj_0.Vec2d, _obj_0.ceil, _obj_0.floor
end
local Entity
do
  local _class_0
  local _parent_0 = Box
  local _base_0 = {
    w = 20,
    h = 20,
    loc = function(self)
      return Vec2d(self.x, self.y)
    end,
    update = function(self, dt, world)
      local dx, dy
      do
        local _obj_0 = self.vel
        dx, dy = _obj_0[1], _obj_0[2]
      end
      dx = dx * dt
      dy = dy * dt
      return self:fit_move(dx, dy, world)
    end,
    on_stuck = function(self)
      return print("on_stuck: " .. self.__class.__name)
    end,
    direction_name = function(self, default_dir, v)
      if default_dir == nil then
        default_dir = "down"
      end
      if v == nil then
        v = self.vel
      end
      local base
      if v:is_zero() then
        base = "stand"
      else
        self.last_direction = v:direction_name()
        base = "walk"
      end
      local dir = self.last_direction or default_dir
      return base .. "_" .. dir
    end,
    fit_move = function(self, dx, dy, world, box)
      if box == nil then
        box = self
      end
      local collided_x = false
      local collided_y = false
      if world:collides(self) then
        return self:on_stuck()
      end
      if dx > 0 then
        local start = box.x
        box.x = box.x + dx
        if world:collides(self) then
          collided_x = true
          box.x = floor(box.x)
          while world:collides(self) do
            box.x = box.x - 1
          end
        end
      elseif dx < 0 then
        local start = box.x
        box.x = box.x + dx
        if world:collides(self) then
          collided_x = true
          box.x = ceil(box.x)
          while world:collides(self) do
            box.x = box.x + 1
          end
        end
      end
      if dy > 0 then
        local start = box.y
        box.y = box.y + dy
        if world:collides(self) then
          collided_y = true
          box.y = floor(box.y)
          while world:collides(self) do
            box.y = box.y - 1
          end
        end
      elseif dy < 0 then
        local start = box.y
        box.y = box.y + dy
        if world:collides(self) then
          collided_y = true
          box.y = ceil(box.y)
          while world:collides(self) do
            box.y = box.y + 1
          end
        end
      end
      return collided_x, collided_y
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      _class_0.__parent.__init(self, ...)
      self.vel = Vec2d(0, 0)
    end,
    __base = _base_0,
    __name = "Entity",
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
  Entity = _class_0
end
local PlatformEntity
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    w = 20,
    h = 20,
    update = function(self, dt)
      self.velocity = self.velocity + (self.world.gravity * dt)
      local cx, cy = self:fit_move(unpack(self.velocity * dt))
      if cy then
        if self.velocity[2] > 0 then
          self.on_ground = true
        end
        self.velocity[2] = 0
      else
        if math.floor(self.velocity[2] * dt) ~= 0 then
          self.on_ground = false
        end
      end
      return true
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, world, x, y)
      self.world = world
      self.facing = "right"
      self.on_ground = false
      self.velocity = Vec2d(0, 0)
      self.box = Box(x, y, self.w, self.h)
    end,
    __base = _base_0,
    __name = "PlatformEntity",
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
  PlatformEntity = _class_0
end
return {
  Entity = Entity,
  PlatformEntity = PlatformEntity
}
