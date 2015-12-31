local inotify = require("inotify")
local config_char
config_char = function(n)
  return package.config:sub(n, n)
end
local dirsep, pathsep, wildcard = unpack((function()
  local _accum_0 = { }
  local _len_0 = 1
  local _list_0 = {
    1,
    3,
    5
  }
  for _index_0 = 1, #_list_0 do
    local n = _list_0[_index_0]
    _accum_0[_len_0] = config_char(n)
    _len_0 = _len_0 + 1
  end
  return _accum_0
end)())
local handle = inotify.init(true)
local actions = { }
local watching = { }
local insert
insert = table.insert
local Path = {
  exists = function(path)
    local file = io.open(path)
    do
      local _with_0 = file
      if file then
        local _
        do
          local _base_0 = file
          local _fn_0 = _base_0.close
          _ = function(...)
            return _fn_0(_base_0, ...)
          end
        end
      end
      return _with_0
    end
  end,
  write_file = function(path, content)
    do
      local _with_0 = io.open(path, "w")
      _with_0:write(content)
      _with_0:close()
      return _with_0
    end
  end,
  normalize = function(path)
    return path:gsub("^%./", "")
  end,
  basepath = function(path)
    return path:match("^(.*)/[^/]*$") or "."
  end,
  mkdir = function(path)
    return os.execute(("mkdir -p %s"):format(path))
  end,
  copy = function(src, dest)
    return os.execute(("cp %s %s"):format(src, dest))
  end,
  join = function(a, b)
    a = a:match("^(.*)/$") or a
    b = b:match("^/(.*)$") or b
    if a == "" then
      return b
    end
    if b == "" then
      return a
    end
    return a .. "/" .. b
  end
}
local watch
watch = function(fname, action)
  local dir = Path.basepath(fname)
  if not watching[dir] then
    local wd = handle:addwatch(dir, inotify.IN_CLOSE_WRITE)
    watching[dir] = wd
    watching[wd] = dir
  end
  actions[fname] = {
    action,
    unpack(actions[fname] or { })
  }
end
local is_watching
is_watching = function(fname)
  return actions[fname]
end
local update
update = function()
  local events = handle:read()
  if events then
    for _index_0 = 1, #events do
      local e = events[_index_0]
      local file_name = Path.join(watching[e.wd], e.name)
      if actions[file_name] then
        local _list_0 = actions[file_name]
        for _index_1 = 1, #_list_0 do
          local fn = _list_0[_index_1]
          fn()
        end
      end
    end
  end
end
local path_to_package
path_to_package = function(path)
  local search_paths
  if path:match("%.moon$") then
    search_paths = package.moonpath
  else
    search_paths = package.path
  end
  for s in (search_paths .. pathsep):gmatch("(.-)" .. pathsep) do
    local pattern = s:gsub("%.", "%%.")
    pattern = "^" .. pattern:gsub("%" .. wildcard, "(.-)") .. "$"
    local pkg_path = path:match(pattern)
    if pkg_path then
      return (pkg_path:gsub(dirsep, "."):gsub("^%.+", ""))
    end
  end
end
local absolute_name
absolute_name = function(cls, pkg_name)
  return cls.__name .. "::" .. pkg_name
end
local class_by_name = { }
local seen_classes = setmetatable({ }, {
  __mode = "k"
})
local watch_class
watch_class = function(cls)
  if seen_classes[cls] then
    return 
  end
  seen_classes[cls] = true
  local info = debug.getinfo(getmetatable(cls).__call)
  local source_name = "./" .. info.source:match("^%@(.*)$") or info.source
  local pkg_name = path_to_package(source_name)
  local a_name = absolute_name(cls, pkg_name)
  if class_by_name[a_name] then
    print("Replacing class...", a_name)
    local old_cls = class_by_name[a_name]
    cls.__reload_parent = old_cls
    while old_cls do
      local _list_0
      do
        local _accum_0 = { }
        local _len_0 = 1
        for key in pairs(old_cls.__base) do
          _accum_0[_len_0] = key
          _len_0 = _len_0 + 1
        end
        _list_0 = _accum_0
      end
      for _index_0 = 1, #_list_0 do
        local key = _list_0[_index_0]
        old_cls.__base[key] = nil
      end
      for key, value in pairs(cls.__base) do
        old_cls.__base[key] = value
      end
      old_cls = old_cls.__reload_parent
    end
    class_by_name[a_name] = cls
    return 
  end
  print("Watching", tostring(a_name) .. "[" .. tostring(source_name) .. "]")
  if not (is_watching(source_name)) then
    watch(source_name, function()
      print("Reloading:", pkg_name)
      package.loaded[pkg_name] = nil
      return require(pkg_name)
    end)
  end
  class_by_name[a_name] = cls
end
local is_class
is_class = function(obj)
  return type(obj) == "table" and obj.__base
end
local scan_for_classes
scan_for_classes = function(to_scan, accum)
  if accum == nil then
    accum = { }
  end
  if is_class(to_scan) and not accum[to_scan] then
    accum[to_scan] = true
    scan_for_classes(to_scan.__init, accum)
    for k, v in pairs(to_scan.__base) do
      scan_for_classes(v, accum)
    end
  elseif type(to_scan) == "function" then
    local i = 1
    while true do
      local _continue_0 = false
      repeat
        local name, val = debug.getupvalue(to_scan, i)
        i = i + 1
        if not (name) then
          break
        end
        if not is_class(val) or accum[val] then
          _continue_0 = true
          break
        end
        insert(accum, val)
        scan_for_classes(val, accum)
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end
  return accum
end
local handle_main_reload
handle_main_reload = function()
  local _list_0 = scan_for_classes(love.load)
  for _index_0 = 1, #_list_0 do
    local cls = _list_0[_index_0]
    watch_class(cls)
  end
end
local reload_require
do
  local require = require
  reload_require = function(mod_name)
    local seen = package.loaded[mod_name] ~= nil
    local mod = require(mod_name)
    if mod_name == "main" then
      handle_main_reload()
    end
    if not seen and type(mod) == "table" then
      for name, val in pairs(mod) do
        if is_class(val) then
          watch_class(val)
          local upvalue_classes = scan_for_classes(val)
          for _index_0 = 1, #upvalue_classes do
            local cls = upvalue_classes[_index_0]
            watch_class(cls)
          end
        end
      end
    end
    return mod
  end
end
local bind
bind = function(g)
  if g == nil then
    g = _G
  end
  local Image
  Image = g.Image
  if Image then
    local old_constructor = Image.__init
    Image.__init = function(self, ...)
      old_constructor(self, ...)
      if not (is_watching(self.fname)) then
        return watch(self.fname, (function()
          local _base_0 = self
          local _fn_0 = _base_0.reload
          return function(...)
            return _fn_0(_base_0, ...)
          end
        end)())
      end
    end
  end
  g.require = reload_require
  local timer
  timer = love.timer
  local old_step = timer.step
  timer.step = function()
    update()
    return old_step()
  end
  local old_run = love.run
  love.run = function(...)
    handle_main_reload()
    love.run = old_run
    return love.run(...)
  end
end
bind()
return {
  Path = Path,
  update = update,
  watch = watch,
  watch_class = watch_class,
  bind = bind
}
