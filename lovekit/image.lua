local graphics
graphics = love.graphics
local Image
do
  local _class_0
  local _base_0 = {
    width = function(self)
      return self.tex:getWidth()
    end,
    height = function(self)
      return self.tex:getHeight()
    end,
    set_wrap = function(self, ...)
      return self.tex:setWrap(...)
    end,
    draw = function(self, ...)
      return graphics.draw(self.tex, ...)
    end,
    reload = function(self)
      self.tex = graphics.newImage(self.fname)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, fname)
      self.fname = fname
      return self:reload()
    end,
    __base = _base_0,
    __name = "Image"
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
  self.from_tex = function(self, tex)
    return setmetatable({
      tex = tex
    }, self.__base)
  end
  Image = _class_0
end
local _newImage = graphics.newImage
graphics.newImage = function(...)
  print("loading image:", ...)
  do
    local _with_0 = _newImage(...)
    _with_0:setFilter("nearest", "nearest")
    return _with_0
  end
end
local image_cache = { }
local imgfy
imgfy = function(img)
  if "string" == type(img) then
    local cached = image_cache[img]
    if not cached then
      local new = Image(img)
      image_cache[img] = new
      img = new
    else
      img = cached
    end
  end
  return img
end
return {
  imgfy = imgfy,
  Image = Image
}
