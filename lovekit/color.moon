
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

export *

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

