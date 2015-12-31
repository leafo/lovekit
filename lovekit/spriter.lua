local graphics
graphics = love.graphics
local push, pop, scale, translate
push, pop, scale, translate = graphics.push, graphics.pop, graphics.scale, graphics.translate
local floor
floor = math.floor
local imgfy
imgfy = require("lovekit.image").imgfy
local StateAnim, Animator, Spriter
do
  local _class_0
  local _base_0 = {
    set_state = function(self, name, ...)
      do
        local new_anim = self.states[name]
        if new_anim then
          self.current = new_anim
          if name ~= self.current_name then
            self.current:reset(...)
          end
          self.current_name = name
        end
      end
    end,
    update = function(self, dt)
      if not self.paused then
        return self.current:update(dt)
      end
    end,
    reset = function(self, ...)
      return self.current:reset(...)
    end,
    draw = function(self, x, y)
      return self.current:draw(x, y)
    end,
    state_duration = function(self, name)
      local state = self.states[name]
      if not (state) then
        error("unknown state " .. tostring(name))
      end
      return state.rate * #state.sequence
    end,
    splice_states = function(self, idx, fn)
      local current_states
      do
        local _accum_0 = { }
        local _len_0 = 1
        for k, v in pairs(self.states) do
          _accum_0[_len_0] = {
            k,
            v
          }
          _len_0 = _len_0 + 1
        end
        current_states = _accum_0
      end
      local idx_set
      do
        local _tbl_0 = { }
        for _index_0 = 1, #idx do
          local i = idx[_index_0]
          _tbl_0[i] = true
        end
        idx_set = _tbl_0
      end
      for _index_0 = 1, #current_states do
        local _continue_0 = false
        repeat
          local _des_0 = current_states[_index_0]
          local name, anim
          name, anim = _des_0[1], _des_0[2]
          local new_name = fn(name)
          if not (new_name and new_name ~= name) then
            _continue_0 = true
            break
          end
          local new_sequence
          do
            local _accum_0 = { }
            local _len_0 = 1
            for i, frame in ipairs(anim.sequence) do
              local _continue_1 = false
              repeat
                if not (idx_set[i]) then
                  _continue_1 = true
                  break
                end
                local _value_0 = frame
                _accum_0[_len_0] = _value_0
                _len_0 = _len_0 + 1
                _continue_1 = true
              until true
              if not _continue_1 then
                break
              end
            end
            new_sequence = _accum_0
          end
          self.states[new_name] = Animator(anim.sprite, new_sequence, anim.rate, anim.flip_x, anim.flip_y)
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, initial, states)
      self.states = states
      self.current_name = nil
      self:set_state(initial)
      self.paused = false
    end,
    __base = _base_0,
    __name = "StateAnim"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  StateAnim = _class_0
end
do
  local _class_0
  local copy_props
  local _base_0 = {
    ox = 0,
    oy = 0,
    get_width = function(self)
      return self.sprite.cell_w
    end,
    get_height = function(self)
      return self.sprite.cell_h
    end,
    reset = function(self, frame)
      if frame == nil then
        frame = 1
      end
      self.time = 0
      self.i = frame
    end,
    update = function(self, dt)
      if self.rate > 0 then
        self.time = self.time + dt
        if self.time > self.rate then
          self.time = self.time - self.rate
          self.i = self.i + 1
          local num = #self.sequence
          if self.i > num then
            if self.once == true then
              self.i = num
            else
              self.i = 1
            end
          end
        end
      end
    end,
    draw = function(self, x, y)
      return self.sprite:draw_cell(self.sequence[self.i], x - self.ox, y - self.oy, self.flip_x, self.flip_y)
    end,
    drawt = function(self, t, x, y)
      local k = math.max(1, math.ceil(t * #self.sequence))
      return self.sprite:draw_cell(self.sequence[k], x - self.ox, y - self.oy, self.flip_x, self.flip_y)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, sprite, sequence, rate, flip_x, flip_y)
      if rate == nil then
        rate = 0
      end
      if flip_x == nil then
        flip_x = false
      end
      if flip_y == nil then
        flip_y = false
      end
      self.sprite, self.sequence, self.rate, self.flip_x, self.flip_y = sprite, sequence, rate, flip_x, flip_y
      for _index_0 = 1, #copy_props do
        local p = copy_props[_index_0]
        local val = self.sequence[p]
        if val ~= nil then
          self.sequence[p] = nil
          self[p] = val
        end
      end
      return self:reset()
    end,
    __base = _base_0,
    __name = "Animator"
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
  copy_props = {
    "ox",
    "oy",
    "rate",
    "flip_x",
    "flip_y",
    "once"
  }
  Animator = _class_0
end
do
  local _class_0
  local _base_0 = {
    seq = function(self, ...)
      return Animator(self, ...)
    end,
    _quad_dimensions = function(self, i)
      if type(i) == "string" then
        local x, y, w, h = i:match("(%d+),(%d+),(%d+),(%d+)")
        return tonumber(x), tonumber(y), tonumber(w), tonumber(h)
      else
        if not (self.cell_w > 0) then
          error("can't draw from index with no cell size")
        end
        local sx, sy
        if self.width == 0 then
          sx, sy = self.ox + i * self.cell_w, self.oy
        else
          sx, sy = self.ox + (i % self.width) * self.cell_w, self.oy + floor(i / self.width) * self.cell_h
        end
        return sx, sy, self.cell_w, self.cell_h
      end
    end,
    quad_for = function(self, i)
      do
        local q = self.quads[i]
        if q then
          return q
        end
      end
      local x, y, w, h = self:_quad_dimensions(i)
      local q = graphics.newQuad(x, y, w, h, self.iw, self.ih)
      self.quads[i] = q
      return q
    end,
    draw_sized = function(self, i, x, y, w, h)
      local q = self:quad_for(i)
      local sx = w / self.cell_w
      local sy = h / self.cell_h
      self.img:draw(q, x, y, 0, sx, sy)
      return nil
    end,
    draw = function(self, i, ...)
      return self.img:draw(self:quad_for(i), ...)
    end,
    draw_cell = function(self, i, x, y, flip_x, flip_y)
      if flip_x == nil then
        flip_x = false
      end
      if flip_y == nil then
        flip_y = false
      end
      local q = self:quad_for(i)
      if flip_x or flip_y then
        local _, qw, qh
        _, _, qw, qh = q:getViewport()
        local sx = flip_x and -1 or 1
        local sy = flip_y and -1 or 1
        local ox = flip_x and qw or 0
        local oy = flip_y and qh or 0
        self.img:draw(q, x, y, 0, sx, sy, ox, oy)
      else
        self.img:draw(q, x, y)
      end
      return nil
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, img, cell_w, cell_h, width)
      if cell_w == nil then
        cell_w = 0
      end
      if cell_h == nil then
        cell_h = cell_w
      end
      if width == nil then
        width = nil
      end
      self.img, self.cell_w, self.cell_h, self.width = img, cell_w, cell_h, width
      self.img = imgfy(self.img)
      self.iw, self.ih = self.img:width(), self.img:height()
      self.ox = 0
      self.oy = 0
      if not (self.width) then
        self.width = floor(self.iw / self.cell_w)
      end
      self.quads = { }
    end,
    __base = _base_0,
    __name = "Spriter"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Spriter = _class_0
end
return {
  StateAnim = StateAnim,
  Animator = Animator,
  Spriter = Spriter
}
