local Controller
Controller = require("lovekit.input").Controller
local config, current, refresh
local find_pads
find_pads = function()
  local _accum_0 = { }
  local _len_0 = 1
  local _list_0 = love.joystick.getJoysticks()
  for _index_0 = 1, #_list_0 do
    local j = _list_0[_index_0]
    if j:isGamepad() then
      _accum_0[_len_0] = j
      _len_0 = _len_0 + 1
    end
  end
  return _accum_0
end
local setup
setup = function(opts)
  if opts == nil then
    opts = { }
  end
  config = opts
  return refresh()
end
local build
build = function(into)
  local opts = config or { }
  local pad = find_pads()[opts.pad or 1]
  local controller = Controller(opts.keys or Controller.default_mapping, pad)
  if pad and opts.gamepad then
    controller:add_mapping((function()
      local _tbl_0 = { }
      for name, btns in pairs(opts.gamepad) do
        _tbl_0[name] = {
          joystick = btns
        }
      end
      return _tbl_0
    end)())
  end
  if into then
    for k in pairs(into) do
      into[k] = nil
    end
    for k, v in pairs(controller) do
      into[k] = v
    end
    controller = into
  end
  if opts.on_build then
    opts.on_build(controller, pad)
  end
  return controller
end
local get
get = function()
  current = current or build()
  return current
end
refresh = function()
  if not (current) then
    return 
  end
  return build(current)
end
local has_pad
has_pad = function()
  return get().joystick ~= nil
end
local prompt
prompt = function(pad_label, key_label)
  return function()
    if has_pad() then
      return pad_label
    else
      return key_label
    end
  end
end
local bind
bind = function(love)
  local _list_0 = {
    "joystickadded",
    "joystickremoved"
  }
  for _index_0 = 1, #_list_0 do
    local event = _list_0[_index_0]
    local previous = love[event]
    love[event] = function(...)
      refresh()
      if previous then
        return previous(...)
      end
    end
  end
end
return {
  setup = setup,
  get = get,
  refresh = refresh,
  has_pad = has_pad,
  prompt = prompt,
  bind = bind,
  find_pads = find_pads
}
