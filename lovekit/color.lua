local graphics
graphics = love.graphics
local rgb_helper
rgb_helper = function(comp, temp1, temp2)
  if comp < 0 then
    comp = comp + 1
  elseif comp > 1 then
    comp = comp - 1
  end
  if 6 * comp < 1 then
    return temp1 + (temp2 - temp1) * 6 * comp
  elseif 2 * comp < 1 then
    return temp2
  elseif 3 * comp < 2 then
    return temp1 + (temp2 - temp1) * (2 / 3 - comp) * 6
  else
    return temp1
  end
end
local hsl_to_rgb
hsl_to_rgb = function(h, s, l)
  h = h / 360
  s = s / 100
  l = l / 100
  local r, g, b = nil
  if s == 0 then
    r = l
    g = l
    b = l
  else
    local temp2
    if l < 0.5 then
      temp2 = l * (1 + s)
    else
      temp2 = l + s - l * s
    end
    local temp1 = 2 * l - temp2
    r = rgb_helper(h + 1 / 3, temp1, temp2)
    g = rgb_helper(h, temp1, temp2)
    b = rgb_helper(h - 1 / 3, temp1, temp2)
  end
  return r * 255, g * 255, b * 255
end
local rgb_to_hsl
rgb_to_hsl = function(r, g, b)
  r = r / 255
  g = g / 255
  b = b / 255
  local min = math.min(r, g, b)
  local max = math.max(r, g, b)
  local s = 0
  local h = 0
  local l = (min + max) / 2
  if min ~= max then
    if l < 0.5 then
      s = (max - min) / (max + min)
    else
      s = (max - min) / (2 - max - min)
    end
    local _exp_0 = max
    if r == _exp_0 then
      h = (g - b) / (max - min)
    elseif g == _exp_0 then
      h = 2 + (b - r) / (max - min)
    elseif b == _exp_0 then
      h = 4 + (r - g) / (max - min)
    end
  end
  if h < 0 then
    h = h + 6
  end
  return h * 60, s * 100, l * 100
end
local hash_string
do
  local cache = { }
  hash_string = function(str)
    local hash = cache[str]
    if not (hash) then
      local bytes = {
        string.byte(str, 1, #str)
      }
      hash = 0
      for i, b in ipairs(bytes) do
        hash = hash + (bytes[i] ^ (4 - (i - 1) % 4))
      end
      cache[str] = hash
    end
    return hash
  end
end
local hash_to_color
hash_to_color = function(str, s, l)
  if s == nil then
    s = 60
  end
  if l == nil then
    l = 60
  end
  local num = hash_string(str) % 360
  return hsl_to_rgb(num, s, l)
end
local ColorStack
do
  local _class_0
  local _base_0 = {
    red = {
      255,
      0,
      0
    },
    green = {
      0,
      255,
      0
    },
    blue = {
      0,
      0,
      255
    },
    push = function(self, r, g, b, a)
      local s, l
      s, l = self.stack, self.length
      if type(r) == "table" then
        r, g, b, a = unpack(r)
      end
      r = r or 255
      g = g or 255
      b = b or 255
      a = a or 255
      local top = l * 4 + 1
      l = l + 1
      r = r * s[top - 4] / 255
      g = g * s[top - 3] / 255
      b = b * s[top - 2] / 255
      a = a * s[top - 1] / 255
      s[top] = r
      s[top + 1] = g
      s[top + 2] = b
      s[top + 3] = a
      self.length = l
      return graphics.setColor(r, g, b, a)
    end,
    set = function(self, ...)
      self.length = self.length - 1
      return self:push(...)
    end,
    pusha = function(self, a)
      local s, l
      s, l = self.stack, self.length
      local top = l * 4 + 1
      l = l + 1
      local r = s[top - 4]
      local g = s[top - 3]
      local b = s[top - 2]
      a = a * s[top - 1] / 255
      s[top] = r
      s[top + 1] = g
      s[top + 2] = b
      s[top + 3] = a
      self.length = l
      return graphics.setColor(r, g, b, a)
    end,
    pop = function(self, n)
      if n == nil then
        n = 1
      end
      local s, l
      s, l = self.stack, self.length
      l = l - 1
      local top = l * 4 + 1
      s[top + 3] = nil
      s[top + 2] = nil
      s[top + 1] = nil
      s[top] = nil
      self.length = l
      if n > 1 then
        return self:pop(n - 1)
      end
      return graphics.setColor(s[top - 4], s[top - 3], s[top - 2], s[top - 1])
    end,
    current = function(self)
      local s = self.stack
      local start = (self.length - 1) * 4 + 1
      return s[start], s[start + 1], s[start + 2], s[start + 3]
    end,
    apply = function(self)
      return graphics.setColor(self:current())
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.length = 1
      self.stack = {
        255,
        255,
        255,
        255
      }
    end,
    __base = _base_0,
    __name = "ColorStack"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ColorStack = _class_0
end
local COLOR = ColorStack()
return {
  hsl_to_rgb = hsl_to_rgb,
  rgb_to_hsl = rgb_to_hsl,
  hash_string = hash_string,
  hash_to_color = hash_to_color,
  ColorStack = ColorStack,
  COLOR = COLOR
}
