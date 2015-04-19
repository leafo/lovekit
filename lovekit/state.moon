
import COLOR from require "lovekit.color"
import Sequence from require "lovekit.sequence"

{graphics: g} = love

import insert, remove from table

class Transition
  new: (@before, @after) =>

  -- return: alive
  update: => false
  draw: =>

class FadeTransition extends Sequence
  time: 0.4
  color: {80, 80, 80}

  new: (@before, @after) =>
    @p = 0
    super -> tween @, @time, p: 1.0

  update: (dt) =>
    @after\update dt if @p > 0.5
    super dt

  draw: =>
    alpha = if @p < 0.5
      @before\draw!
      @p * 2
    else
      @after\draw!
      (1 - @p) * 2

    {_r, _g, _b} = @color
    COLOR\push _r, _g, _b, alpha * 255
    g.rectangle "fill", 0, 0, g.getWidth!, g.getHeight!
    COLOR\pop!

-- handles a stack of objects that can respond to events
class Dispatcher
  @event_handlers: {
    "draw"
    "update"
    "keypressed"
    "mousepressed"
    "mousereleased"
    "joystickpressed"
  }

  default_transition: Transition

  new: (initial) =>
    if "function" == type initial
      @stack = {}
      @init_later = initial
    else
      @stack = { initial }
      initial\on_show self if initial and initial.on_show

  send: (event, ...) =>
    current = @top!
    current[event] current, ... if current and current[event]

  top: => @stack[#@stack]
  parent: => @stack[#@stack - 1]

  reset: (initial) =>
    @stack = {}
    @push initial

  push: (state, transition=@default_transition) =>
    @transition = if transition and @top!
      transition @top!, state

    insert @stack, state
    state\on_show self if state.on_show

  insert: (state, pos=#@stack) =>
    insert @stack, #@stack, state

  replace: (state, ...) =>
    @insert state
    @pop 1, ...

  pop: (n=1, transition=@default_transition) =>
    @transition = if transition
      transition @top!,@stack[#@stack - n]

    while n > 0
      love.event.push "quit" if #@stack == 0
      top = @top!
      top\on_hide self if top and top.on_hide

      remove @stack
      n -= 1

    new_top = @top!
    if new_top and new_top.on_show
      new_top\on_show self, true

  bind: (love) =>
    for fn in *@@event_handlers
      func = self[fn]
      love[fn] = (...) -> func self, ...

  keypressed: (key, code) =>
    return if @send "on_key", key, code
    return if @send "on_input", "key", key, code

    if key == "escape"
      love.event.push "quit"

  joystickpressed: (...) =>
    return if @send "on_joystick", ...
    @send "on_input", "joystick", ...

  mousepressed: (...) => @send "mousepressed", ...
  mousereleased: (...) => @send "mousereleased", ...

  draw: =>
    @viewport\apply! if @viewport

    if t = @transition
      t\draw!
    else
      @send "draw"

    @viewport\pop! if @viewport

  update: (dt) =>
    if @init_later
      @push @init_later!
      @init_later = nil

    @viewport\update dt if @viewport and @viewport.update

    if t = @transition
      unless t\update dt
        @transition = nil
    else
      @send "update", dt

{
  :Transition
  :FadeTransition
  :Dispatcher
}
