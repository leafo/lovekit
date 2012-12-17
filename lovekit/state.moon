
require "lovekit.support"

export ^

import insert, remove from table

-- handles a stack of objects that can respond to events
class Dispatcher
  new: (initial) =>
    @stack = { initial }
    initial\onload self if initial.onload

  send: (event, ...) =>
    current = @top!
    current[event] current, ... if current and current[event]

  top: => @stack[#@stack]
  parent: => @stack[#@stack - 1]

  reset: (initial) =>
    @stack = { initial }

  push: (state) =>
    insert @stack, state
    state\onload self if state.onload

  pop: (n=1) =>
    while n > 0
      os.exit! if #@stack == 0
      top = @top!
      top\onunload self if top and top.unload
      remove @stack
      n -= 1

  bind: (love) =>
    for fn in *{"draw", "update", "keypressed", "mousepressed", "mousereleased"}
      func = self[fn]
      love[fn] = (...) -> func self, ...

  keypressed: (key, code) =>
    return if @send "on_key",  key, code
    switch key
      when "escape"
        love.event.push "quit"

  mousepressed: (...) => @send "mousepressed", ...
  mousereleased: (...) => @send "mousereleased", ...

  draw: =>
    @send "draw"

  update: (dt) =>
    @send "update", dt

