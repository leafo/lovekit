
require "lovekit.all"

->
  v = Viewport w: 100, h: 100, margin: 200

  love.draw = ->
    v\apply!
    Box.draw v, {255,0, 0}
    v\pop!

  love.mousepressed = (x,y) ->
    vx, vy = v\unproject x, y

    print "raw", x, y
    print "click", vx, vy
    print "project", v\project vx, vy
    print!


