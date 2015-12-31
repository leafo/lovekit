local audio
audio = love.audio
local Audio
do
  local _class_0
  local _base_0 = {
    preload = function(self, names)
      for _index_0 = 1, #names do
        local name = names[_index_0]
        self:get_source(name)
      end
      return nil
    end,
    fade_music = function(self, t, callback_fn)
      if t == nil then
        t = 1.0
      end
      local music = self.music
      local volume = music:getVolume()
      local min = music:getVolumeLimits()
      local remaining = t
      return Sequence(function()
        during(t, function(dt)
          remaining = remaining - dt
          local vol = remaining / t * (volume - min) + min
          return music:setVolume(vol)
        end)
        music:stop()
        return callback_fn and callback_fn()
      end)
    end,
    get_source = function(self, name, ext, source_type)
      if source_type == nil then
        source_type = "static"
      end
      if self.sources[name] then
        return self.sources[name]
      end
      ext = ext or self.ext
      local fname = self.dir .. "/" .. name .. "." .. ext
      print("loading source(" .. tostring(source_type) .. "):", fname)
      local source = audio.newSource(fname, source_type)
      do
        local _with_0 = source
        self.sources[name] = source
        return _with_0
      end
    end,
    play_music = function(self, name, looping)
      if looping == nil then
        looping = true
      end
      if self.music then
        self.music:stop()
      end
      self.current_music = name
      do
        local _with_0 = self:get_source(name, "ogg", "stream")
        _with_0:setVolume(0.5)
        _with_0:setLooping(looping)
        _with_0:play()
        self.music = _with_0
      end
    end,
    play = function(self, name)
      local s = self:get_source(name)
      if s then
        s:rewind()
        return s:play()
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, dir, ext)
      if dir == nil then
        dir = "audio"
      end
      if ext == nil then
        ext = "wav"
      end
      self.dir, self.ext = dir, ext
      self.sources = { }
    end,
    __base = _base_0,
    __name = "Audio"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Audio = _class_0
end
return {
  Audio = Audio
}
