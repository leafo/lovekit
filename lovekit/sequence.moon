
require "lovekit.support"

import min from math
import keyboard from love
import insert from table
import select from _G

import smoothstep from require "lovekit.support"

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

  -- wait_for_key "a"
  -- key = wait_for_key! -- waits for any key
  wait_for_key: (expect_key, ...) ->
    if expect_key
      local dt
      while true
        break if keyboard.isDown expect_key, ...
        dt = coroutine.yield!
      coroutine.yield "more", dt if dt
    else
      old_keypressed = love.keypressed
      local key

      love.keypressed = (...) ->
        key = ...
        love.keypressed = old_keypressed
        old_keypressed ...

      local dt
      while not key
        dt = coroutine.yield!

      coroutine.yield "more", dt if dt
      key

  -- call function over and over waiting for it to return true
  wait_until: (fn) ->
    local dt
    while not fn!
      dt = coroutine.yield!
    coroutine.yield "more", dt if dt

  -- flattens an async function
  -- callback must be last arg
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
    leftover = (t - 1.0) * time
    if leftover > 0
      coroutine.yield "more", leftover

  -- run another function in the correct scope
  run: (fn, ...) ->
    env = getfenv 2
    setfenv fn, env
    fn ...
}

-- safely resumes a coroutine
-- TODO: support more than 2 return values
resume = (co, ...) ->
  status, err, v = coroutine.resume co, ...
  if not status
    error err or "Failed to resume coroutine"
  err, v

class Sequence
  @default_scope: default_scope
  elapsed: 0

  @after: (time, fn) =>
    Sequence ->
      wait time
      fn!

  @extend: (tbl) =>
    @default_scope = setmetatable tbl, __index: @default_scope

  @join: (...) ->
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

  new: (fn, scope, ...) =>
    @fn = @_setfenv fn, scope
    @create ...

  _setfenv: (fn, scope=@@default_scope) =>
    if scope
      old_env = getfenv fn
      setfenv fn, setmetatable {}, {
        __index: (name) =>
          val = scope[name]
          if val
            val
          else
            old_env[name]
      }

    fn

  create: (...) =>
    @args = {...}
    @co = coroutine.create @fn
    @started = false

  start: (...) =>
    @started = true
    resume @co, ...

  respond: =>

  is_dead: => coroutine.status(@co) == "dead"

  send_time: (dt) =>
    -- loop until the time is sent
    while true do
      @start unpack @args unless @started
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

  update: (dt) =>
    @elapsed += dt
    @send_time dt

  draw: => -- do nothing, so we can store in entity lists


{
  :Sequence
}

