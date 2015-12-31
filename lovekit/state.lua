local COLOR
COLOR = require("lovekit.color").COLOR
local Sequence
Sequence = require("lovekit.sequence").Sequence
local g
g = love.graphics
local insert, remove
do
  local _obj_0 = table
  insert, remove = _obj_0.insert, _obj_0.remove
end
local Transition
do
  local _class_0
  local _base_0 = {
    update = function(self)
      return false
    end,
    draw = function(self) end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, before, after)
      self.before, self.after = before, after
    end,
    __base = _base_0,
    __name = "Transition"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Transition = _class_0
end
local FadeTransition
do
  local _class_0
  local _parent_0 = Sequence
  local _base_0 = {
    time = 0.4,
    color = {
      80,
      80,
      80
    },
    update = function(self, dt)
      if self.p > 0.5 then
        self.after:update(dt)
      end
      return _class_0.__parent.__base.update(self, dt)
    end,
    draw = function(self)
      local alpha
      if self.p < 0.5 then
        self.before:draw()
        alpha = self.p * 2
      else
        self.after:draw()
        alpha = (1 - self.p) * 2
      end
      local _r, _g, _b
      do
        local _obj_0 = self.color
        _r, _g, _b = _obj_0[1], _obj_0[2], _obj_0[3]
      end
      COLOR:push(_r, _g, _b, alpha * 255)
      g.rectangle("fill", 0, 0, g.getWidth(), g.getHeight())
      return COLOR:pop()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, before, after)
      self.before, self.after = before, after
      self.p = 0
      return _class_0.__parent.__init(self, function()
        return tween(self, self.time, {
          p = 1.0
        })
      end)
    end,
    __base = _base_0,
    __name = "FadeTransition",
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
  FadeTransition = _class_0
end
local Dispatcher
do
  local _class_0
  local _base_0 = {
    default_transition = Transition,
    send = function(self, event, ...)
      local current = self:top()
      if current and current[event] then
        return current[event](current, ...)
      end
    end,
    top = function(self)
      return self.stack[#self.stack]
    end,
    parent = function(self)
      return self.stack[#self.stack - 1]
    end,
    reset = function(self, initial)
      self.stack = { }
      return self:push(initial)
    end,
    push = function(self, state, transition)
      if transition == nil then
        transition = self.default_transition
      end
      if transition and self:top() then
        self.transition = transition(self:top(), state)
      end
      insert(self.stack, state)
      if state.on_show then
        return state:on_show(self)
      end
    end,
    insert = function(self, state, pos)
      if pos == nil then
        pos = #self.stack
      end
      return insert(self.stack, #self.stack, state)
    end,
    replace = function(self, state, ...)
      self:insert(state)
      return self:pop(1, ...)
    end,
    pop = function(self, n, transition)
      if n == nil then
        n = 1
      end
      if transition == nil then
        transition = self.default_transition
      end
      if transition then
        self.transition = transition(self:top(), self.stack[#self.stack - n])
      end
      while n > 0 do
        if #self.stack == 0 then
          love.event.push("quit")
        end
        local top = self:top()
        if top and top.on_hide then
          top:on_hide(self)
        end
        remove(self.stack)
        n = n - 1
      end
      local new_top = self:top()
      if new_top and new_top.on_show then
        return new_top:on_show(self, true)
      end
    end,
    bind = function(self, love)
      local _list_0 = self.__class.event_handlers
      for _index_0 = 1, #_list_0 do
        local fn = _list_0[_index_0]
        local func = self[fn]
        love[fn] = function(...)
          return func(self, ...)
        end
      end
    end,
    keypressed = function(self, key, code)
      if self:send("on_key", key, code) then
        return 
      end
      if self:send("on_input", "key", key, code) then
        return 
      end
      if key == "escape" then
        return love.event.push("quit")
      end
    end,
    joystickpressed = function(self, ...)
      if self:send("on_joystick", ...) then
        return 
      end
      return self:send("on_input", "joystick", ...)
    end,
    mousepressed = function(self, ...)
      return self:send("mousepressed", ...)
    end,
    mousereleased = function(self, ...)
      return self:send("mousereleased", ...)
    end,
    draw = function(self)
      if self.viewport then
        self.viewport:apply()
      end
      do
        local t = self.transition
        if t then
          t:draw()
        else
          self:send("draw")
        end
      end
      if self.viewport then
        return self.viewport:pop()
      end
    end,
    update = function(self, dt)
      if self.init_later then
        self:push(self:init_later())
        self.init_later = nil
      end
      if self.viewport and self.viewport.update then
        self.viewport:update(dt)
      end
      do
        local t = self.transition
        if t then
          if not (t:update(dt)) then
            self.transition = nil
          end
        else
          return self:send("update", dt)
        end
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, initial)
      if "function" == type(initial) then
        self.stack = { }
        self.init_later = initial
      else
        self.stack = {
          initial
        }
        if initial and initial.on_show then
          return initial:on_show(self)
        end
      end
    end,
    __base = _base_0,
    __name = "Dispatcher"
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
  self.event_handlers = {
    "draw",
    "update",
    "keypressed",
    "mousepressed",
    "mousereleased",
    "joystickpressed"
  }
  Dispatcher = _class_0
end
return {
  Transition = Transition,
  FadeTransition = FadeTransition,
  Dispatcher = Dispatcher
}
