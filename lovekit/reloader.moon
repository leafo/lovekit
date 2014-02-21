-- How to use:
-- require "lovekit.reloader"

inotify = require "inotify"

config_char = (n) -> package.config\sub n,n
-- /, ;, ?
dirsep, pathsep, wildcard = unpack [config_char n for n in *{1,3,5}]

handle = inotify.init true
actions = {}
watching = {} -- directories being watched

import insert from table

Path =
  exists: (path) ->
    file = io.open path
    with file
      file\close if file
  write_file: (path, content) ->
    with io.open path, "w"
      \write content
      \close!
  normalize: (path) ->
    path\gsub "^%./", ""
  basepath: (path) ->
    path\match"^(.*)/[^/]*$" or "."
  mkdir: (path) ->
    os.execute ("mkdir -p %s")\format path
  copy: (src, dest) ->
    os.execute ("cp %s %s")\format src, dest
  join: (a, b) ->
    a = a\match"^(.*)/$" or a
    b = b\match"^/(.*)$" or b
    return b if a == ""
    return a if b == ""
    a .. "/" .. b

watch = (fname, action) ->
  dir = Path.basepath fname
  if not watching[dir]
    wd = handle\addwatch dir, inotify.IN_CLOSE_WRITE
    watching[dir] = wd
    watching[wd] = dir
  actions[fname] = { action, unpack actions[fname] or {} }

is_watching = (fname) ->
  actions[fname]

update = ->
  events = handle\read!
  if events
    for e in *events
      file_name = Path.join watching[e.wd], e.name
      if actions[file_name]
        fn! for fn in *actions[file_name]

path_to_package = (path) ->
  search_paths = if path\match "%.moon$"
    package.moonpath
  else
    package.path

  for s in (search_paths .. pathsep)\gmatch "(.-)"..pathsep
    pattern = s\gsub "%.", "%%."
    pattern = "^" .. pattern\gsub("%"..wildcard, "(.-)") .. "$"
    pkg_path = path\match pattern
    if pkg_path
      return (pkg_path\gsub(dirsep, ".")\gsub "^%.+", "")

absolute_name = (cls, pkg_name) ->
  cls.__name  .. "::" .. pkg_name

class_by_name = {} -- classes being watched indexed by name
seen_classes = setmetatable {}, __mode: "k"

-- watch a class for reloading
watch_class = (cls) ->
  return if seen_classes[cls]
  seen_classes[cls] = true
  info = debug.getinfo getmetatable(cls).__call

  source_name = "./" .. info.source\match"^%@(.*)$" or info.source
  pkg_name = path_to_package source_name
  a_name = absolute_name cls, pkg_name

  if class_by_name[a_name]
    print "Replacing class...", a_name
    old_cls = class_by_name[a_name]

    cls.__reload_parent = old_cls

    while old_cls
      -- clear old one
      for key in *[key for key in pairs old_cls.__base]
        old_cls.__base[key] = nil

      -- copy new methods
      for key, value in pairs cls.__base
        old_cls.__base[key] = value
      old_cls = old_cls.__reload_parent

    class_by_name[a_name] = cls
    return

  print "Watching", "#{a_name}[#{source_name}]"
  -- don't watch the same file multiple times
  unless is_watching source_name
    watch source_name, ->
      print "Reloading:", pkg_name
      package.loaded[pkg_name] = nil
      require pkg_name

  class_by_name[a_name] = cls

is_class = (obj) ->
  type(obj) == "table" and obj.__base

-- tries to find classes from locals in a function or a class's methods
scan_for_classes = (to_scan, accum={}) ->
  if is_class(to_scan) and not accum[to_scan]
    accum[to_scan] = true
    -- scan constructor or methods
    scan_for_classes to_scan.__init, accum
    for k,v in pairs to_scan.__base
      scan_for_classes v, accum
  elseif type(to_scan) == "function"
    i = 1
    while true
      name, val = debug.getupvalue to_scan, i
      i += 1
      break unless name
      continue if not is_class(val) or accum[val]
      insert accum, val
      scan_for_classes val, accum

  accum


-- main isn't a module so we scan love.load for upvalues
handle_main_reload = ->
  for cls in *scan_for_classes love.load
    watch_class cls

reload_require = do
  require = require
  (mod_name) ->
    seen = package.loaded[mod_name] != nil
    mod = require mod_name

    if mod_name == "main"
      handle_main_reload!

    -- look for moonscript classes to call watch_class on
    if not seen and type(mod) == "table"
      for name, val in pairs mod
        if is_class val
          watch_class val
          -- scan constructor and methods for more classes to watch
          upvalue_classes = scan_for_classes val
          for cls in *upvalue_classes
            watch_class cls

    mod

bind = (g=_G) ->
  {:Image} = g

  -- reload images when they are changed
  if Image
    old_constructor = Image.__init
    Image.__init = (...) =>
      old_constructor @, ...
      unless is_watching @fname
        watch @fname, @\reload

  -- watch requires
  g.require = reload_require

  -- insert reloader to run with timer.step :)
  import timer from love
  old_step = timer.step
  timer.step = ->
    update!
    old_step!

  -- add reloader to main
  old_run = love.run
  love.run = (...) ->
    handle_main_reload!
    love.run = old_run
    love.run ...

bind!

{
  :Path
  :update, :watch, :watch_class
  :bind
}

