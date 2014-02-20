
import restore from require "spec.helpers"

describe "support", ->
  setup ->
    require "lovekit.support"

  teardown restore

  it "should set lazy value", ->
    cats_called = 0
    hello_called = 0
    eat_called = 0

    class Base
      what: "world"
      lazy_value @, "cats", ->
        cats_called += 1
        "meow"

    class Test extends Base
      real: "hello"
      lazy_value @, "hello", ->
        hello_called += 1
        "world"

      lazy_value @, "eat", ->
        eat_called += 1
        "me"

    t = Test!
    assert.same t.cats, "meow"
    assert.same t.real, "hello"
    assert.same t.what, "world"
    assert.same t.hello, "world"
    assert.same t.eat, "me"

    t.hello
    t.eat

    assert.same hello_called, 1
    assert.same eat_called, 1

  it "should lazy class value", ->
    class Thing
      lazy color: -> "blue"

    assert.same Thing.color, "blue"

  it "should lazy with short syntax", ->
    class Thing
      lazy hello: -> "world"

    t = Thing!
    assert.same t.hello, "world"

