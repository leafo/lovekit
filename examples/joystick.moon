
require "lovekit.all"

{graphics: g} = love

-- 030000006f0e00001f01000000010000 -- pink thing
-- 030000005e0400008e02000014010000 -- xbox 360

apply_deadzone = (vec, amount=.2) ->
  -- should be in normalized range
  x,y = unpack vec
  len = vec\len!
  new_len = if len < amount
    0
  else
    math.min 1, (len - amount) / (1 - amount)

  Vec2d x/len * new_len, y/len * new_len

->
  joystick = unpack love.joystick.getJoysticks!
  love.graphics.setLineWidth 1/100

  deadzone = 0.2

  love.draw = ->
    x = joystick\getGamepadAxis("leftx")
    y = joystick\getGamepadAxis("lefty")
    vec = Vec2d(x,y)
    clean_vec = apply_deadzone vec

    w = g.getWidth!
    h = g.getHeight!

    g.print "len: #{vec\len!}", 10, 10
    g.print "clean len: #{clean_vec\len!}", 10, 20

    g.push!
    g.translate w/2, h/2
    g.scale 200

    g.rectangle "line", -deadzone, -deadzone,
      deadzone * 2, deadzone * 2

    g.rectangle "line", -1, -1, 2, 2

    COLOR\push 255, 100, 100
    g.line 0,0, unpack vec
    COLOR\pop!

    COLOR\push 100, 255, 100
    g.line 0,0, unpack clean_vec
    COLOR\pop!

    g.pop!

  love.joystickpressed = (j, ...) ->
    print "[#{j\getID()}] [#{j\isGamepad!}] pressed", ...

