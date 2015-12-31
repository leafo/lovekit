local rectangle, line
do
  local _obj_0 = love.graphics
  rectangle, line = _obj_0.rectangle, _obj_0.line
end
local atan2, cos, sin, random, abs
do
  local _obj_0 = math
  atan2, cos, sin, random, abs = _obj_0.atan2, _obj_0.cos, _obj_0.sin, _obj_0.random, _obj_0.abs
end
local type, pairs, ipairs
do
  local _obj_0 = _G
  type, pairs, ipairs = _obj_0.type, _obj_0.pairs, _obj_0.ipairs
end
local _floor, _ceil, _deg, _rad
do
  local _obj_0 = math
  _floor, _ceil, _deg, _rad = _obj_0.floor, _obj_0.ceil, _obj_0.deg, _obj_0.rad
end
local COLOR
COLOR = require("lovekit.color").COLOR
local floor
floor = function(n)
  if n < 0 then
    return -_floor(-n)
  else
    return _floor(n)
  end
end
local ceil
ceil = function(n)
  if n < 0 then
    return -_ceil(-n)
  else
    return _ceil(n)
  end
end
local Vec2d
do
  local _class_0
  local base
  local _base_0 = {
    angle = function(self)
      return _deg(atan2(self[2], self[1]))
    end,
    radians = function(self)
      return atan2(self[2], self[1])
    end,
    len = function(self)
      local n = self[1] ^ 2 + self[2] ^ 2
      if n == 0 then
        return 0
      end
      return math.sqrt(n)
    end,
    cap = function(self, len)
      local _len = self:len()
      if _len > len then
        self[1] = self[1] / _len * len
        self[2] = self[2] / _len * len
      end
      return self
    end,
    dup = function(self)
      return Vec2d(unpack(self))
    end,
    is_zero = function(self)
      return self[1] == 0 and self[2] == 0
    end,
    left = function(self)
      return self[1] < 0
    end,
    right = function(self)
      return self[1] > 0
    end,
    update = function(self, x, y)
      self[1], self[2] = x, y
      return self
    end,
    adjust = function(self, dx, dy)
      self[1] = self[1] + dx
      self[2] = self[2] + dy
      return self
    end,
    normalized = function(self)
      local len = self:len()
      if len == 0 then
        return Vec2d()
      else
        return Vec2d(self[1] / len, self[2] / len)
      end
    end,
    cross = function(self)
      return Vec2d(-self[2], self[1])
    end,
    flip = function(self)
      return Vec2d(-self[1], -self[2])
    end,
    truncate = function(self, max_len)
      local l = self:len()
      if l > max_len then
        self[1] = self[1] / l * max_len
        self[2] = self[2] / l * max_len
      end
    end,
    direction_name = (function()
      local _direction_names = {
        "up",
        "right",
        "down",
        "left"
      }
      return function(self, names)
        if names == nil then
          names = _direction_names
        end
        if abs(self[1]) > abs(self[2]) then
          if self[1] < 0 then
            return names[4]
          else
            return names[2]
          end
        else
          if self[2] < 0 then
            return names[1]
          else
            return names[3]
          end
        end
      end
    end)(),
    rotate = function(self, rads)
      local x, y
      x, y = self[1], self[2]
      local c, s = cos(rads), sin(rads)
      return Vec2d(x * c - y * s, y * c + x * s)
    end,
    random_heading = function(self, spread, r)
      if spread == nil then
        spread = 10
      end
      if r == nil then
        r = random()
      end
      local offset = (r - 0.5) * spread
      return self:rotate(_rad(offset))
    end,
    primary_direction = function(self)
      local x, y
      x, y = self[1], self[2]
      if x == 0 and y == 0 then
        return Vec2d(0, 0)
      end
      local xx = math.abs(x)
      local yy = math.abs(y)
      if xx > yy then
        if x < 0 then
          return Vec2d(-1, 0)
        else
          return Vec2d(1, 0)
        end
      else
        if y < 0 then
          return Vec2d(0, -1)
        else
          return Vec2d(0, 1)
        end
      end
    end,
    __mul = function(left, right)
      if type(left) == "number" then
        return Vec2d(left * right[1], left * right[2])
      else
        if type(right) ~= "number" then
          return left[1] * right[1] + left[2] * right[2]
        else
          return Vec2d(left[1] * right, left[2] * right)
        end
      end
    end,
    __div = function(left, right)
      if type(left) == "number" then
        error("vector division undefined")
      end
      return Vec2d(left[1] / right, left[2] / right)
    end,
    __add = function(self, other)
      return Vec2d(self[1] + other[1], self[2] + other[2])
    end,
    __sub = function(self, other)
      return Vec2d(self[1] - other[1], self[2] - other[2])
    end,
    __tostring = function(self)
      return ("vec2d<%f, %f>"):format(self[1], self[2])
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Vec2d"
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
  base = self.__base
  self.__base.__index = function(self, name)
    if name == "x" then
      return self[1]
    elseif name == "y" then
      return self[2]
    else
      return base[name]
    end
  end
  do
    local __base
    __base = self.__base
    getmetatable(self).__call = function(cls, x, y)
      return setmetatable({
        x or 0,
        y or 0
      }, __base)
    end
  end
  self.from_angle = function(deg)
    local theta = _rad(deg)
    return Vec2d(cos(theta), sin(theta))
  end
  self.from_radians = function(rads)
    return Vec2d(cos(rads), sin(rads))
  end
  self.random = function(mag)
    if mag == nil then
      mag = 1
    end
    local vec = Vec2d.from_angle(random() * 360)
    return vec * mag
  end
  Vec2d = _class_0
end
local Box
do
  local _class_0
  local _base_0 = {
    unpack = function(self)
      return self.x, self.y, self.w, self.h
    end,
    unpack2 = function(self)
      return self.x, self.y, self.x + self.w, self.y + self.h
    end,
    dup = function(self)
      return Box(self:unpack())
    end,
    pad = function(self, amount)
      local amount2 = amount * 2
      return Box(self.x + amount, self.y + amount, self.w - amount2, self.h - amount2)
    end,
    pos = function(self)
      return self.x, self.y
    end,
    set_pos = function(self, x, y)
      self.x, self.y = x, y
    end,
    move = function(self, x, y)
      self.x = self.x + x
      self.y = self.y + y
      return self
    end,
    move_center = function(self, x, y)
      self.x = x - self.w / 2
      self.y = y - self.h / 2
      return self
    end,
    center = function(self)
      return self.x + self.w / 2, self.y + self.h / 2
    end,
    touches_pt = function(self, x, y)
      local x1, y1, x2, y2 = self:unpack2()
      return x > x1 and x < x2 and y > y1 and y < y2
    end,
    touches_box = function(self, o)
      local x1, y1, x2, y2 = self:unpack2()
      local ox1, oy1, ox2, oy2 = o:unpack2()
      if x2 <= ox1 then
        return false
      end
      if x1 >= ox2 then
        return false
      end
      if y2 <= oy1 then
        return false
      end
      if y1 >= oy2 then
        return false
      end
      return true
    end,
    contains_box = function(self, o)
      local x1, y1, x2, y2 = self:unpack2()
      local ox1, oy1, ox2, oy2 = o:unpack2()
      if ox1 <= x1 then
        return false
      end
      if ox2 >= x2 then
        return false
      end
      if oy1 <= y1 then
        return false
      end
      if oy2 >= y2 then
        return false
      end
      return true
    end,
    left_of = function(self, box)
      return self.x < box.x
    end,
    above_of = function(self, box)
      return self.y <= box.y + box.h
    end,
    draw = function(self, color)
      if color == nil then
        color = nil
      end
      if color then
        COLOR:push(unpack(color))
      end
      rectangle("fill", self:unpack())
      if color then
        return COLOR:pop()
      end
    end,
    outline = function(self, color)
      if color == nil then
        color = nil
      end
      if color then
        COLOR:push(unpack(color))
      end
      rectangle("line", self:unpack())
      if color then
        return COLOR:pop()
      end
    end,
    vector_to = function(self, other)
      local x1, y1 = self:center()
      local x2, y2 = other:center()
      return Vec2d(x2 - x1, y2 - y1)
    end,
    random_point = function(self)
      return self.x + random() * self.w, self.y + random() * self.h
    end,
    fix = function(self)
      local x, y, w, h = self:unpack()
      if w < 0 then
        x = x + w
        w = -w
      end
      if h < 0 then
        y = y + h
        h = -h
      end
      return Box(x, y, w, h)
    end,
    scale = function(self, sx, sy, center)
      if sx == nil then
        sx = 1
      end
      if sy == nil then
        sy = sx
      end
      if center == nil then
        center = false
      end
      local scaled = Box(self.x, self.y, self.w * sx, self.h * sy)
      if center then
        scaled:move_center(self:center())
      end
      return scaled
    end,
    shrink = function(self, dx, dy)
      if dx == nil then
        dx = 1
      end
      if dy == nil then
        dy = dx
      end
      local hx = dx / 2
      local hy = dy / 2
      local w = self.w - dx
      local h = self.h - dy
      if w < 0 or h < 0 then
        error("box too small")
      end
      return Box(self.x + hx, self.y + hy, w, h)
    end,
    add_box = function(self, other)
      if self.w == 0 or self.h == 0 then
        self.x, self.y, self.w, self.h = other:unpack()
      else
        local x1, y1, x2, y2 = self:unpack2()
        local ox1, oy1, ox2, oy2 = other:unpack2()
        x1 = math.min(x1, ox1)
        y1 = math.min(y1, oy1)
        x2 = math.max(x2, ox2)
        y2 = math.max(x2, oy2)
        self.x = x1
        self.y = y1
        self.w = x2 - x1
        self.h = y2 - y1
      end
      return nil
    end,
    __div = function(left, right)
      assert(left and left.__class == Box and right and right.__class == Box)
      return Box((left.x - right.x) / right.w, (left.y - right.y) / right.h, left.w / right.w, left.h / right.h)
    end,
    __tostring = function(self)
      return ("box<(%.2f, %.2f), (%.2f, %.2f)>"):format(self:unpack())
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y, w, h)
      self.x, self.y, self.w, self.h = x, y, w, h
    end,
    __base = _base_0,
    __name = "Box"
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
  self.from_pt = function(x1, y1, x2, y2)
    return Box(x1, y1, x2 - x1, y2 - y1)
  end
  Box = _class_0
end
local hash_pt
hash_pt = function(x, y)
  return tostring(x) .. ":" .. tostring(y)
end
local SetList
do
  local _class_0
  local _base_0 = {
    add = function(self, item, value)
      if self.contains[item] then
        return 
      end
      self.contains[item] = true
      self[#self + 1] = value or item
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.contains = { }
    end,
    __base = _base_0,
    __name = "SetList"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  SetList = _class_0
end
local UniformGrid
do
  local _class_0
  local _base_0 = {
    draw = function(self)
      for box in pairs(self.values) do
        Box.draw(box)
      end
    end,
    clear = function(self)
      for _, bucket in pairs(self.buckets) do
        for k, v in pairs(bucket) do
          bucket[k] = nil
        end
      end
      for k, v in pairs(self.values) do
        self.values[k] = nil
      end
    end,
    add = function(self, box, value)
      if value == nil then
        value = box
      end
      for bucket, key in self:buckets_for_box(box, true) do
        bucket[#bucket + 1] = box
      end
      self.values[box] = value
    end,
    get_touching = function(self, query_box)
      local values = self.values
      do
        local _with_0 = SetList()
        for bucket in self:buckets_for_box(query_box) do
          for _index_0 = 1, #bucket do
            local box = bucket[_index_0]
            if query_box ~= box then
              if box:touches_box(query_box) then
                _with_0:add(box, values[box])
              end
            end
          end
        end
        return _with_0
      end
    end,
    get_touching_pt = function(self, x, y)
      local bucket = self:bucket_for_pt(x, y)
      if not (bucket) then
        return 
      end
      local values = self.values
      local list
      do
        local _with_0 = SetList()
        for _index_0 = 1, #bucket do
          local box = bucket[_index_0]
          if box:touches_pt(x, y) then
            _with_0:add(box, values[box])
          end
        end
        list = _with_0
      end
      if next(list) then
        return list
      end
    end,
    bucket_for_pt = function(self, x, y, insert)
      if insert == nil then
        insert = false
      end
      x = _floor(x / self.cell_size)
      y = _floor(y / self.cell_size)
      local key = hash_pt(x, y)
      local b = self.buckets[key]
      if not b and insert then
        b = { }
        self.buckets[key] = b
      end
      return b, key
    end,
    buckets_for_box = function(self, box, insert)
      if insert == nil then
        insert = false
      end
      return coroutine.wrap(function()
        local x1, y1, x2, y2 = box:unpack2()
        local x, y = x1, y1
        while x < x2 + self.cell_size do
          y = y1
          while y < y2 + self.cell_size do
            local b, k = self:bucket_for_pt(x, y, insert)
            if b then
              coroutine.yield(b, k)
            end
            y = y + self.cell_size
          end
          x = x + self.cell_size
        end
      end)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, cell_size)
      if cell_size == nil then
        cell_size = 10
      end
      self.cell_size = cell_size
      self.buckets = { }
      self.values = { }
    end,
    __base = _base_0,
    __name = "UniformGrid"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  UniformGrid = _class_0
end
local Selector
do
  local _class_0
  local _base_0 = {
    cursor_size = 3,
    color = {
      255,
      100,
      100,
      100
    },
    update_mouse = function(self)
      self.mx, self.my = self.viewport:unproject(love.mouse.getPosition())
      self.mx = math.floor(self.mx)
      self.my = math.floor(self.my)
    end,
    draw_cursor = function(self)
      love.mouse.setVisible(false)
      local x, y = self.mx, self.my
      if not (x and y) then
        return 
      end
      Box(x, y - self.cursor_size, 1, self.cursor_size):draw({
        255,
        255,
        255
      })
      Box(x, y + 1, 1, self.cursor_size):draw({
        255,
        255,
        255
      })
      Box(x - self.cursor_size, y, self.cursor_size, 1):draw({
        255,
        255,
        255
      })
      return Box(x + 1, y, self.cursor_size, 1):draw({
        255,
        255,
        255
      })
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, viewport)
      self.viewport = viewport
    end,
    __base = _base_0,
    __name = "Selector"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Selector = _class_0
end
local BoxSelector
do
  local _class_0
  local _parent_0 = Selector
  local _base_0 = {
    draw = function(self)
      self:draw_cursor()
      if self.current then
        return self.current:draw(self.color)
      end
    end,
    update = function(self, dt)
      self:update_mouse()
      if not self.current and love.mouse.isDown("l") then
        self.current = Box(self.mx, self.my, 1, 1)
      end
      if self.current and not love.mouse.isDown("l") then
        print(self.current:fix())
        self.current = nil
      end
      if self.current then
        self.current.w = self.mx - self.current.x
        self.current.h = self.my - self.current.y
      end
      return true
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "BoxSelector",
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
  BoxSelector = _class_0
end
local VectorSelector
do
  local _class_0
  local _parent_0 = Selector
  local _base_0 = {
    draw = function(self)
      self:draw_cursor()
      if self.origin then
        COLOR:push(unpack(self.color))
        line(self.origin[1], self.origin[2], self.mx, self.my)
        return COLOR:pop()
      end
    end,
    update = function(self, dt)
      self:update_mouse()
      if not self.origin and love.mouse.isDown("l") then
        self.origin = Vec2d(self.mx, self.my)
      end
      if self.origin and not love.mouse.isDown("l") then
        local v = Vec2d(self.mx - self.origin[1], self.my - self.origin[2])
        print("Vec:", v, "Dir:", v:normalized())
        self.dest = nil
        self.origin = nil
      end
      return true
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "VectorSelector",
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
  VectorSelector = _class_0
end
return {
  floor = floor,
  ceil = ceil,
  hash_pt = hash_pt,
  Vec2d = Vec2d,
  Box = Box,
  UniformGrid = UniformGrid,
  SetList = SetList,
  Selector = Selector,
  BoxSelector = BoxSelector,
  VectorSelector = VectorSelector
}
