require("lovekit.geometry")
local keyboard, timer
do
  local _obj_0 = love
  keyboard, timer = _obj_0.keyboard, _obj_0.timer
end
local insert
insert = table.insert
local unpack
unpack = _G.unpack
local Vec2d
Vec2d = require("lovekit.geometry").Vec2d
if love and love.joystick then
  do
    local guid = "030000006f0e00001f01000000010000"
    love.joystick.setGamepadMapping(guid, "leftx", "axis", 1)
    love.joystick.setGamepadMapping(guid, "lefty", "axis", 2)
  end
end
local table_table
table_table = function()
  return setmetatable({ }, {
    __index = function(self, key)
      do
        local new = { }
        self[key] = new
        return new
      end
    end
  })
end
local make_mover
make_mover = function(up, down, left, right)
  if not (type(up) == "table") then
    up = {
      up
    }
  end
  if not (type(down) == "table") then
    down = {
      down
    }
  end
  if not (type(left) == "table") then
    left = {
      left
    }
  end
  if not (type(right) == "table") then
    right = {
      right
    }
  end
  return function(speed)
    local vel = Vec2d(0, 0)
    if keyboard.isDown(unpack(left)) then
      vel[1] = -1
    elseif keyboard.isDown(unpack(right)) then
      vel[1] = 1
    else
      vel[1] = 0
    end
    if keyboard.isDown(unpack(down)) then
      vel[2] = 1
    elseif keyboard.isDown(unpack(up)) then
      vel[2] = -1
    else
      vel[2] = 0
    end
    local out = vel:normalized()
    if speed then
      out = out * speed
    end
    return out
  end
end
local movement_vector = make_mover("up", "down", "left", "right")
local joystick_deadzone_normalize
joystick_deadzone_normalize = function(vec, min_amount, max_amount)
  if min_amount == nil then
    min_amount = .2
  end
  if max_amount == nil then
    max_amount = 0.95
  end
  local x, y = unpack(vec)
  local len = vec:len()
  local new_len
  if len < min_amount then
    new_len = 0
  elseif len > max_amount then
    new_len = 1
  else
    new_len = math.min(1, (len - min_amount) / (max_amount - min_amount))
  end
  local out = Vec2d(x / len * new_len, y / len * new_len)
  if new_len ~= 0 then
    local primary = out:primary_direction()
    local dot = primary * out
    if dot > 0.95 then
      if new_len == 1 then
        out = primary
      else
        out = primary * new_len
      end
    end
  end
  return out
end
local make_joystick_mover
make_joystick_mover = function(joystick, xaxis, yaxis)
  if joystick == nil then
    joystick = 1
  end
  if xaxis == nil then
    xaxis = "leftx"
  end
  if yaxis == nil then
    yaxis = "lefty"
  end
  if type(joystick) == "number" then
    joystick = assert(love.joystick.getJoysticks()[joystick], "Missing joystick")
  end
  return function(speed)
    local hat_dir = joystick:getHat(1)
    local vec
    if hat_dir ~= "c" then
      local _exp_0 = hat_dir
      if "u" == _exp_0 then
        vec = Vec2d(0, -1)
      elseif "d" == _exp_0 then
        vec = Vec2d(0, 1)
      elseif "l" == _exp_0 then
        vec = Vec2d(-1, 0)
      elseif "r" == _exp_0 then
        vec = Vec2d(1, 0)
      elseif "ld" == _exp_0 then
        vec = Vec2d(-1, 1):normalized()
      elseif "lu" == _exp_0 then
        vec = Vec2d(-1, -1):normalized()
      elseif "rd" == _exp_0 then
        vec = Vec2d(1, 1):normalized()
      elseif "ru" == _exp_0 then
        vec = Vec2d(1, -1):normalized()
      end
    else
      local x = joystick:getGamepadAxis(xaxis)
      local y = joystick:getGamepadAxis(yaxis)
      vec = Vec2d(x, y)
    end
    vec = joystick_deadzone_normalize(vec)
    if speed then
      vec = vec * speed
    end
    return vec
  end
end
local Controller
do
  local _class_0
  local _base_0 = {
    tap_delay = 0.2,
    axis_button = {
      left = true,
      right = true,
      up = true,
      down = true
    },
    make_mover = function(self)
      local left = rawget(self.key_mapping, "left")
      local right = rawget(self.key_mapping, "right")
      local down = rawget(self.key_mapping, "down")
      local up = rawget(self.key_mapping, "up")
      local keyboard_mover
      if left and right and down and up then
        keyboard_mover = make_mover(up, down, left, right)
      end
      local joystick_mover
      if self.joystick then
        joystick_mover = make_joystick_mover(self.joystick)
      end
      if keyboard_mover and joystick_mover then
        self.movement_vector = function(self, ...)
          local kv = keyboard_mover(...)
          local jv = joystick_mover(...)
          local x
          if kv[1] ~= 0 then
            if jv[1] ~= 0 then
              x = (kv[1] + jv[1]) / 2
            else
              x = kv[1]
            end
          else
            x = jv[1]
          end
          local y
          if kv[2] ~= 0 then
            if jv[2] ~= 0 then
              y = (kv[2] + jv[2]) / 2
            else
              y = kv[2]
            end
          else
            y = jv[2]
          end
          kv[1] = x
          kv[2] = y
          return kv
        end
      elseif keyboard_mover then
        self.movement_vector = function(self, ...)
          return keyboard_mover(...)
        end
      elseif joystick_mover then
        self.movement_vector = function(self, ...)
          return joystick_mover(...)
        end
      end
    end,
    add_mapping = function(self, mapping)
      self.key_mapping = self.key_mapping or table_table()
      self.joy_mapping = self.joy_mapping or table_table()
      for name, inputs in pairs(mapping) do
        local _continue_0 = false
        repeat
          if type(inputs) == "string" then
            insert(self.key_mapping[name], inputs)
            _continue_0 = true
            break
          end
          for _index_0 = 1, #inputs do
            local key = inputs[_index_0]
            insert(self.key_mapping[name], key)
          end
          do
            local extra_keys = inputs.keyboard
            if extra_keys then
              if type(extra_keys) == "table" then
                for _index_0 = 1, #extra_keys do
                  local key = extra_keys[_index_0]
                  insert(self.key_mapping[name], key)
                end
              else
                insert(self.key_mapping[name], extra_keys)
              end
            end
          end
          do
            local joy_buttons = inputs.joystick
            if joy_buttons then
              if type(joy_buttons) == "table" then
                for _index_0 = 1, #joy_buttons do
                  local btn = joy_buttons[_index_0]
                  insert(self.joy_mapping[name], btn)
                end
              else
                insert(self.joy_mapping[name], joy_buttons)
              end
            end
          end
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      if not (next(self.joy_mapping)) then
        self.joy_mapping = nil
      end
    end,
    downed = function(self, key)
      if self:is_down(key) then
        local was_down = self.downer[key]
        self.downer[key] = true
        if not (was_down) then
          return true
        end
      else
        self.downer[key] = nil
      end
    end,
    tapped = function(self, key, ...)
      if self:is_down(key) then
        self.tapper[key] = true
      elseif self.tapper[key] == true then
        self.tapper[key] = nil
        return true
      end
    end,
    double_tapped = function(self, key, ...)
      if self:is_down(key) then
        local tap = self.dtapper[key]
        if type(tap) == "number" then
          if timer.getTime() - tap < self.tap_delay then
            self.dtapper[key] = false
            if ... then
              return true, self:double_tapped(...)
            else
              return true
            end
          end
        end
        if not (tap == false) then
          self.dtapper[key] = true
        end
      elseif self.dtapper[key] == false then
        self.dtapper[key] = nil
      elseif self.dtapper[key] == true then
        self.dtapper[key] = love.timer.getTime()
      end
      if ... then
        return false, self:double_tapped(...)
      else
        return false
      end
    end,
    is_down = function(self, name, ...)
      do
        local keys = self.key_mapping[name]
        if keys then
          local pressed = keyboard.isDown(unpack(keys))
          if pressed then
            return true
          end
        end
      end
      if self:joystick_is_down(name) then
        return true
      end
      if ... then
        return self:is_down(...)
      else
        return false
      end
    end,
    direction_is_down = function(self, name)
      if not (self.axis_button[name]) then
        return nil
      end
      do
        local keys = self.key_mapping[name]
        if keys then
          if keyboard.isDown(unpack(keys)) then
            return true
          end
        end
      end
      if self.joystick then
        local x = self.joystick:getGamepadAxis("leftx")
        local y = self.joystick:getGamepadAxis("lefty")
        local vec = joystick_deadzone_normalize(Vec2d(x, y))
        vec = vec:primary_direction()
        local yes
        local _exp_0 = name
        if "left" == _exp_0 then
          yes = vec[1] < 0
        elseif "right" == _exp_0 then
          yes = vec[1] > 0
        elseif "up" == _exp_0 then
          yes = vec[2] < 0
        elseif "down" == _exp_0 then
          yes = vec[2] > 0
        end
        if yes then
          return true
        end
      end
    end,
    joystick_is_down = function(self, name)
      if not (self.joystick) then
        return false
      end
      if self.axis_button[name] then
        local x = self.joystick:getGamepadAxis("leftx")
        local y = self.joystick:getGamepadAxis("lefty")
        local vec = joystick_deadzone_normalize(Vec2d(x, y))
        local hat_dir = self.joystick:getHat(1)
        if hat_dir ~= "c" then
          local _exp_0 = name
          if "left" == _exp_0 then
            return hat_dir:match("l")
          elseif "right" == _exp_0 then
            return hat_dir:match("r")
          elseif "up" == _exp_0 then
            return hat_dir:match("u")
          elseif "down" == _exp_0 then
            return hat_dir:match("d")
          end
        end
        local _exp_0 = name
        if "left" == _exp_0 then
          return vec[1] < 0
        elseif "right" == _exp_0 then
          return vec[1] > 0
        elseif "up" == _exp_0 then
          return vec[2] < 0
        elseif "down" == _exp_0 then
          return vec[2] > 0
        end
      end
      if not (self.joy_mapping) then
        return false
      end
      local btns = self.joy_mapping[name]
      if not (btns and next(btns)) then
        return false
      end
      return self.joystick:isDown(unpack(btns))
    end,
    movement_vector = function(self)
      return error("don't know how to make movement vector")
    end,
    wait_for = function(self) end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, mapping, joystick)
      self.joystick = joystick
      if self.joystick == "auto" then
        self.joystick = love.joystick.getJoysticks()[self.__class.next_joystick]
        if self.joystick then
          self.__class.next_joystick = self.__class.next_joystick + 1
        end
      end
      self:add_mapping(mapping)
      self.tapper = { }
      self.dtapper = { }
      self.downer = { }
      return self:make_mover()
    end,
    __base = _base_0,
    __name = "Controller"
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
  self.next_joystick = 1
  self.default = function(self)
    return self({
      left = "left",
      right = "right",
      up = "up",
      down = "down",
      confirm = "x",
      cancel = "c"
    }, "auto")
  end
  Controller = _class_0
end
return {
  make_mover = make_mover,
  movement_vector = movement_vector,
  make_joystick_mover = make_joystick_mover,
  Controller = Controller
}
