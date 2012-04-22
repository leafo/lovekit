
module "lui", package.seeall

export ^

import graphics from love
import max from math

border = {
  tl: 0
  l: 1
  t: 2
  tr: 3
  bl: 4
  r: 5
  b: 6
  br: 7
  back: 8
}

class Window
  shadow: true

  new: (@sprite) =>
    @border_size = @sprite.cell_w
    assert @sprite.cell_w == @sprite.cell_h -- TODO remove this

  -- TODO see if it's worth caching this
  draw: (x, y, w, h) =>
    w = max w, @border_size*2
    h = max h, @border_size*2

    x2 = x + w - @border_size
    y2 = y + h - @border_size

    s = @border_size
    s2 = s*2

    if @shadow
      graphics.setColor 0,0,0, 64
      graphics.rectangle "fill", x + 1, y + 1, w, h
      graphics.setColor 255, 255, 255

    with @sprite
      -- corners
      \draw_cell border.tl, x, y
      \draw_cell border.tr, x2, y

      \draw_cell border.bl, x, y2
      \draw_cell border.br, x2, y2

      -- edges
      \draw_sized border.t, x + s, y, w - s2, s
      \draw_sized border.b, x + s, y2, w - s2, s

      \draw_sized border.l, x, y + s, s, h - s2
      \draw_sized border.r, x2, y + s, s, h - s2

      -- back, TODO: tile it?
      \draw_sized border.back, x + s, y + s, w - s2, h - s2


