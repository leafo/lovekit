require("lovekit.support")
local min
min = math.min
local keyboard
keyboard = love.keyboard
local insert
insert = table.insert
local select
select = _G.select
local smoothstep
smoothstep = require("lovekit.support").smoothstep
local interval
interval = function(rate, fn)
  local t = 0
  while true do
    local done = false
    t = t + coroutine.yield()
    while t > rate do
      t = t - rate
      done = not fn()
    end
    if done then
      break
    end
  end
end
local default_scope = {
  again = function()
    coroutine.yield("again")
    return nil
  end,
  wait = function(time)
    while time > 0 do
      time = time - coroutine.yield()
    end
    if time < 0 then
      return coroutine.yield("more", -time)
    end
  end,
  wait_for_key = function(expect_key, ...)
    if expect_key then
      local dt
      while true do
        if keyboard.isDown(expect_key, ...) then
          break
        end
        dt = coroutine.yield()
      end
      if dt then
        return coroutine.yield("more", dt)
      end
    else
      local old_keypressed = love.keypressed
      local key
      love.keypressed = function(...)
        key = ...
        love.keypressed = old_keypressed
        return old_keypressed(...)
      end
      local dt
      while not key do
        dt = coroutine.yield()
      end
      if dt then
        coroutine.yield("more", dt)
      end
      return key
    end
  end,
  wait_until = function(fn)
    local dt, ret
    local elapsed = 0
    while true do
      ret = fn(elapsed)
      if ret then
        break
      else
        dt = coroutine.yield()
        elapsed = elapsed + dt
      end
    end
    if dt then
      coroutine.yield("more", dt)
    end
    return ret
  end,
  await = function(fn, ...)
    local out
    local called = false
    local callback
    callback = function(...)
      called = true
      out = {
        ...
      }
    end
    if select("#", ...) > 0 then
      local args = {
        ...
      }
      insert(args, callback)
      fn(unpack(args))
    else
      fn(callback)
    end
    while not called do
      coroutine.yield()
    end
    return unpack(out)
  end,
  during = function(time, fn)
    while time > 0 do
      local dt = coroutine.yield()
      time = time - dt
      if time < 0 then
        dt = dt + time
      end
      if "cancel" == fn(dt) then
        break
      end
    end
    if time < 0 then
      return coroutine.yield("more", -time)
    end
  end,
  wait_for_one = function(...)
    local seqs
    do
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = {
        ...
      }
      for _index_0 = 1, #_list_0 do
        local fn = _list_0[_index_0]
        _accum_0[_len_0] = Sequence(fn)
        _len_0 = _len_0 + 1
      end
      seqs = _accum_0
    end
    while true do
      local dt = coroutine.yield()
      for idx, seq in ipairs(seqs) do
        if not (seq:update(dt)) then
          return idx
        end
      end
    end
  end,
  parallel = function(...)
    local seqs
    do
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = {
        ...
      }
      for _index_0 = 1, #_list_0 do
        local _continue_0 = false
        repeat
          local fn = _list_0[_index_0]
          if not (fn) then
            _continue_0 = true
            break
          end
          local _value_0
          if type(fn) == "function" then
            _value_0 = Sequence(fn)
          elseif fn.__class == Sequence then
            _value_0 = fn
          else
            _value_0 = error("Got unknown object to parallel, expected function or sequence, got: " .. tostring(type(fn)))
          end
          _accum_0[_len_0] = _value_0
          _len_0 = _len_0 + 1
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      seqs = _accum_0
    end
    if not (next(seqs)) then
      return 
    end
    while true do
      local dt = coroutine.yield()
      local running = 0
      for idx, seq in pairs(seqs) do
        local _continue_0 = false
        repeat
          if not (seq) then
            _continue_0 = true
            break
          end
          local alive = seq:update(dt)
          if alive then
            running = running + 1
          else
            seqs[idx] = false
          end
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      if running == 0 then
        break
      end
    end
  end,
  tween = function(obj, time, props, step, onupdate)
    if step == nil then
      step = smoothstep
    end
    local t = 0
    local initial = { }
    for key in pairs(props) do
      initial[key] = obj[key]
    end
    while t < 1.0 do
      for key, finish in pairs(props) do
        obj[key] = step(initial[key], finish, t)
      end
      if onupdate then
        onupdate(obj)
      end
      t = t + (coroutine.yield() / time)
    end
    for key, finish in pairs(props) do
      obj[key] = finish
      if onupdate then
        onupdate(obj)
      end
    end
    local leftover = (t - 1.0) * time
    if leftover > 0 then
      return coroutine.yield("more", leftover)
    end
  end,
  run = function(fn, ...)
    local env = getfenv(2)
    setfenv(fn, env)
    return fn(...)
  end
}
local resume
resume = function(co, ...)
  local status, err, v = coroutine.resume(co, ...)
  if not status then
    error(err or "Failed to resume coroutine")
  end
  return err, v
end
local Sequence
do
  local _class_0
  local _base_0 = {
    elapsed = 0,
    create = function(self, ...)
      self.args = {
        ...
      }
      self.co = coroutine.create(self.fn)
      self.started = false
    end,
    start = function(self, ...)
      self.started = true
      return resume(self.co, ...)
    end,
    respond = function(self) end,
    is_dead = function(self)
      return coroutine.status(self.co) == "dead"
    end,
    send_time = function(self, dt)
      while true do
        if not (self.started) then
          self:start(unpack(self.args))
        end
        if self:is_dead() then
          return false
        end
        local signal, val = resume(self.co, dt)
        local _exp_0 = signal
        if "again" == _exp_0 then
          self:create()
        elseif "more" == _exp_0 then
          self:send_time(0)
          dt = val
        else
          break
        end
      end
      return true
    end,
    update = function(self, dt)
      self.elapsed = self.elapsed + dt
      return self:send_time(dt)
    end,
    draw = function(self) end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, fn, scope, ...)
      if scope then
        for k, v in pairs(scope) do
          if type(v) == "function" then
            self.__class:setfenv(v, scope)
          end
        end
        setmetatable(scope, {
          __index = self.__class.default_scope
        })
      end
      self.fn = self.__class:setfenv(fn, scope)
      return self:create(...)
    end,
    __base = _base_0,
    __name = "Sequence"
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
  self.default_scope = default_scope
  self.after = function(self, time, fn)
    return Sequence(function()
      wait(time)
      return fn()
    end)
  end
  self.extend = function(self, tbl)
    for k, v in pairs(tbl) do
      if type(v) == "function" then
        self:setfenv(v, tbl)
      end
    end
    self.default_scope = setmetatable(tbl, {
      __index = self.default_scope
    })
  end
  self.join = function(...)
    local seqs = {
      ...
    }
    return setmetatable({
      _seqs = seqs,
      update = function(self, dt)
        local alive = false
        for _index_0 = 1, #seqs do
          local s = seqs[_index_0]
          alive = s:update(dt) or alive
        end
        return alive
      end
    }, {
      __index = function(self, key)
        local val = seqs[1][key]
        if type(val) == "function" then
          val = function(self, ...)
            for _index_0 = 1, #seqs do
              local s = seqs[_index_0]
              if s[key] then
                s[key](s, ...)
              end
            end
          end
          self[key] = val
        end
        return val
      end
    })
  end
  self.setfenv = function(self, fn, scope)
    if scope == nil then
      scope = self.default_scope
    end
    if scope then
      local old_env = getfenv(fn)
      setfenv(fn, setmetatable({ }, {
        __index = function(self, name)
          local val = scope[name]
          if val then
            return val
          else
            return old_env[name]
          end
        end
      }))
    end
    return fn
  end
  Sequence = _class_0
end
return {
  Sequence = Sequence
}
