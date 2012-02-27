
import graphics from love

export ^
export imgfy

class ImageReloader
  new: =>
    require "inotify"
    @handle = inotify.init true
    @descriptors = {}

  add: (image) =>
    print "watching:", image.fname
    wd = @handle\addwatch image.fname, inotify.IN_CLOSE_WRITE
    @descriptors[wd] = image

  update: =>
    events = @handle\read!
    if events
      for e in *events
        @descriptors[e.wd]\reload!

class Image
  new: (@fname) =>
    @reload!
    if lovekit and lovekit.reload_images
      lovekit.reloader = ImageReloader! if not lovekit.reloader
      lovekit.reloader\add self
    nil
  
  width: => @tex\getWidth!
  height: => @tex\getHeight!

  drawq: (...) =>
    graphics.drawq @tex, ...

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



