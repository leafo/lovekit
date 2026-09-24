local window, mouse
do
  local _obj_0 = love
  window, mouse = _obj_0.window, _obj_0.mouse
end
local open_window
open_window = function(opts)
  if opts == nil then
    opts = { }
  end
  local design_w, design_h, title, env, args
  design_w, design_h, title, env, args = opts.design_w, opts.design_h, opts.title, opts.env, opts.args
  if not (design_w and design_h) then
    error("open_window needs a design size")
  end
  local size = env and os.getenv(env)
  if args then
    for i, arg in ipairs(args) do
      if arg == "--window" then
        size = args[i + 1]
      end
    end
  end
  if size then
    local w, h = size:match("^(%d+)x(%d+)$")
    if not (w) then
      error("bad --window size, expected WxH: " .. tostring(size))
    end
    window.setMode(tonumber(w), tonumber(h))
  else
    local dw, dh = window.getDesktopDimensions()
    local mobile = love._os == "Android" or love._os == "iOS"
    if mobile or dw < design_w or dh < design_h then
      window.setMode(0, 0, {
        fullscreen = true,
        fullscreentype = "desktop"
      })
      mouse.setVisible(false)
    else
      window.setMode(design_w, design_h)
    end
  end
  if title then
    return window.setTitle(title)
  end
end
return {
  open_window = open_window
}
