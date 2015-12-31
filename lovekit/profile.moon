
module "lovekit.profile", package.seeall

import graphics from love

export ^

class Counter
  new: =>
    @counts = {}

  count: (label) =>
    old = @counts[label]
    @counts[label] = if old
      old + 1
    else
      1

  count_func: (obj, func_name, label=func_name) =>
    @counts[label] = 0
    old_fn = obj[func_name]
    obj[func_name] = (...) ->
      @counts[label] += 1
      old_fn ...

  reset: =>
    for key in pairs @counts
      @counts[key] = 0

  -- shows the top n counts
  format_message: (n=10) =>
    tuples = [{k,v} for k,v in pairs @counts]
    table.sort tuples, (a,b) ->
      a[2] < b[2]

    final = for i=#tuples, #tuples - n, -1
      break unless tuples[i]
      tuples[i]

    table.concat [t[1] .. ": " .. t[2] for t in *final], "\n"

  draw: (x=0,y=0, reset=true) =>
    msg = @format_message!
    graphics.print msg, x, y
    @reset! if reset

