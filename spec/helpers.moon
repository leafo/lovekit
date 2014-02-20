
local loaded, global

save = ->
  error "already saved state" if loaded or global
  loaded = { k,v for k,v in pairs package.loaded }
  global = { k,v for k,v in pairs _G }

restore = ->
  error "never saved state" unless loaded and global

  for k in pairs package.loaded
    package.loaded[k] = loaded[k]

  for k in pairs _G
    _G[k] = global[k]

save!

{ :save, :restore }
