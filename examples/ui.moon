
require "lovekit.all"
import Anchor, Label, VList, HList from require "lovekit.ui"

{graphics: g} = love

->
  v = Viewport scale: 4
  draw_list = DrawList!
  vx, vy = v\center!

  perms_i = 1
  perms = {
    { "center",  "center" }
    { "center",  "top" }
    { "center",  "bottom" }

    { "left",  "center" }
    { "left",  "top" }
    { "left",  "bottom" }


    { "right",  "center" }
    { "right",  "top" }
    { "right",  "bottom" }
  }

  aligns_i = 1
  aligns = {
    { "left", "top" }
    { "center", "center" }
    { "right", "bottom"}
  }

  {"left", "center", "right"}

  list = VList {
    xalign: aligns[aligns_i][1]
    yalign: aligns[aligns_i][2]

    Box(0,0, 15, 25)
    Box(0,0, 10, 10)
    Box(0,0, 20, 20)
    Box(0,0, 25, 15)

    draw: =>
      Box.draw @, {255,100,100,100}
      @__class.draw @
  }

  anchor = Anchor vx, vy, list , unpack perms[perms_i]

  -- show dot in center
  anchor.draw = =>
    Anchor.draw @
    COLOR\push 255,100,100
    g.rectangle "fill", @x - 2, @y - 2, 4,4
    COLOR\pop!

  draw_list\add anchor

  love.draw = ->
    g.print "Left click: change anchor", 10, 10
    g.print "Right click: change list align", 10, 30
    g.print "Middle click: Switch list type", 10, 50

    v\apply!
    draw_list\draw!
    v\pop!

  love.update = (dt) ->
    draw_list\update dt

  love.mousepressed = (x,y, btn) ->
    if btn == 1
      perms_i = perms_i % #perms + 1
      print "Anchor:", unpack perms[perms_i]
      anchor.xalign, anchor.yalign = unpack perms[perms_i]

    if btn == 2
      aligns_i = aligns_i % #aligns + 1
      print "List:", unpack aligns[aligns_i]
      list.xalign, list.yalign = unpack aligns[aligns_i]
      nil

    if btn == 3
      print "Flipping..."
      if list.__class == VList
        setmetatable list, HList.__base
      else
        setmetatable list, VList.__base
