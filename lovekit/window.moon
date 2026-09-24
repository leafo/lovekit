
{:window, :mouse} = love

-- opens the window at design_w by design_h screen pixels, or fullscreen on
-- phones and displays too small for that (handhelds like the RG35XX are
-- 640x480). a size
-- in the env var named by opts.env, or a `--window 640x480` argument, wins
open_window = (opts={}) ->
  {:design_w, :design_h, :title, :env, :args} = opts

  error "open_window needs a design size" unless design_w and design_h

  size = env and os.getenv env

  if args
    for i, arg in ipairs args
      size = args[i + 1] if arg == "--window"

  if size
    w, h = size\match "^(%d+)x(%d+)$"
    error "bad --window size, expected WxH: #{size}" unless w
    window.setMode tonumber(w), tonumber(h)
  else
    dw, dh = window.getDesktopDimensions!
    -- phones take the whole screen, a windowed mode there leaves the status
    -- and navigation bars showing
    mobile = love._os == "Android" or love._os == "iOS"
    if mobile or dw < design_w or dh < design_h
      window.setMode 0, 0, fullscreen: true, fullscreentype: "desktop"
      mouse.setVisible false
    else
      window.setMode design_w, design_h

  window.setTitle title if title

{ :open_window }
