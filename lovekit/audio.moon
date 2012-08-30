
import audio from love

module "lovekit.audio", package.seeall

export  ^

class Audio
  new: (@dir="audio", @ext="wav") =>
    @sources = {}

  preload: (names) =>
    @get_source name for name in *names
    nil

  get_source: (name, ext, source_type="static") =>
    return @sources[name] if @sources[name]

    ext = ext or @ext
    fname = @dir .. "/" .. name .. "." ..ext
    print "loading source(".. tostring(source_type) .. "):", fname
    source = audio.newSource fname, source_type
    with source
      @sources[name] = source

  play_music: (name) =>
    @music\stop! if @music

    @music = with @get_source name, "ogg", "steam"
      \setVolume 0.5
      \setLooping true
      \play!

  play: (name) =>
    s = @get_source name
    if s
      s\rewind!
      s\play!

