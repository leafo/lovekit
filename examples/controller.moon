
require "lovekit.all"

{graphics: g} = love

->
  g.setLineWidth 10
  c = Controller {
    left: "left"
    right: "right"
    up: "up"
    down: "down"
  }, "auto"

  love.draw = ->
    g.print "Hello", 10, 10

    move = c\movement_vector 200

    g.push!
    g.translate g.getWidth!/2, g.getHeight!/2
    g.rectangle "line", -200, -200, 400, 400
    g.line 0,0, unpack move
    g.pop!
  
  love.update = =>

