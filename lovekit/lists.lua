local insert, remove
do
  local _obj_0 = table
  insert, remove = _obj_0.insert, _obj_0.remove
end
local box_sort
box_sort = function(a, b)
  local abox = a.box
  local bbox = b.box
  return (abox and abox.y + abox.h or a.y or 0) < (bbox and bbox.y + bbox.h or b.y or 0)
end
local Set
Set = function(items)
  do
    local s = { }
    for _index_0 = 1, #items do
      local key = items[_index_0]
      s[key] = true
    end
    return s
  end
end
local List
do
  local _class_0
  local _base_0 = {
    _node = function(self, item)
      if self.nodes[item] then
        error("list already contains item: " .. tostring(item))
      end
      local n = {
        value = item
      }
      self.nodes[item] = n
      return n
    end,
    _insert_after = function(self, node, after_node)
      local nxt = after_node.next
      node.prev = after_node
      node.next = nxt
      after_node.next = node
      nxt.prev = node
    end,
    _remove = function(self, node)
      node.prev.next = node.next
      node.next.prev = node.prev
    end,
    remove = function(self, item)
      local n = self.nodes[item]
      if n then
        self.nodes[item] = nil
        self:_remove(n)
        return true
      end
    end,
    clear = function(self)
      self.front = {
        next = nil
      }
      self.back = {
        prev = self.front
      }
      self.front.next = self.back
      self.nodes = { }
    end,
    push = function(self, item)
      local n = self:_node(item)
      return self:_insert_after(n, self.back.prev)
    end,
    shift = function(self, item)
      local n = self:_node(item)
      return self:_insert_after(n, self.front)
    end,
    each = function(self)
      return coroutine.wrap(function()
        local curr = self.front.next
        while curr ~= self.back do
          coroutine.yield(curr.value)
          curr = curr.next
        end
      end)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      return self:clear()
    end,
    __base = _base_0,
    __name = "List"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  List = _class_0
end
local EntityList
do
  local _class_0
  local _base_0 = {
    add = function(self, item)
      return insert(self, item)
    end,
    update = function(self, ...)
      local i = 1
      local len = #self
      while i <= len do
        local item = self[i]
        local alive = item:update(...)
        if alive then
          i = i + 1
        else
          item.alive = false
          if item.onremove then
            item:onremove()
          end
          table.remove(self, i)
          len = len - 1
        end
      end
      return len > 0
    end,
    draw = function(self, ...)
      local i = 1
      for _index_0 = 1, #self do
        local item = self[_index_0]
        i = i + 1
        item:draw(...)
      end
    end,
    draw_sorted = function(self)
      return self:draw()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self) end,
    __base = _base_0,
    __name = "EntityList"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  EntityList = _class_0
end
local DrawList
do
  local _class_0
  local _base_0 = {
    show_boxes = false,
    NULL = {
      alive = false
    },
    add = function(self, item)
      local i = next(self.dead_list)
      if i then
        self.dead_list[i] = nil
      else
        i = #self + 1
      end
      item.alive = true
      self[i] = item
      return item
    end,
    add_all = function(self, items)
      for _index_0 = 1, #items do
        local item = items[_index_0]
        self:add(item)
      end
    end,
    remove = function(self, thing)
      for i, item in ipairs(self) do
        if thing == item then
          self[i] = self.NULL
          if thing.alive then
            self.dead_list[i] = true
          end
          return true
        end
      end
      return false
    end,
    update = function(self, dt, ...)
      local i = 1
      local updated = 0
      for item_i, item in ipairs(self) do
        local _continue_0 = false
        repeat
          if item.alive then
            updated = updated + 1
            local alive = item:update(dt, ...)
            if self.dead_list[item_i] then
              _continue_0 = true
              break
            end
            if not alive then
              item.alive = false
              if item.onremove then
                item:onremove()
              end
              self.dead_list[i] = true
            end
          end
          i = i + 1
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      return updated > 0, updated
    end,
    draw = function(self, ...)
      for _index_0 = 1, #self do
        local item = self[_index_0]
        if item.alive then
          item:draw(...)
          if self.show_boxes then
            if item.box then
              item.box:outline()
            end
            if item.w then
              item:outline()
            end
          end
        end
      end
    end,
    draw_sorted = function(self, sort_fn)
      if sort_fn == nil then
        sort_fn = box_sort
      end
      local alive
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #self do
          local item = self[_index_0]
          if item.alive then
            _accum_0[_len_0] = item
            _len_0 = _len_0 + 1
          end
        end
        alive = _accum_0
      end
      table.sort(alive, sort_fn)
      for _index_0 = 1, #alive do
        local item = alive[_index_0]
        item:draw()
        if self.show_boxes and item.box then
          item.box:outline()
        end
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.dead_list = { }
    end,
    __base = _base_0,
    __name = "DrawList"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  DrawList = _class_0
end
local ReuseList
do
  local _class_0
  local _base_0 = {
    update = function(self, dt, ...)
      for i, b in ipairs(self) do
        if b.alive then
          b.alive = b:update(dt, ...)
          if not b.alive then
            if b.onremove then
              b:onremove()
            end
            insert(self.dead_list, i)
          end
        end
      end
    end,
    draw = function(self)
      for _index_0 = 1, #self do
        local b = self[_index_0]
        if b.alive then
          b:draw()
        end
      end
    end,
    add = function(self, cls, ...)
      local top = remove(self.dead_list)
      local out
      if top then
        local o = self[top]
        if o.__class ~= cls then
          setmetatable(o, cls.__base)
        end
        cls.__init(o, ...)
        out = o
      else
        out = self:_append(cls(...))
      end
      out.alive = true
      return out
    end,
    _append = function(self, b)
      do
        local _with_0 = b
        self[#self + 1] = b
        return _with_0
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.dead_list = { }
    end,
    __base = _base_0,
    __name = "ReuseList"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ReuseList = _class_0
end
local EffectList
do
  local _class_0
  local _base_0 = {
    clear = function(self)
      for k in pairs(self.current_effects) do
        self.current_effects[k] = nil
      end
      for i = 1, #self do
        self[i] = nil
      end
    end,
    add = function(self, effect)
      local existing = self.current_effects[effect.__class]
      if existing then
        effect:replace(self[existing])
        self[existing] = effect
      else
        table.insert(self, effect)
        self.current_effects[effect.__class] = #self
      end
    end,
    update = function(self, dt)
      for i, e in ipairs(self) do
        local alive = e:update(dt)
        if not alive then
          if e.on_finish then
            e.on_finish(e)
          end
          self.current_effects[e.__class] = nil
          table.remove(self, i)
        end
      end
    end,
    apply = function(self, fn)
      self:before()
      fn()
      return self:after()
    end,
    before = function(self, ...)
      local _list_0 = self
      for _index_0 = 1, #_list_0 do
        local e = _list_0[_index_0]
        e:before(self.obj or ...)
      end
    end,
    after = function(self, ...)
      for i = #self, 1, -1 do
        self[i]:after(self.obj or ...)
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, obj)
      self.obj = obj
      self.current_effects = { }
    end,
    __base = _base_0,
    __name = "EffectList"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  EffectList = _class_0
end
local ImpulseSet
do
  local _class_0
  local _base_0 = {
    clear = function(self)
      for k in pairs(self) do
        self[k] = false
      end
    end,
    clear_x = function(self)
      for k in pairs(self) do
        self[k][1] = 0
      end
    end,
    clear_y = function(self)
      for k in pairs(self) do
        self[k][2] = 0
      end
    end,
    sum = function(self)
      local ix, iy = 0, 0
      for _, v in pairs(self) do
        local _continue_0 = false
        repeat
          if not (v) then
            _continue_0 = true
            break
          end
          ix = ix + v[1]
          iy = iy + v[2]
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      return ix, iy
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "ImpulseSet"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ImpulseSet = _class_0
end
return {
  Set = Set,
  ImpulseSet = ImpulseSet,
  List = List,
  EntityList = EntityList,
  DrawList = DrawList,
  ReuseList = ReuseList,
  EffectList = EffectList
}
