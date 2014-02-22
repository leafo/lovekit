
import graphics from love

rgb_helper = (comp, temp1, temp2) ->
  if comp < 0
    comp += 1
  elseif comp > 1
    comp -= 1

  if 6 * comp < 1
    temp1 + (temp2 - temp1) * 6 * comp
  elseif 2 * comp < 1
    temp2
  elseif 3 * comp < 2
    temp1 + (temp2 - temp1) * (2/3 - comp) * 6
  else
    temp1

-- h: 0 to 360
-- s, l: 0 to 100
hsl_to_rgb = (h,s,l) ->
  h = h / 360
  s = s / 100
  l = l / 100

  r,g,b = nil

  if s == 0
    r = l
    g = l
    b = l
  else
    temp2 = if l < 0.5
      l * (1 + s)
    else
      l + s - l * s

    temp1 = 2 * l - temp2

    r = rgb_helper h + 1/3, temp1, temp2
    g = rgb_helper h,       temp1, temp2
    b = rgb_helper h - 1/3, temp1, temp2

  r * 255, g * 255, b * 255

rgb_to_hsl = (r,g,b) ->
  r = r / 255
  g = g / 255
  b = b / 255

  min = math.min r, g, b
  max = math.max r, g, b

  s = 0
  h = 0
  l = (min + max) / 2

  if min != max
    s = if l < 0.5
      (max - min) / (max + min)
    else
      (max - min) / (2 - max - min)

    h = switch max
      when r
        (g - b) / (max - min)
      when g
        2 + (b - r) / (max - min)
      when b
        4 + (r - g) / (max - min)

  h += 6 if h < 0
  h * 60, s * 100, l * 100

-- hmm
hash_string = do
  cache = {}
  (str) ->
    hash = cache[str]

    unless hash
      bytes = { string.byte str, 1, #str }
      hash = 0
      for i,b in ipairs bytes
        hash += bytes[i] ^ (4 - (i - 1) % 4)
      cache[str] = hash

    hash

-- hash to hue
hash_to_color = (str, s=60, l=60) ->
  num = hash_string(str) % 360
  hsl_to_rgb num, s, l

-- stacks colors by multiplying them
class ColorStack
  red: {255,0,0}
  green: {0,255,0}
  blue: {0,0,255}

  new: =>
    @length = 1
    @stack = { 255,255,255,255 }

  push: (r,g,b,a) =>
    {stack: s, length: l} = @

    if type(r) == "table"
      r,g,b,a = unpack r

    r or= 255
    g or= 255
    b or= 255
    a or= 255

    top = l * 4 + 1
    l += 1

    r = r * s[top - 4] / 255
    g = g * s[top - 3] / 255
    b = b * s[top - 2] / 255
    a = a * s[top - 1] / 255

    s[top]     = r
    s[top + 1] = g
    s[top + 2] = b
    s[top + 3] = a

    @length = l
    graphics.setColor r,g,b,a

  -- override the color on top, multiplying with one before
  set: (...) =>
    @length -= 1
    @push ...

  -- push just alpha, stupid optimization?
  pusha: (a) =>
    {stack: s, length: l} = @
    top = l * 4 + 1
    l += 1

    r = s[top - 4]
    g = s[top - 3]
    b = s[top - 2]
    a = a * s[top - 1] / 255

    s[top]     = r
    s[top + 1] = g
    s[top + 2] = b
    s[top + 3] = a

    @length = l
    graphics.setColor r,g,b,a

  pop: (n=1) =>
    {stack: s, length: l} = @
    l -= 1
    top = l * 4 + 1

    s[top + 3] = nil
    s[top + 2] = nil
    s[top + 1] = nil
    s[top] = nil

    @length = l
    return @pop n - 1 if n > 1
    graphics.setColor s[top - 4], s[top - 3], s[top - 2], s[top - 1]

  current: =>
    s = @stack
    start = (@length - 1) * 4 + 1
    s[start], s[start + 1], s[start + 2], s[start + 3]

  -- only use this to reset color if something else changes it
  apply: =>
    graphics.setColor @current!

COLOR = ColorStack!

{ :hsl_to_rgb, :rgb_to_hsl, :hash_string, :hash_to_color, :ColorStack, :COLOR }


