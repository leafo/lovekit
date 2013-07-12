require "lovekit.mixins"

import insert from table

describe "mixins", ->
  it "should mixin mixins", ->
    log = {}

    class Mixin
      new: =>
        insert log, "initializing Mixin"
        @thing = { "hello" }

      poop: =>

      add_one: (num) =>
        insert log, "Before add_one (Mixin), #{num}"

    class Mixin2
      new: =>
        insert log, "initializing Mixin2"

      add_one: (num) =>
        insert log, "Before add_one (Mixin2), #{num}"

    class One
      mixin Mixin
      mixin Mixin2

      add_one: (num) =>
        num + 1

      new: =>
        insert log, "initializing One"

    o = One!
    assert.equal o\add_one(12), 13
    assert.same log, {
      "initializing One"
      "initializing Mixin"
      "initializing Mixin2"
      "Before add_one (Mixin2), 12"
      "Before add_one (Mixin), 12"
    }

