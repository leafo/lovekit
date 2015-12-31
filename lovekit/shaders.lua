local g
g = love.graphics
local FullScreenShader
do
  local _class_0
  local _base_0 = {
    shader = function(self)
      return error("override me")
    end,
    send = function(self) end,
    render = function(self, fn)
      local old_canvas = g.getCanvas()
      g.setCanvas(self.canvas)
      self.canvas:clear(0, 0, 0, 0)
      fn()
      if old_canvas then
        g.setCanvas(old_canvas)
      else
        g.setCanvas()
      end
      g.setBlendMode("premultiplied")
      if not (self.disabled) then
        g.setShader(self.shader)
      end
      self:send()
      g.draw(self.canvas, 0, 0)
      g.setShader()
      return g.setBlendMode("alpha")
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, viewport)
      self.viewport = viewport
      self.canvas = g.newCanvas()
      self.canvas:setFilter("nearest", "nearest")
      self.canvas:setWrap("repeat", "repeat")
      self.shader = g.newShader(self:shader())
    end,
    __base = _base_0,
    __name = "FullScreenShader"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  FullScreenShader = _class_0
end
return {
  FullScreenShader = FullScreenShader
}
