
import insert, remove from table

require "lovekit.support"

-- adds methods, wraps constructor
mixin = do
  empty_func = string.dump ->
  (mix) ->
    cls = get_local "self", 2
    base = cls.__base
    -- copy members
    for member_name, member_val in pairs mix.__base
      continue if member_name\match "^__"
      if existing = base[member_name]
        if type(existing) == "function" and type(member_val) == "function"
          -- before mode
          base[member_name] = (...) ->
            member_val ...
            existing ...
        else
          base[member_name] = member_val
      else
        base[member_name] = member_val

    -- constructor
    if mix.__init and string.dump(mix.__init) != empty_func
      old_ctor = cls.__init
      cls.__init = (...) ->
        old_ctor ...
        mix.__init ...


-- holds a queue of sequences
class Sequenced
  add_seq: (seq) =>
    if type(seq) == "function"
      seq = Sequence seq

    @sequence_queue or= {}
    insert @sequence_queue, seq

  update: (dt) =>
    queue = @sequence_queue
    return unless queue

    if not @current_seq and next queue
      @current_seq = remove queue, 1

    if @current_seq
      unless @current_seq\update dt
        @current_seq = nil

class HasParticles
  new: =>
    @particles = DrawList!

  draw_inner: =>
    @particles\draw_sorted!

  update: (dt) =>
    @particles\update dt

class KeyRepeat
  push_key_repeat: (...) =>
    @_key_repeat = love.keyboard.hasKeyRepeat!
    love.keyboard.setKeyRepeat ...

  pop_key_repeat: =>
   love.keyboard.setKeyRepeat @_key_repeat
   @_key_repeat = nil


{
  :mixin
  :Sequenced
  :HasParticles
  :KeyRepeat
}
