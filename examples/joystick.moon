
require "lovekit.all"

->
  love.joystickaxis = (...) ->
    print "axis", ...

  love.joystickpressed = (...) ->
    print "pressed", ...

