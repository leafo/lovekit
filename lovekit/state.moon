
require "lovekit.support"

export ^

import insert, remove from table

-- handles a stack of objects that can respond to events
class Dispatcher
  new: (initial) =>
    @stack = { initial }

  send: (event, ...) =>
    current = @top!
    current[event] current, ... if current and current[event]

  top: => @stack[#@stack]
  parent: => @stack[#@stack - 1]

  push: (state) =>
    insert @stack, state

  pop: (n=1) =>
    @blend_effect = nil
    while n > 0
      os.exit! if #@stack == 0
      remove @stack
      n -= 1

  bind: (love) =>
    for fn in *{"draw", "update", "keypressed"}
      func = self[fn]
      love[fn] = (...) -> func self, ...

  keypressed: (key, code) =>
    return if @send "on_key",  key, code
    switch key
      when "escape" then os.exit!

  draw: =>
    if @blend_effect
      @blend_effect @elapsed / @effect_time
    else
      @send "draw"

  update: (dt) =>
    if @blend_effect
      @elapsed += dt
      @blend_effect = nil if @elapsed > @effect_time

    @send "update", dt

