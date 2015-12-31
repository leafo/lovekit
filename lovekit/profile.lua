module("lovekit.profile", package.seeall)
local graphics
graphics = love.graphics
do
  local _class_0
  local _base_0 = {
    count = function(self, label)
      local old = self.counts[label]
      if old then
        self.counts[label] = old + 1
      else
        self.counts[label] = 1
      end
    end,
    count_func = function(self, obj, func_name, label)
      if label == nil then
        label = func_name
      end
      self.counts[label] = 0
      local old_fn = obj[func_name]
      obj[func_name] = function(...)
        self.counts[label] = self.counts[label] + 1
        return old_fn(...)
      end
    end,
    reset = function(self)
      for key in pairs(self.counts) do
        self.counts[key] = 0
      end
    end,
    format_message = function(self, n)
      if n == nil then
        n = 10
      end
      local tuples
      do
        local _accum_0 = { }
        local _len_0 = 1
        for k, v in pairs(self.counts) do
          _accum_0[_len_0] = {
            k,
            v
          }
          _len_0 = _len_0 + 1
        end
        tuples = _accum_0
      end
      table.sort(tuples, function(a, b)
        return a[2] < b[2]
      end)
      local final
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = #tuples, #tuples - n, -1 do
          if not (tuples[i]) then
            break
          end
          local _value_0 = tuples[i]
          _accum_0[_len_0] = _value_0
          _len_0 = _len_0 + 1
        end
        final = _accum_0
      end
      return table.concat((function()
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #final do
          local t = final[_index_0]
          _accum_0[_len_0] = t[1] .. ": " .. t[2]
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)(), "\n")
    end,
    draw = function(self, x, y, reset)
      if x == nil then
        x = 0
      end
      if y == nil then
        y = 0
      end
      if reset == nil then
        reset = true
      end
      local msg = self:format_message()
      graphics.print(msg, x, y)
      if reset then
        return self:reset()
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.counts = { }
    end,
    __base = _base_0,
    __name = "Counter"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Counter = _class_0
  return _class_0
end
