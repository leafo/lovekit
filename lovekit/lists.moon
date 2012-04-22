
import insert, remove from table

export *

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

    updated > 0

  draw: =>
    for item in *self
      item\draw! if item.alive


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

