import graphics, image, filesystem from love

-- take screenshots every @rate frames, save them in dir
class ScreenSnap
  new: (@rate=3, @dir="snapshots_"..os.time!) =>
    @i = 1
    @frames = 0
    @snaps = {}

    filesystem.createDirectory @dir

  next_name: (ext) =>
    with @dir .. "/" .. ("%09d"\format @i) .. "." .. ext
      @i += 1

  write: (format="png") =>
    print "++ writing ", #@snaps, "snaps"
    for image_data in *@snaps
      fname = @next_name format
      print "encoding #{fname}"
      image_data\encode fname

  take_screenshot: =>
    start = love.timer.getTime!
    @snaps[#@snaps + 1] = graphics.newScreenshot!
    print "++ snap", love.timer.getTime! - start

  tick:  =>
    @take_screenshot! if @frames % @rate == 0
    @frames += 1


{ :ScreenSnap }
