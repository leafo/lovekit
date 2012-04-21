import graphics, image, filesystem from love

export *

-- take screenshots every @rate frames, save them in dir
class ScreenSnap
  new: (@rate=5, @dir="snapshots_"..os.time!) =>
    @prefix = "snap"
    @i = 1
    @frames = 0

    filesystem.mkdir @dir

  next_name: (ext) =>
    with @dir .. "/" .. @prefix .. "_" .. @i .. "." .. ext
      @i += 1

  take_screenshot: (format="png")=>
    image_data = graphics.newScreenshot!
    fname = @next_name format
    print "++ snap: " .. fname

    -- love 7
    if image.newEncodedImageData
      image.newEncodedImageData image_data, format
      filesystem.write fname, ss
    else
      print "encoding"
      image_data\encode fname

  tick:  =>
    @take_screenshot! if @frames % @rate == 0
    @frames += 1

