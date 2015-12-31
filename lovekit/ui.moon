import max from math

{graphics: g } = love

import Box from require "lovekit.geometry"
import COLOR from require "lovekit.color"
import Sequence from require "lovekit.sequence"
import EffectList from require "lovekit.lists"

extract_props = (items) =>
  return unless items
  for k,v in pairs items
    if type(k) == "string"
      items[k] = nil
      @[k] = v

-- update: update the bounding box of the ui component, call update of children before updating current
-- draw: if the component manages positions then it should update children

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

-- TODO: this has nothing to do with any of the stuff in here
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
  alive: true
  align: "left"

  new: (text, @x=0, @y=0) =>
    @set_text text

  set_max_width: (max_width, @align) =>
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
      @w, lines = font\getWrap text, @max_width
      @h = #lines * font\getHeight!
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
    if @color
      COLOR\push unpack @color

    text = @is_func and @_text or @text
    if @max_width
      g.printf text, @x, @y, @max_width, @align
    else
      g.print text, @x, @y

    if @color
      COLOR\pop!

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
  fixed_size: false

  new: (text, @x, @y, fn) =>
    @chr = 0
    @set_text -> text\sub 1, @chr

    @seq = Sequence ->
      while @chr < #text
        @chr += 1
        wait @rate

      @done = true
      @seq = nil
      fn @ if fn

    if type(fn) == "table"
      for k,v in pairs fn
        if type(k) == "string"
          @[k] = v

      fn = fn[1]

    if @fixed_size
      @_set_size = =>
        RevealLabel._set_size @, text


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

    extract_props @, @items

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
    {:x, :y, :w, :xalign} = @

    for item in *@items
      item.x = if xalign == "right"
        x + w - item.w
      elseif xalign == "center"
        x + (w - item.w) /2
      else
        x

      item.y = y

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
    {:x, :y, :h, :yalign} = @

    for item in *@items
      item.x = x
      item.y = if yalign == "bottom"
        y + h - item.h
      elseif yalign == "center"
        y + (h - item.h) / 2
      else
        y

      x += @padding + item.w
      item\draw!

-- fixes a UI element relative to a point
class Anchor extends Box
  w: 0
  h: 0

  new: (@x, @y, @item, @xalign, @yalign=xalign) =>

  update: (...) =>
    with @item\update ...
      @item.x = switch @xalign
        when "right"
          @x - @item.w
        when "center"
          @x - @item.w / 2
        else
          @x

      @item.y = switch @yalign
        when "bottom"
          @y - @item.h
        when "center"
          @y - @item.h / 2
        else
          @y

  draw: =>
    @item\draw!

class CenterAnchor extends Anchor
  new: (x,y, item) =>
    super x, y, item, "center"


-- fixed size container that holds 1 item that is aligned
class Bin extends Box
  xalign: 0.5
  yalign: 0.5

  new: (x,y,w,h, @item, @xalign, @yalign) =>
    super x,y,w,h

  update: (...) =>
    with @item\update ...
      @item.x = math.floor @x + (@w - @item.w) * @xalign
      @item.y = math.floor @y + (@h - @item.h) * @yalign

  draw: =>
    @item\draw!


-- a group just holds items for drawing/updating in one go.
-- is bounding box of all items
class Group extends Box
  new: (@items={}) =>

  update: (dt) =>
    @x = 0
    @y = 0
    @w = 0
    @h = 0

    for item in *@items
      item\update dt
      @add_box item

  draw: (...) =>
    for item in *@items
      item\draw ...

-- wraps a single item with padding/border
class Border extends Box
  padding: 0
  border: true
  background: false

  new: (@item, props) =>
    extract_props @, props
    super @item.x, @item.y, @item.w, @item.h

  update: (dt) =>
    @w = @item.w + @padding * 2
    @h = @item.h + @padding * 2

    if @min_width
      @w = math.max @min_width, @w

    @item\update dt

  draw: =>
    if @border
      g.rectangle "line", @unpack!

    if @background
      COLOR\push unpack @background
      g.rectangle "fill", @unpack!
      COLOR\pop!

    @item.x = @x + @padding
    @item.y = @y + @padding
    @item\draw!


{ :Frame, :Label, :AnimatedLabel, :BlinkingLabel, :RevealLabel, :VList,
  :HList, :Anchor, :CenterAnchor, :Bin, :Group, :Border }
