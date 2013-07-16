
require "lovekit.support"

import min from math
import keyboard from love
import insert from table

select = select

export ^

-- Functions here yield to the sequence object. The sequence object will yield
-- dt so animation can be performed

-- every rate seconds call function
-- stop if function returns falsey
interval = (rate, fn) ->
  t = 0
  while true
    done = false
    t += coroutine.yield!
    while t > rate
      t -= rate
      done = not fn!
    break if done

default_scope = {
  again: ->
    coroutine.yield "again"
    nil

  wait: (time) ->
    while time > 0
      time -= coroutine.yield!
    if time < 0
      coroutine.yield "more", -time

  wait_for_key: (key) ->
    local dt
    while true
      break if keyboard.isDown key
      dt = coroutine.yield!
    coroutine.yield "more", dt if dt

  wait_until: (fn) ->
    local dt
    while not fn!
      dt = coroutine.yield!
    coroutine.yield "more", dt if dt

  -- flattens an async function
  await: (fn, ...) ->
    local out
    called = false

    callback = (...) ->
      called = true
      out = {...}

    if select("#", ...) > 0
      args = {...}
      insert args, callback
      fn unpack args
    else
      fn callback

    while not called
      coroutine.yield!

    unpack out

  during: (time, fn) ->
    while time > 0
      dt = coroutine.yield!
      time -= dt
      dt += time if time < 0
      if "cancel" == fn dt
        break

    coroutine.yield "more", -time if time < 0

  tween: (obj, time, props, step=smoothstep) ->
    t = 0
    initial = {}
    for key in pairs props
      initial[key] = obj[key]

    while t < 1.0
      for key, finish in pairs props
        obj[key] = step initial[key], finish, t
      t += coroutine.yield! / time

    -- finish
    for key, finish in pairs props
      obj[key] = finish

    -- push left over time
    leftover = t - 1.0
    if leftover > 0
      coroutine.yield "more", leftover
}

-- safely resumes a coroutine
-- TODO: support more than 2 return values
resume = (co, ...) ->
  status, err, v = coroutine.resume co, ...
  if not status
    error err or "Failed to resume coroutine"
  err, v

class Sequence
  @default_scope = default_scope

  @extend = (tbl) =>
    @default_scope = setmetatable tbl, __index: @default_scope

  @join = (...) ->
    seqs =  {...}

    setmetatable {
      _seqs: seqs
      update: (dt) =>
        alive = false
        for s in *seqs
          alive = s\update(dt) or alive
        alive
    }, __index: (key) =>
      val = seqs[1][key]

      -- create a joined function
      if type(val) == "function"
        val = (...) =>
          for s in *seqs
            s[key] s, ... if s[key]

        self[key] = val

      val

  new: (@fn, scope=@@default_scope) =>
    if scope
      old_env = getfenv @fn
      setfenv @fn, setmetatable {}, {
        __index: (name) =>
          val = scope[name]
          if val
            val
          else
            old_env[name]
      }
    @create!

  create: =>
    @co = coroutine.create @fn
    @started = false

  start: =>
    @started = true
    resume @co

  respond: =>

  is_dead: => coroutine.status(@co) == "dead"

  send_time: (dt) =>
    -- loop until the time is sent
    while true do
      @start! if not @started
      return false if @is_dead!

      signal, val = resume @co, dt

      switch signal
        when "again"
          @create!
        when "more"
          @send_time 0 -- go past message
          dt = val
        else
          break
    true

  update: (dt) => @send_time dt
