
import graphics from love

class Image
  @from_tex: (tex) =>
    setmetatable {:tex}, @__base

  new: (@fname) =>
    @reload!
  
  width: => @tex\getWidth!
  height: => @tex\getHeight!

  set_wrap: (...) => @tex\setWrap ...

  draw: (...) =>
    graphics.draw @tex, ...

  reload: =>
    @tex = graphics.newImage @fname

_newImage = graphics.newImage
graphics.newImage = (...) ->
  print "loading image:", ...
  with _newImage ...
    \setFilter "nearest", "nearest"

image_cache = {}
imgfy = (img) ->
  if "string" == type img
    cached = image_cache[img]
    img = if not cached
      new = Image img
      image_cache[img] = new
      new
    else
      cached
  img


{
  :imgfy, :Image
}
