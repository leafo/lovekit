
import insert, remove from table

box_sort = (a, b) ->
  abox = a.box
  bbox = b.box
  (abox and abox.y + abox.h or a.y) < (bbox and bbox.y + bbox.h or b.y)

export *

Set = (items) ->
  self = {}
  self[key] = true for key in *items
  self

-- a basic hashed linked list
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


-- a lua array that fills dead slots added items
-- uses .alive property of items in list to keep track of state
class DrawList
  show_boxes: false

  new: =>
    @dead_list = {}

  add: (item) =>
    dead_len = #@dead_list
    i = if dead_len > 0
      with @dead_list[dead_len]
        @dead_list[dead_len] = nil
    else
      #self + 1

    item.alive = true
    self[i] = item

  update: (dt, ...) =>
    i = 1
    updated = 0
    for item in *self
      if item.alive
        updated += 1
        alive = item\update dt, ...
        if not alive
          item.alive = false
          item\onremove! if item.onremove
          insert @dead_list, i

      i += 1

    updated > 0, updated

  draw: =>
    for item in *self
      if item.alive
        item\draw!
        item.box\outline! if @show_boxes and item.box

  -- sort based on depth (y value)
  draw_sorted: (sort_fn=box_sort)=>
    alive = [item for item in *self when item.alive]
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
    for i, b in ipairs self
      if b.alive
        b.alive = b\update dt, ...
        if not b.alive
          b\onremove! if b.onremove
          insert @dead_list, i

  draw: =>
    for b in *self
      b\draw! if b.alive

  add: (cls, ...) =>
    top = remove @dead_list
    out = if top
      o = self[top]
      setmetatable o, cls.__base if o.__class != cls
      cls.__init o, ...
      o
    else
      @_append cls ...

    out.alive = true
    out

  _append: (b) =>
    with b
      self[#self + 1] = b


-- Holds a collection of objects that have update/before/after methods
-- Only once instance of a class can be in list at a time
class EffectList
  new: (@obj) =>
    @current_effects = {}

  clear: (@obj) =>
    for k in pairs @current_effects
      @current_effects[k] = nil

    for i=1,#self
      self[i] = nil

  add: (effect) =>
    existing = @current_effects[effect.__class]
    if existing
      effect\replace self[existing]
      self[existing] = effect
    else
      table.insert self, effect
      @current_effects[effect.__class] = #self

  update: (dt) =>
    for i, e in ipairs self
      alive = e\update dt
      if not alive
        e.on_finish e if e.on_finish
        @current_effects[e.__class] = nil
        table.remove self, i

  apply: (fn) =>
    @before!
    fn!
    @after!

  before: =>
    e\before @obj for e in *self

  after: =>
    for i=#self,1,-1 -- reverse order
      self[i]\after @obj

