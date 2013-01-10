-- How to use:
-- reloader = require "lovekit.reloader"
-- love.update = (dt) ->
--   reloader\update!
--
-- -- some_file.lua, must not be main!
-- import watch_class from require "lovekit.reloader"
-- class Something
--   watch_class self
--
-- -- images will be reloaded automatically by deafult

return false if disable_reloader
require "inotify"

config_char = (n) -> package.config\sub n,n
-- /, ;, ?
dirsep, pathsep, wildcard = unpack [config_char n for n in *{1,3,5}]

handle = inotify.init true
actions = {}
watching = {} -- directories being watched

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

update = =>
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
      return (pkg_path\gsub dirsep, ".")

absolute_name = (cls, pkg_name) ->
  cls.__name  .. "::" .. pkg_name

class_table = {} -- classes are are being watched

-- watch a class for reloading
watch_class = (cls) ->
  info = debug.getinfo getmetatable(cls).__call

  source_name = "./" .. info.source\match"^%@(.*)$" or info.source
  pkg_name = path_to_package source_name
  a_name = absolute_name cls, pkg_name

  if class_table[a_name]
    print "Replacing class...", a_name
    old_cls = class_table[a_name]

    cls.__reload_parent = old_cls

    while old_cls
      -- clear old one
      for key in *[key for key in pairs old_cls.__base]
        old_cls.__base[key] = nil
      
      -- copy new methods
      for key, value in pairs cls.__base
        old_cls.__base[key] = value
      old_cls = old_cls.__reload_parent
    
    class_table[a_name] = cls
    return

  print "Watching", a_name, source_name
  -- don't watch the same file multiple times
  unless is_watching source_name
    watch source_name, ->
      print "Reloading:", pkg_name
      package.loaded[pkg_name] = nil
      require pkg_name

  class_table[a_name] = cls

bind = (g=_G) ->
  {:Image} = g

  -- reload images when they are changed
  if Image
    old_constructor = Image.__init
    Image.__init = (...) =>
      old_constructor @, ...
      unless is_watching @fname
        reloader.watch @fname, @\reload

bind!

{
  :Path
  :update, :watch, :watch_class
  :bind
}

