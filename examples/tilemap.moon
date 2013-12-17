
require "lovekit.all"

import graphics, keyboard from love

->
  viewport = Viewport scale: 4

  sprite = Spriter "scrap/tileset.png", 16, 16
  map = TileMap.from_image "scrap/map.png", sprite, {
    ["0,0,0"]: { tid: 0 }
    ["255,255,255"]: { tid: 1 }
    ["0,0,255"]: animated_tile { 2, 3, layer: 0 }
  }

  ui_sprite = Spriter "scrap/ui.png", 4, 4, 4

  b = Box 0,0, 30, 30

  world =
    collides: (...) => map\collides ...

  speed = 150
  me = Entity 0,0

  particles = DrawList!

  speed_i = 0
  love.keypressed = (name, code) ->
    switch name
      when " "
        speed_i = (speed_i + 1) % 4
        print "speed index", speed_i
        speed = 50 + speed_i * 50
      when "escape"
        love.event.push "quit"
      when "s"
        snapper = if snapper then nil else ScreenSnap!

  seq = Sequence ->
    tween b, 1, x: 80, y: 50
    tween b, 1, x: 0, y: 0
    again!

  make_particles = Sequence ->
    base_dir = Vec2d(1, 0) * 50

    class P extends PixelParticle
      life: 2

    while true
      dir = base_dir\random_heading 60, random_normal!
      particles\add P 50, 50, dir
      wait 0.05

  love.mousepressed = (x, y) ->
    x,y = viewport\unproject x, y
    x, y = math.floor(x), math.floor(y)
    b\set_pos x,y
    print "CLICK", x, y

  love.update = (dt) ->
    me.vel\update unpack movement_vector speed

    me\update dt, world
    map\update dt

    seq\update dt
    make_particles\update dt

    particles\update dt

  love.draw = ->
    viewport\center_on me
    viewport\apply!

    v = viewport\pad 20
    map\draw v
    v\outline!

    COLOR\pusha 64
    graphics.rectangle "fill", b\unpack!
    COLOR\pop!

    map\show_touching me

    me\draw!

    viewport\pop!

    graphics.push!
    graphics.scale 4, 4
    particles\draw_sorted!
    graphics.pop!

    graphics.print love.timer.getFPS!, 10, 10



