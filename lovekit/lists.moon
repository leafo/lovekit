
import insert, remove from table

box_sort = (a, b) ->
  abox = a.box
  bbox = b.box
  (abox and abox.y + abox.h or a.y or 0) < (bbox and bbox.y + bbox.h or b.y or 0)


Set = (items) ->
  with s = {}
    s[key] = true for key in *items

-- a linked list set
class List
  new: => @clear!

  _node: (item) =>
    error "list already contains item: " .. tostring item if @nodes[item]
    n = { value: item }
    @nodes[item] = n
    n

  _insert_after: (node, after_node) =>
    nxt = after_node.next
    node.prev = after_node
    node.next = nxt
    after_node.next = node
    nxt.prev = node

  _remove: (node) =>
   node.prev.next = node.next
   node.next.prev = node.prev

  remove: (item) =>
    n = @nodes[item]
    if n
      @nodes[item] = nil
      @_remove n
      true

  clear: =>
    @front = { next: nil }
    @back = { prev: @front }
    @front.next = @back
    @nodes = {}

  push: (item) =>
    n = @_node item
    @_insert_after n, @back.prev

  shift: (item) =>
    n = @_node item
    @_insert_after n, @front

  each: =>
    coroutine.wrap ->
      curr = @front.next
      while curr != @back
        coroutine.yield curr.value
        curr = curr.next


-- nothing efficient about this, same API as draw list but preserves insert order
class EntityList
  new: =>

  add: (item) =>
    insert @, item

  update: (...) =>
    i = 1
    len = #@

    while i <= len
      item = @[i]
      alive = item\update ...

      if alive
        i +=1
      else
        item.alive = false
        item\onremove! if item.onremove
        table.remove @, i
        len -= 1

    len > 0

  draw: (...) =>
    i = 1
    for item in *@
      i += 1
      item\draw ...

  draw_sorted: => @draw!

-- a lua array that fills dead slots added items
-- uses .alive property of items in list to keep track of state
class DrawList
  show_boxes: false
  NULL: { alive: false }

  new: =>
    @dead_list = {}

  add: (item) =>
    i = next @dead_list
    if i
      @dead_list[i] = nil
    else
      i = #@ + 1

    item.alive = true
    @[i] = item
    item

  add_all: (items) =>
    for item in *items
      @add item

  -- avoid, slow
  remove: (thing) =>
    for i, item in ipairs @
      if thing == item
        @[i] = @NULL
        @dead_list[i] = true if thing.alive
        return true

    false

  update: (dt, ...) =>
    i = 1
    updated = 0
    for item_i, item in ipairs @
      if item.alive
        updated += 1
        alive = item\update dt, ...

        -- if item was removed during update
        continue if @dead_list[item_i]

        if not alive
          item.alive = false
          item\onremove! if item.onremove
          @dead_list[i] = true

      i += 1

    updated > 0, updated

  draw: (...) =>
    for item in *@
      if item.alive
        item\draw ...
        if @show_boxes
          item.box\outline! if item.box
          item\outline! if item.w

  -- sort based on depth (y value)
  draw_sorted: (sort_fn=box_sort)=>
    alive = [item for item in *@ when item.alive]
    table.sort alive, sort_fn

    for item in *alive
      item\draw!
      item.box\outline! if @show_boxes and item.box

-- a simple array that reuses the tables created for objects when they are dead
-- better than "DeadList" above
class ReuseList
  new: =>
    @dead_list = {}

  update: (dt, ...) =>
    for i, b in ipairs @
      if b.alive
        b.alive = b\update dt, ...
        if not b.alive
          b\onremove! if b.onremove
          insert @dead_list, i

  draw: =>
    for b in *@
      b\draw! if b.alive

  add: (cls, ...) =>
    top = remove @dead_list
    out = if top
      o = @[top]
      setmetatable o, cls.__base if o.__class != cls
      cls.__init o, ...
      o
    else
      @_append cls ...

    out.alive = true
    out

  _append: (b) =>
    with b
      @[#@ + 1] = b


-- Holds a collection of objects that have update/before/after methods
-- Only once instance of a class can be in list at a time
class EffectList
  new: (@obj) =>
    @current_effects = {}

  clear: =>
    for k in pairs @current_effects
      @current_effects[k] = nil

    for i=1,#@
      @[i] = nil

  add: (effect) =>
    existing = @current_effects[effect.__class]
    if existing
      effect\replace @[existing]
      @[existing] = effect
    else
      table.insert @, effect
      @current_effects[effect.__class] = #@

  -- TODO: combine on_finish with the callback?
  update: (dt) =>
    for i, e in ipairs @
      alive = e\update dt
      if not alive
        e.on_finish e if e.on_finish
        @current_effects[e.__class] = nil
        table.remove @, i

  apply: (fn) =>
    @before!
    fn!
    @after!

  before: (...) =>
    e\before @obj or ... for e in *@

  after: (...) =>
    for i=#@,1,-1 -- reverse order
      @[i]\after @obj or ...

class ImpulseSet
  clear: =>
    for k in pairs @
      @[k] = false

  clear_x: =>
    for k in pairs @
      @[k][1] = 0

  clear_y: =>
    for k in pairs @
      @[k][2] = 0

  sum: =>
    ix, iy = 0, 0
    for _,v in pairs @
      continue unless v
      ix += v[1]
      iy += v[2]

    ix, iy
{
  :Set
  :ImpulseSet
  :List
  :EntityList
  :DrawList
  :ReuseList
  :EffectList
}

