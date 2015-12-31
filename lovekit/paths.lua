local graphics
graphics = love.graphics
local Vec2d
Vec2d = require("lovekit.geometry").Vec2d
local COLOR
COLOR = require("lovekit.color").COLOR
local hermite_interpolate
do
  local h00
  h00 = function(t, t2, t3)
    return 2 * t3 - 3 * t2 + 1
  end
  local h10
  h10 = function(t, t2, t3)
    return t3 - 2 * t2 + t
  end
  local h01
  h01 = function(t, t2, t3)
    return -2 * t3 + 3 * t2
  end
  local h11
  h11 = function(t, t2, t3)
    return t3 - t2
  end
  hermite_interpolate = function(p1, p2, m1, m2, t)
    local t2 = t * t
    local t3 = t2 * t
    return p1 * h00(t, t2, t3) + m1 * h10(t, t2, t3) + p2 * h01(t, t2, t3) + m2 * h11(t, t2, t3)
  end
end
local PathWalker
do
  local _class_0
  local _base_0 = {
    reset = function(self, i, t)
      if i == nil then
        i = 1
      end
      if t == nil then
        t = 0
      end
      self.i, self.t = i, t
      if not (self.points[self.i + 3]) then
        return false
      end
      self.p1 = Vec2d(unpack(self.points[self.i + 1]))
      self.p2 = Vec2d(unpack(self.points[self.i + 2]))
      self.duration = math.abs((self.p2 - self.p1):len())
      self.x, self.y = unpack(self.p1)
      return true
    end,
    update = function(self, dt)
      self.t = self.t + (dt * self.speed)
      local p
      while true do
        p = self.t / self.duration
        if p <= 1 then
          break
        end
        if not (self:reset(self.i + 1, self.t - self.duration)) then
          print("Finished")
          self:reset()
        end
      end
      self.x, self.y = unpack(self.points:interpolate(self.i + 1, p))
      return self.x, self.y
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, points, speed)
      self.points, self.speed = points, speed
      return self:reset()
    end,
    __base = _base_0,
    __name = "PathWalker"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  PathWalker = _class_0
end
local CatmullRomPath
do
  local _class_0
  local _base_0 = {
    add = function(self, x, y)
      return table.insert(self, {
        x,
        y
      })
    end,
    pop = function(self)
      self[#self] = nil
    end,
    draw_pair = function(self, i)
      local p1, p2, m1, m2 = self:interpolation_parts(i)
      local d = math.abs((p2 - p1):len() / 10)
      for t = 0, 1, 1 / d do
        graphics.point(unpack(hermite_interpolate(p1, p2, m1, m2, t)))
      end
    end,
    interpolation_parts = function(self, i)
      local p0 = Vec2d(unpack(self[i - 1]))
      local p1 = Vec2d(unpack(self[i]))
      local p2 = Vec2d(unpack(self[i + 1]))
      local p3 = Vec2d(unpack(self[i + 2]))
      local m1 = (p2 - p0) * 0.5
      local m2 = (p3 - p1) * 0.5
      return p1, p2, m1, m2
    end,
    interpolate = function(self, i, t)
      local p1, p2, m1, m2 = self:interpolation_parts(i)
      return hermite_interpolate(p1, p2, m1, m2, t)
    end,
    walker = function(self, speed)
      return PathWalker(self, speed)
    end,
    each_pt = function(self, rate)
      if rate == nil then
        rate = 1
      end
      if not (#self >= 4) then
        return 
      end
      return coroutine.wrap(function()
        for i = 2, #self - 2 do
          local p1, p2, m1, m2 = self:interpolation_parts(i)
          local d = math.abs((p2 - p1):len() / 10)
          for t = 0, 1, 1 / d * rate do
            coroutine.yield(unpack(hermite_interpolate(p1, p2, m1, m2, t)))
          end
        end
      end)
    end,
    draw = function(self)
      local pt = graphics.getPointSize()
      graphics.setPointSize(4)
      if #self >= 4 then
        COLOR:push(255, 100, 100)
        for i = 2, #self - 2 do
          self:draw_pair(i)
        end
        COLOR:pop()
      end
      for _index_0 = 1, #self do
        local _des_0 = self[_index_0]
        local x, y
        x, y = _des_0[1], _des_0[2]
        graphics.point(x, y)
      end
      return graphics.setPointSize(pt)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self) end,
    __base = _base_0,
    __name = "CatmullRomPath"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  CatmullRomPath = _class_0
end
return {
  hermite_interpolate = hermite_interpolate,
  PathWalker = PathWalker,
  CatmullRomPath = CatmullRomPath
}
