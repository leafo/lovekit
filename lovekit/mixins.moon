
get_local = (search_name, level=1) ->
  level += 1
  i = 1
  while true
    name, val = debug.getlocal level, i
    break unless name
    if name == search_name
      return val
    i += 1


export *

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

