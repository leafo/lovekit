
{graphics: g} = love

class FullScreenShader
  shader: => error "override me"

  new: (@viewport) =>
    @canvas = g.newCanvas!
    @canvas\setFilter "nearest", "nearest"
    @canvas\setWrap "repeat", "repeat"

    @shader = g.newShader @shader!

  send: =>

  render: (fn) =>
    old_canvas = g.getCanvas!

    g.setCanvas @canvas
    @canvas\clear 0,0,0,0

    fn!

    if old_canvas
      g.setCanvas old_canvas
    else
      g.setCanvas!

    g.setBlendMode "premultiplied"
    g.setShader @shader unless @disabled
    @send!
    g.draw @canvas, 0,0
    g.setShader!
    g.setBlendMode "alpha"

{ :FullScreenShader }
