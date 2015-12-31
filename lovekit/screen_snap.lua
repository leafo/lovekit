local graphics, image, filesystem
do
  local _obj_0 = love
  graphics, image, filesystem = _obj_0.graphics, _obj_0.image, _obj_0.filesystem
end
local ScreenSnap
do
  local _class_0
  local _base_0 = {
    next_name = function(self, ext)
      do
        local _with_0 = self.dir .. "/" .. (("%09d"):format(self.i)) .. "." .. ext
        self.i = self.i + 1
        return _with_0
      end
    end,
    write = function(self, format)
      if format == nil then
        format = "png"
      end
      print("++ writing ", #self.snaps, "snaps")
      local _list_0 = self.snaps
      for _index_0 = 1, #_list_0 do
        local image_data = _list_0[_index_0]
        local fname = self:next_name(format)
        print("encoding " .. tostring(fname))
        image_data:encode(fname)
      end
    end,
    take_screenshot = function(self)
      local start = love.timer.getTime()
      self.snaps[#self.snaps + 1] = graphics.newScreenshot()
      return print("++ snap", love.timer.getTime() - start)
    end,
    tick = function(self)
      if self.frames % self.rate == 0 then
        self:take_screenshot()
      end
      self.frames = self.frames + 1
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, rate, dir)
      if rate == nil then
        rate = 3
      end
      if dir == nil then
        dir = "snapshots_" .. os.time()
      end
      self.rate, self.dir = rate, dir
      self.i = 1
      self.frames = 0
      self.snaps = { }
      return filesystem.createDirectory(self.dir)
    end,
    __base = _base_0,
    __name = "ScreenSnap"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ScreenSnap = _class_0
end
return {
  ScreenSnap = ScreenSnap
}
