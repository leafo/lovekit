
import audio from love

module "lovekit.audio", package.seeall

export  ^

class Audio
  new: (@dir="audio", @ext="wav") =>
    @sources = {}

  preload: (names) =>
    @get_source name for name in *names
    nil

  get_source: (name, ext) =>
    return @sources[name] if @sources[name]

    ext = ext or @ext
    fname = @dir .. "/" .. name .. "." ..ext
    print "loading source:", fname
    source = audio.newSource fname, "static"
    with source
      @sources[name] = source

  play: (name) =>
    s = @get_source name
    if s
      s\rewind!
      s\play!

