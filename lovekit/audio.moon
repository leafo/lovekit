
import audio from love

class Audio
  new: (@dir="audio", @ext="wav") =>
    @sources = {}

  preload: (names) =>
    @get_source name for name in *names
    nil

  -- return a sequence that fades out audio
  fade_music: (t=1.0, callback_fn) =>
    music = @music
    volume = music\getVolume!
    min = music\getVolumeLimits!

    remaining = t
    Sequence ->
      during t, (dt) ->
        remaining -= dt
        vol = remaining/t * (volume - min) + min
        music\setVolume vol

      music\stop!
      callback_fn and callback_fn!

  get_source: (name, ext, source_type="static") =>
    return @sources[name] if @sources[name]

    ext = ext or @ext
    fname = @dir .. "/" .. name .. "." ..ext
    print "loading source(".. tostring(source_type) .. "):", fname
    source = audio.newSource fname, source_type
    with source
      @sources[name] = source

  play_music: (name, looping=true) =>
    @music\stop! if @music
    @current_music = name
    @music = with @get_source name, "ogg", "stream"
      \setVolume 0.5
      \setLooping looping
      \play!

  play: (name) =>
    s = @get_source name
    if s
      s\rewind!
      s\play!


{ :Audio }
