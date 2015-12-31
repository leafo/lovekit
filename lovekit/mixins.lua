local insert, remove
do
  local _obj_0 = table
  insert, remove = _obj_0.insert, _obj_0.remove
end
local get_local
get_local = require("lovekit.support").get_local
local DrawList, EffectList
do
  local _obj_0 = require("lovekit.lists")
  DrawList, EffectList = _obj_0.DrawList, _obj_0.EffectList
end
local Sequence
Sequence = require("lovekit.sequence").Sequence
local mixin
do
  local empty_func = string.dump(function() end)
  mixin = function(mix)
    local cls = get_local("self", 2)
    local base = cls.__base
    for member_name, member_val in pairs(mix.__base) do
      local _continue_0 = false
      repeat
        if member_name:match("^__") then
          _continue_0 = true
          break
        end
        do
          local existing = base[member_name]
          if existing then
            if type(existing) == "function" and type(member_val) == "function" then
              local merged
              if mix.merge_methods then
                merged = mix:merge_methods(member_name, existing, member_val)
              end
              base[member_name] = merged or function(...)
                member_val(...)
                return existing(...)
              end
            else
              base[member_name] = member_val
            end
          else
            base[member_name] = member_val
          end
        end
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    if mix.__init and string.dump(mix.__init) ~= empty_func then
      local old_ctor = cls.__init
      cls.__init = function(...)
        old_ctor(...)
        return mix.__init(...)
      end
    end
  end
end
local Sequenced
do
  local _class_0
  local _base_0 = {
    add_seq = function(self, seq)
      if type(seq) == "function" then
        seq = Sequence(seq)
      end
      self.sequence_queue = self.sequence_queue or { }
      return insert(self.sequence_queue, seq)
    end,
    update = function(self, dt)
      local queue = self.sequence_queue
      if not (queue) then
        return 
      end
      if not self.current_seq and next(queue) then
        self.current_seq = remove(queue, 1)
      end
      if self.current_seq then
        if not (self.current_seq:update(dt)) then
          self.current_seq = nil
        end
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Sequenced"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Sequenced = _class_0
end
local HasParticles
do
  local _class_0
  local _base_0 = {
    draw_inner = function(self)
      return self.particles:draw_sorted()
    end,
    update = function(self, dt)
      return self.particles:update(dt)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.particles = DrawList()
    end,
    __base = _base_0,
    __name = "HasParticles"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  HasParticles = _class_0
end
local KeyRepeat
do
  local _class_0
  local _base_0 = {
    push_key_repeat = function(self, ...)
      self._key_repeat = love.keyboard.hasKeyRepeat()
      return love.keyboard.setKeyRepeat(...)
    end,
    pop_key_repeat = function(self)
      love.keyboard.setKeyRepeat(self._key_repeat)
      self._key_repeat = nil
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "KeyRepeat"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  KeyRepeat = _class_0
end
local HasEffects
do
  local _class_0
  local _base_0 = {
    update = function(self, dt)
      return self.effects:update(dt)
    end,
    draw = function(self)
      return error("implement draw in receiver")
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.effects = self.effects or EffectList()
    end,
    __base = _base_0,
    __name = "HasEffects"
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
  self.merge_methods = function(self, name, existing, new)
    local _exp_0 = name
    if "draw" == _exp_0 then
      return function(self, ...)
        self.effects:before(self)
        existing(self, ...)
        return self.effects:after(self)
      end
    end
  end
  HasEffects = _class_0
end
return {
  mixin = mixin,
  HasEffects = HasEffects,
  HasParticles = HasParticles,
  KeyRepeat = KeyRepeat,
  Sequenced = Sequenced
}
