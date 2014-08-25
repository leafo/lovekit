
import graphics from love
import push, pop, scale, translate from graphics
import floor from math

import imgfy from require "lovekit.image"

local *

-- holds a collection of Animators assigned to a state
class StateAnim
  new: (initial, @states) =>
    @current_name = nil
    @set_state initial
    @paused = false

  set_state: (name, ...) =>
    if new_anim = @states[name]
      @current = new_anim
      @current\reset ... if name != @current_name
      @current_name = name

  update: (dt) =>
    @current\update dt if not @paused

  reset: (...) =>
    @current\reset ...

  draw: (x,y) =>
    @current\draw x, y

  -- duration of a state animation in seconds
  state_duration: (name) =>
    state = @states[name]
    error "unknown state #{name}" unless state
    state.rate * #state.sequence

  -- dupes Animators using frame indexes in idx when fn returns a new state name
  splice_states: (idx, fn) =>
    current_states =[{k,v} for k,v in pairs @states]

    idx_set = {i, true for i in *idx}

    for {name, anim} in *current_states
      new_name = fn name
      continue unless new_name and new_name != name

      new_sequence = for i, frame in ipairs anim.sequence
        continue unless idx_set[i]
        frame

      @states[new_name] = Animator anim.sprite, new_sequence, anim.rate, anim.flip_x, anim.flip_y

-- animating a series of cells from a Spriter
class Animator
  -- values that can be pulled from sequence and passed to animator
  copy_props = { "ox", "oy", "rate", "flip_x", "flip_y", "once" }

  ox: 0
  oy: 0

  get_width: => @sprite.cell_w
  get_height: => @sprite.cell_h

  -- @sequence array of cell ids to animate
  -- @rate time between each frame in seconds
  -- @flip flip all frames horizontally if true
  new: (@sprite, @sequence, @rate=0, @flip_x=false, @flip_y=false) =>
    for p in *copy_props
      val = @sequence[p]
      if val != nil
        @sequence[p] = nil
        @[p] = val

    @reset!

  reset: (frame=1) =>
    @time = 0
    @i = frame

  update: (dt) =>
    if @rate > 0
      @time += dt
      if @time > @rate
        @time -= @rate
        @i = @i + 1
        num = #@sequence
        if @i > num
          if @once == true
            @i = num
          else
            @i = 1

  draw: (x, y) =>
    @sprite\draw_cell @sequence[@i], x - @ox, y - @oy, @flip_x, @flip_y

  -- draw frame based on time from 0 to 1
  drawt: (t, x, y) =>
    k = math.max 1, math.ceil t * #@sequence
    @sprite\draw_cell @sequence[k], x - @ox, y - @oy, @flip_x, @flip_y

-- used for blitting
-- use @width of 0 to prevent the tiles from wrapping
class Spriter
  new: (@img, @cell_w=0, @cell_h=cell_w, @width=nil) =>
    @img = imgfy @img

    @iw, @ih = @img\width!, @img\height!

    @ox = 0
    @oy = 0

    unless @width
      @width = floor @iw / @cell_w

    @quads = {}

  seq: (...) => Animator self, ...

  -- return x,y,w,h of named quad
  _quad_dimensions: (i) =>
    if type(i) == "string" -- "x,y,w,h"
      x, y, w, h = i\match "(%d+),(%d+),(%d+),(%d+)"
      tonumber(x), tonumber(y), tonumber(w), tonumber(h)
    else
      error "can't draw from index with no cell size" unless @cell_w > 0
      sx, sy = if @width == 0
        @ox + i * @cell_w, @oy
      else
        @ox + (i % @width) * @cell_w, @oy + floor(i / @width) * @cell_h

      sx, sy, @cell_w, @cell_h

  quad_for: (i) =>
    if q = @quads[i]
      return q

    x,y,w,h = @_quad_dimensions(i)
    q = graphics.newQuad x, y, w, h, @iw, @ih
    @quads[i] = q
    q

  draw_sized: (i, x,y, w,h) =>
    q = @quad_for i

    sx = w / @cell_w
    sy = h / @cell_h
    @img\draw q, x, y, 0, sx, sy

    nil

  draw: (i,...) =>
    @img\draw @quad_for(i), ...

  draw_cell: (i, x, y, flip_x=false, flip_y=false) =>
    q = @quad_for i

    if flip_x or flip_y
      _, _, qw, qh = q\getViewport!
      sx = flip_x and -1 or 1
      sy = flip_y and -1 or 1

      ox = flip_x and qw or 0
      oy = flip_y and qh or 0
      @img\draw q, x, y, 0, sx, sy, ox, oy
    else
      @img\draw q, x, y

    nil


{
  :StateAnim
  :Animator
  :Spriter
}
