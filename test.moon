export love = { graphics: {} }

import Vec2d from require "lovekit.geometry"

a = Vec2d(0, 0.5)
print a
a = a\rotate math.pi * 2 / 3
print a
a = a\rotate math.pi * 2 / 3
print a