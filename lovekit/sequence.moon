
require "lovekit.support"

import min from math

export ^

-- Functions here yeild to the sequence object. The sequence object will yeild
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
  self.default_scope = default_scope

  new: (@fn, scope=Sequence.default_scope) =>
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

  send_time: (dt) =>
    -- loop until the time is sent
    while true do
      @start! if not @started
      return false if coroutine.status(@co) == "dead"

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
