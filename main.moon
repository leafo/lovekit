
{graphics: g} = love

example_prefix = "examples."
examples = {
  "tilemap"
  "curves"
  "ui"
}

load_example = (num) ->
  love.draw = nil
  love.keypressed = nil
  love.update = nil

  fn = require example_prefix .. assert(examples[num], "invalid example")

  start = love.timer.getTime!
  fn!
  print "example load", love.timer.getTime() - start

  unless love.keypressed
    love.keypressed = (key) ->
      if key == "escape"
        love.event.quit()

love.load = ->
  love.draw = ->
    g.print "Choose an example:", 10, 10
    for i, name in ipairs examples
      g.print "#{i}. #{name}", 10, 20 + 20 * i

  love.update = (dt) ->

  love.keypressed = (key) ->
    if key == "escape"
      love.event.quit()

    if num = tonumber(key)
      load_example num if examples[num]

