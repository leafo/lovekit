import max from math

{graphics: g } = love

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

class Frame extends Box
  shadow: true

  new: (@sprite, ...) =>
    @border_size = @sprite.cell_w
    super ...

  draw: =>
    {:x, :y, :w, :h} = @

    w = max w, @border_size*2
    h = max h, @border_size*2

    x2 = x + w - @border_size
    y2 = y + h - @border_size

    s = @border_size
    s2 = s*2

    if @shadow
      COLOR\push 0,0,0, 64
      g.rectangle "fill", x + 1, y + 1, w, h
      COLOR\pop!

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


-- a piece of text that knows its size
-- set max_width to wrap it
class Label extends Box
  new: (text, @x=0, @y=0) =>
    @set_text text

  set_max_width: (max_width) =>
    return if max_width == @max_width
    @max_width = max_width
    @_set_size @text unless @is_func

  set_text: (@text) =>
    @is_func = type(@text) == "function"
    @_set_size @text unless @is_func
    @_update_from_fun!

  _set_size: (text) =>
    font = g.getFont!
    @w = font\getWidth text

    if @max_width
      @w = math.min @max_width, @w
      @w, num_lines = font\getWrap text, @max_width
      @h = num_lines * font\getHeight!
    else
      @h = font\getHeight!

  _update_from_fun: =>
    if @is_func
      @_text = @text!
      @_set_size @_text

  update: (dt) =>
    @_update_from_fun!
    @alive

  draw: =>
    text = @is_func and @_text or @text
    if @max_width
      g.printf text, @x, @y, @max_width
    else
      g.print text, @x, @y

    -- COLOR\push 255,100,100, 200
    -- g.rectangle "fill", @x,@y, 2,2
    -- g.rectangle "fill", @x+@w,@y+@h, 2,2
    -- COLOR\pop!


-- has effect list
class AnimatedLabel extends Label
  new: (...) =>
    super ...
    @effects = EffectList!

  update: (dt) =>
    @effects\update dt
    super dt

  draw: =>
    text = @is_func and @_text or @text
    hw = @w/2
    hh = @h/2

    g.push!
    g.translate @x + hw, @y + hh
    @effects\before!
    g.print text, -hw, -hh
    @effects\after!
    g.pop!


class BlinkingLabel extends Label
  rate: 1.2
  duty: 0.8 -- percent of time visible

  elapsed: 0

  update: (dt) =>
    @elapsed += dt
    super dt

  draw: =>
    scaled = @elapsed / @rate
    p = scaled - math.floor scaled

    if p <= @duty
      super!

class RevealLabel extends Label
  rate: 0.03

  new: (text, @x, @y, fn) =>
    @chr = 0
    @seq = Sequence ->
      while @chr < #text
        @chr += 1
        wait @rate

      @done = true
      @seq = nil
      fn @ if fn

    @set_text -> text\sub 1, @chr

  update: (dt) =>
    @seq\update dt if @seq
    super dt


class BaseList extends Box
  padding: 5
  xalign: "left"
  yalign: "top"
  w: 0
  h: 0

  -- can pass instance properties into items
  new: (@x, @y, @items={}) =>
    -- not specifying position
    if type(@x) == "table"
      @items = @x
      @x = 0
      @y = 0

    -- extract props
    for k,v in pairs @items
      if type(k) == "string"
        @items[k] = nil
        @[k] = v

  update_size: -> error "override me"

  update: (dt, ...) =>
    for item in *@items
      if item.update
        item\update dt, ...
    @update_size!
    true

class VList extends BaseList
  update_size: =>
    @w, @h = 0, 0
    for item in *@items
      @h += item.h + @padding
      if item.w > @w
        @w = item.w

    @h -= @padding if @h > 0

  draw: =>
    {:x, :y} = @

    dy = if @yalign == "bottom"
      total_height = 0
      for item in *@items
        total_height += item.h

      if total_height > 0
        total_height += @padding * #@items

      -total_height
    else
      0

    for item in *@items
      item.x = if @xalign == "right"
        x - item.w
      else
        x

      item.y = y + dy
      y += @padding + item.h
      item\draw!

class HList extends BaseList
  update_size: =>
    @w, @h = 0, 0
    for item in *@items
      @w += item.w + @padding
      if item.h > @h
        @h = item.h

    @w -= @padding if @w > 0

  draw: =>
    {:x, :y} = @

    for item in *@items
      item.x = x
      item.y = y
      x += @padding + item.w
      item\draw!


class CenterBin extends Box
  w: 0
  h: 0

  new: (@x, @y, @item) =>

  update: (dt) =>
    @item\update dt
    @item.x = @x - @item.w / 2
    @item.y = @y - @item.h / 2
    true

  draw: =>
    @item\draw!

{ :Frame, :Label, :AnimatedLabel, :BlinkingLabel, :RevealLabel, :VList, :HList, :CenterBin }
