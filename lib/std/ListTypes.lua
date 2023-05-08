local Vector = class "Vector" do
    ---@param T type
    ---@param base table
    function Vector.new(T, base)
        assert(T and typeof(T) == "string", "cannot create std::Vector with no type")
        return Vector:constructor(function(self)
            self.cache = base or {}
            self.type = T

            function self.meta.__tostring()
                return self:ToString()
            end

            function self.meta.__len()
                return self:Size()
            end

            function self.meta.__bnot()
                return self:Values()
            end

            ---@return Vector
            function self.meta.__band(_, vec)
                return self:Union(vec)
            end
        end)
    end

    local function TypeEquals(value, expected)
        if typeof(value) == expected then
            return true
        end
        return false
    end

    local function VectorTypeError(value, expected)
        if typeof(value) == "Function" and expected == "function" then
            return
        end
        throw(Error(("VectorTypeError: \n\tgot: %s\n\texpected: %s"):format(typeof(value), expected)), 3)
    end

    local function AssertType(self, value)
        if not TypeEquals(value, self.type) then
            VectorTypeError(value, self.type)
        end
    end

    function Vector:Join(sep)
        local res = ""
        for v in ~self do
            res = res + v
            if self:IndexOf(v) ~= #self then
                res = res + sep
            end
        end
        return res
    end

    function Vector:Fill(amount, callback)
        for i = 1, amount do
            self:Add((callback or lambda "|i| -> i")(i))
        end
    end

    function Vector:Filter(predicate)
        local res = Vector(self.type)
        for v in ~self do
            local i = self:IndexOf(v)
            if predicate(v, i) then
                res:Add(v)
            end
        end
        return res
    end

    function Vector:Map(transform)
        local res = Vector(self.type)
        for v in ~self do
            local i = self:IndexOf(v)
            res:Add(transform(v, i))
        end
        return res
    end

    function Vector:At(idx)
        return self.cache[idx]
    end

    ---@param vec Vector
    ---@return Vector
    function Vector:Union(vec)
        assert(
            TypeEquals(vec, "Vector") and vec.type == self.type,
            "expected to merge Vector<" + self.type + ">"
        )

        local res = Vector(self.type, self.cache)
        for v in ~vec do
            res:Add(v)
        end
        return res
    end

    function Vector:Slice(start, finish)
        finish = finish or #self
        local res = Vector(self.type)
        for i = start, finish do
            res:Add(self:At(i))
        end
        return res
    end

    function Vector:Add(value)
        AssertType(self, value)
        table.insert(self.cache, value)
    end

    function Vector:First()
        return self.cache[1]
    end

    function Vector:Last()
        return self.cache[#self]
    end

    function Vector:Shift()
        self:Remove(self:First())
    end

    function Vector:Pop()
        self:Remove(self:Last())
    end

    function Vector:Remove(value)
        AssertType(self, value)
        local idx = self:IndexOf(value)
            self:RemoveIndex(idx)
    end

    function Vector:RemoveIndex(idx)
        table.remove(self.cache, idx)
    end

    function Vector:ForEach(callback)
        for i in self:Indices() do
            local v = self.cache[i]
            callback(v, i)
        end
    end

    function Vector:IndexOf(value)
        AssertType(self, value)
        local res
        self:ForEach(function(v, i)
            if v == value then
                res = i
            end
        end)
        return res
    end

    function Vector:Unpack()
        return table.unpack(self.cache)
    end

    function Vector:Indices()
        return pairs(self.cache)
    end

    function Vector:Values()
        return values(self.cache)
    end

    function Vector:Display()
        repr(self)
    end

    function Vector:ToTable()
        return self.cache
    end

    function Vector:Size()
        return #self:ToTable()
    end

    function Vector:ToString()
        return ("Vector<%s>( size=%s )"):format(self.type, self:Size())
    end

    function Vector:__repr()
        repr(self.cache)
    end
end

---@class List
---@field cache table
local List = class "List" do
    ---@param base table
    function List.new(base)
        return constructor(List, function(self)
            self.cache = base or {}

            function self.meta.__tostring()
                return self:ToString()
            end

            function self.meta.__len()
                return self:Size()
            end

            function self.meta.__bnot()
                return self:Values()
            end

            function self.meta.__band(_, list)
                return self:Union(list)
            end
        end)
    end

    function List:Union(list)
        local res = List(self.cache)
        for v in ~list do
            res:Add(v)
        end
        return res
    end

    function List:Slice(start, finish)
        finish = finish or #self
        local res = List(self.cache)
        for i = start, finish do
            res:Add(self:At(i))
        end
        return res
    end

    function List:Shift()
        local val = self:First()
        self:Remove(val)
        return val
    end

    function List:Filter(predicate)
        local res = List()
        for v in ~self do
            local i = self:IndexOf(v)
            if predicate(v, i) then
                res:Add(v)
            end
        end
        return res
    end

    function List:Map(transform)
        local res = List()
        for v in ~self do
            local i = self:IndexOf(v)
            res:Add(transform(v, i))
        end
        return res
    end

    function List:Unpack()
        return table.unpack(self.cache)
    end

    function List:At(idx)
        return self.cache[idx]
    end

    function List:Join(sep)
        local res = ""
        for v in ~self do
            res = res + v
            if self:IndexOf(v) ~= #self then
                res = res + sep
            end
        end
        return res
    end

    function List:First()
        return self.cache[1]
    end

    function List:Last()
        return self.cache[#self.cache]
    end

    function List:Add(value)
        table.insert(self.cache, value)
        return self
    end

    function List:RemoveIndex(idx)
        table.remove(self.cache, idx)
        return self
    end

    function List:Remove(value)
        local idx = self:IndexOf(value)
        return self:RemoveIndex(idx)
    end

    function List:ForEach(callback)
        for i in self:Indices() do
            local v = self.cache[i]
            callback(v, i)
        end
    end

    function List:IndexOf(value)
        local res
        self:ForEach(function(v, i)
            if v == value then
                res = i
            end
        end)
        return res
    end

    function List:Indices()
        return pairs(self.cache)
    end

    function List:Values()
        return values(self.cache)
    end

    function List:Display()
        repr(self)
    end

    function List:ToTable()
        return self.cache
    end

    function List:Size()
        return #self:ToTable()
    end

    function List:ToString()
        return ("List( size=%s )"):format(self:Size())
    end

    function List:__repr()
        repr(self.cache)
    end
end

---@class Stack
---@field cache table
local Stack = class "Stack" do
    ---@param base table
    function Stack.new(base)
        return constructor(Stack, function(self)
            self.cache = base or {}

            function self.meta.__tostring()
                return self:ToString()
            end

            function self.meta.__len()
                return self:Size()
            end

            function self.meta.__bnot()
                return self:Values()
            end

            function self.meta.__band(_, stack)
                return self:Union(stack)
            end
        end)
    end

    function Stack:Unpack()
        return table.unpack(self.cache)
    end

    function Stack:Union(stack)
        local res = Stack(self.cache)
        for v in ~stack do
            res:Push(v)
        end
        return res
    end

    function Stack:First()
        return self.cache[1]
    end

    function Stack:Last()
        return self.cache[#self.cache]
    end

    function Stack:Push(value)
        table.insert(self.cache, value)
        return #self.cache
    end

    function Stack:Pop()
        local idx = #self.cache
        local element = self.cache[idx]
        table.remove(self.cache, idx)
        return element
    end

    function Stack:Peek(offset)
        return self.cache[#self.cache + (offset or 0)]
    end

    function Stack:Values()
        return values(self.cache)
    end

    function Stack:Size()
        return #self:ToTable()
    end

    function Stack:ToString()
        return ("Stack( size=%s )"):format(self:Size())
    end

    function Stack:ToTable()
        return self.cache
    end

    function Stack:__repr()
        repr(self.cache)
    end
end

---@class Map
---@field K type
---@field V type
---@field cache table
local Map = class "Map" do
    ---@param K type
    ---@param V type
    ---@param base table
    function Map.new(K, V, base)
        assert(K and typeof(K) == "string", "Map must have key type")
        assert(V and typeof(V) == "string", "Map must have value type")
        return constructor(Map, function(self)
            self.cache = base or {}
            self.K = K
            self.V = V

            function self.meta.__tostring()
                return self:ToString()
            end

            function self.meta.__len()
                return self:Size()
            end

            function self.meta.__bnot()
                return self:Values()
            end
        end)
    end

    local function TypeEquals(value, expected)
        if typeof(value) == expected then
            return true
        end
        return false
    end

    local function MapTypeError(value, expected)
        throw(Error(("MapTypeError: \n\tgot: %s\n\texpected: %s"):format(type(value), expected)))
    end

    local function AssertType(value, expected)
        if not TypeEquals(value, expected) then
            MapTypeError(value, expected)
        end
    end

    function Map:Union(map)
        local res = Map(self.K, self.V, self.cache)
        for k, v in map:Keys() do
            res:Set(k, v)
        end
        return res
    end

    function Map:Set(key, value)
        AssertType(key, self.K)
        AssertType(value, self.V)
        self.cache[key] = value
    end

    function Map:Get(key)
        AssertType(key, self.K)
        return self.cache[key]
    end

    function Map:Delete(key)
        AssertType(key, self.K)
        self.cache[key] = nil
    end

    function Map:Keys()
        return pairs(self.cache)
    end

    function Map:Values()
        return values(self.cache)
    end

    function Map:Display()
        repr(self)
    end

    function Map:ToTable()
        return self.cache
    end

    function Map:ToString()
        return ("Map<%s, %s>( size=%s )"):format(self.K, self.V, self:Size())
    end

    function Map:Size()
        local count = 0
        for _ in self:Keys() do
            count = count + 1
        end
        return count
    end

    function Map:__repr()
        repr(self.cache)
    end
end

---@class Queue : Class
---@field cache table
local Queue = class "Queue" do
    ---@param base? table
    ---@return Queue
    function Queue.new(base)
        return constructor(Queue, function(self)
            self.cache = base or {}

            function self.meta.__len()
                return self:Size()
            end

            function self.meta.__bnot()
                return self:Values()
            end

            function self.meta.__band(_, queue)
                return self:Union(queue)
            end
        end)
    end

    function Queue:Unpack()
        return table.unpack(self.cache)
    end

    function Queue:Union(queue)
        local res = Queue(self.cache)
        for v in ~queue do
            res:Add(v)
        end
        return res
    end

    function Queue:Slice(start, finish)
        finish = finish or #self
        local res = Queue()
        for i = start, finish do
            res:Add(self:At(i))
        end
        return res
    end

    function Queue:First()
        return self:At(1)
    end

    function Queue:Last()
        return self:At(#self)
    end

    function Queue:At(idx)
        return self.cache[idx]
    end

    function Queue:Enqueue(value)
        table.insert(self.cache, 1, value)
    end

    function Queue:Dequeue()
        local v = self:Last()
        table.remove(self.cache, #self)
        return v
    end

    function Queue:Indices()
        return pairs(self.cache)
    end

    function Queue:Values()
        return values(self.cache)
    end

    function Queue:Size()
        return #self:ToTable()
    end

    function Queue:ToTable()
        return self.cache
    end

    function Queue:ToString()
        return ("Queue( size=%s )"):format(self:Size())
    end

    function Queue:__repr()
        repr(self.cache)
    end
end

---@class Deque : Queue
---@field cache table
local Deque = class "Deque" do
    ---@param base table
    function Deque.new(base)
        extend(Deque, Queue.new(base))
        return constructor(Deque, function(self)
            function self.meta.__tostring()
                return self:ToString()
            end

            function self.meta.__len()
                return self:Size()
            end

            function self.meta.__bnot()
                return self:Values()
            end
        end)
    end

    function Deque:Unpack()
        return table.unpack(self.cache)
    end

    function Deque:Slice(start, finish)
        finish = finish or #self
        local res = Deque()
        for i = start, finish do
            res:AddLast(self:At(i))
        end
        return res
    end

    function Deque:At(idx)
        return self.cache[idx]
    end

    function Deque:AddFirst(value)
        self:Enqueue(value)
    end

    function Deque:RemoveFirst()
        table.remove(self.cache, 1)
    end

    function Deque:AddLast(value)
        table.insert(self.cache, value)
    end

    function Deque:RemoveLast()
        self:Dequeue()
    end

    function Deque:Indices()
        return pairs(self.cache)
    end

    function Deque:Values()
        return values(self.cache)
    end

    function Deque:Size()
        return #self:ToTable()
    end

    function Deque:ToTable()
        return self.cache
    end

    function Deque:ToString()
        return ("Deque( size=%s )"):format(self:Size())
    end

    function Deque:__repr()
        repr(self.cache)
    end
end

---@class Pair
---@field first any
---@field second any
local Pair = class "Pair" do
    function Pair.new(first, second)
        return constructor(Pair, function(self)
            self.first = first
            self.second = second

            function self.meta.__bnot()
                return values(self:ToTable())
            end
        end)
    end

    function Pair:Unpack()
        return table.unpack(self:ToTable())
    end

    function Pair:ToTable()
        return {self.first, self.second}
    end
end

---@class KeyValuePair
---@field first string
---@field second any
local KeyValuePair = class "KeyValuePair" do
    function KeyValuePair.new(first, second)
        assert(typeof(first) == "string", "key in KeyValuePair must be a string")
        return constructor(KeyValuePair, function(self)
            self.first = first
            self.second = second

            function self.meta.__bnot()
                return values(self:ToTable())
            end
        end)
    end

    function KeyValuePair:Unpack()
        return table.unpack(self:ToTable())
    end

    function KeyValuePair:ToTable()
        return {self.first, self.second}
    end
end


---@class StrictPair<T1, T2>
---@field T1 type
---@field T2 type
---@field first `T1`
---@field second `T2`
local StrictPair = class "StrictPair" do
    ---@param T1 type
    ---@param T2 type
    ---@param first `T1`
    ---@param second `T2`
    function StrictPair.new(T1, T2, first, second)
        assert(typeof(first) == T1, "first value in StrictPair must be of type '" + T1 + "'")
        assert(typeof(second) == T2, "second value in StrictPair must be of type '" + T2 + "'")
        return constructor(StrictPair, function(self)
            self.first = first
            self.second = second

            function self.meta.__bnot()
                return values(self:ToTable())
            end
        end)
    end

    function StrictPair:Unpack()
        return table.unpack(self:ToTable())
    end

    function StrictPair:ToTable()
        return {self.first, self.second}
    end
end

---@class StrictKeyValuePair<V>
---@field V type
---@field first string
---@field second `V`
local StrictKeyValuePair = class "StrictKeyValuePair" do
    function StrictKeyValuePair.new(V, first, second)
        assert(typeof(first) == "string", "key in StrictKeyValuePair must be a string")
        assert(typeof(second) == V, "value in StrictKeyValuePair must be of type '" + V + "'")
        return constructor(StrictKeyValuePair, function(self)
            self.first = first
            self.second = second

            function self.meta.__bnot()
                return values(self:ToTable())
            end
        end)
    end

    function StrictKeyValuePair:Unpack()
        return table.unpack(self:ToTable())
    end

    function StrictKeyValuePair:ToTable()
        return {self.first, self.second}
    end
end

---@class Set
---@field cache table
local Set = class "Set" do
    ---@param base table
    function Set.new(base)
        return constructor(Set, function(self)
            self.cache = base or {}

            function self.meta.__tostring()
                return self:ToString()
            end

            function self.meta.__len()
                return self:Size()
            end

            function self.meta.__bnot()
                return self:Values()
            end

            function self.meta.__band(_, set)
                return self:Union(set)
            end

            function self.meta.__bor(_, set)
                return self:Intersect(set)
            end
        end)
    end

    local function SetAlreadyContains(value)
        throw(Error("Set already contains value '" + tostring(value) + "'"))
    end

    function Set:Unpack()
        return table.unpack(self.cache)
    end

    function Set:Intersect(set)
        local res = Set(self.cache)
        for i in self:Indices() do
            res.cache[i] = set:At(i)
        end
        return res
    end

    function Set:Union(set)
        local res = Set(self.cache)
        for v in ~set do
            res:Add(v)
        end
        return res
    end

    function Set:Slice(start, finish)
        finish = finish or #self
        local res = Set()
        for i = start, finish do
            res:Add(self:At(i))
        end
        return res
    end

    function Set:At(idx)
        return self.cache[idx]
    end

    function Set:Has(value)
        local res = false
        for v in ~self do
            if v == value then
                res = true
            end
        end
        return res
    end

    function Set:Add(value)
        if self:Has(value) then
            SetAlreadyContains(value)
        end
        table.insert(self.cache, value)
    end

    function Set:First()
        return self.cache[1]
    end

    function Set:Last()
        return self.cache[#self.cache]
    end

    function Set:Shift()
        self:Remove(self:First())
    end

    function Set:Pop()
        self:Remove(self:Last())
    end

    function Set:Remove(value)
        local idx = self:IndexOf(value)
        self:RemoveIndex(idx)
    end

    function Set:RemoveIndex(idx)
        table.remove(self.cache, idx)
    end

    function Set:ForEach(callback)
        for i in self:Indices() do
            local v = self.cache[i]
            callback(v, i)
        end
    end

    function Set:IndexOf(value)
        local res
        self:ForEach(function(v, i)
            if v == value then
                res = i
            end
        end)
        return res
    end

    function Set:Indices()
        return pairs(self.cache)
    end

    function Set:Values()
        return values(self.cache)
    end

    function Set:Display()
        repr(self)
    end

    function Set:ToTable()
        return self.cache
    end

    function Set:Size()
        return #self:ToTable()
    end

    function Set:ToString()
        return ("Set( size=%s )"):format(self:Size())
    end

    function Set:__repr()
        repr(self.cache)
    end
end

---@class LinkedNode
---@field value any
---@field next? LinkedNode
local LinkedNode = class "LinkedNode" do
    ---@param value any
    ---@return LinkedNode
    function LinkedNode.new(value)
        return constructor(LinkedNode, function(self)
            self.value = value
            self.next = nil

            function self.meta.__tostring()
                return self:ToString()
            end
        end)
    end

    function LinkedNode:Next()
        return self.next
    end

    function LinkedNode:ToString()
        return ("LinkedNode( value=%s next=%s )"):format(self.value, self.next)
    end
end

---@class LinkedList
---@field root? LinkedNode
local LinkedList = class "LinkedList" do
    ---@return LinkedList
    function LinkedList.new()
        return constructor(LinkedList, function(self)
            self.root = nil

            function self.meta.__len()
                return self:Size()
            end

            function self.meta.__tostring()
                return self:ToString()
            end

            function self.meta.__bnot()
                return self:Nodes()
            end
        end)
    end

    function LinkedList:Remove(value)
        local parent
        for node in ~self do
            if node.value == value then
                if parent == nil then
                    self.root = nil
                else
                    parent.next = nil
                end
            end
            parent = node
        end
    end

    function LinkedList:GetNodes()
        local nodes = Vector("LinkedNode")
        local current = self.root

        while true do
            if current ~= nil then
                nodes:Add(current)
                current = current:Next()
            else
                break
            end
        end

        return nodes
    end

    function LinkedList:Nodes()
        return self:GetNodes():Values()
    end

    function LinkedList:ForEach(callback)
        local nodes = self:GetNodes()
        for node in ~nodes do
            callback(node)
        end
    end

    ---@param value any
    ---@return LinkedList
    function LinkedList:Add(value)
        if self.root == nil then
            self.root = LinkedNode(value, nil)
        else
            local current = self.root
            local node = current
            while true do
                if current then
                    current = current:Next()
                end
                if current == nil then
                    break
                else
                    node = current
                end
            end
            node.next = LinkedNode(value, nil)
        end
        return self
    end

    ---@return LinkedNode
    function LinkedList:Next()
        return self.root
    end

    ---@return integer
    function LinkedList:Size()
        local size = 1
        local current
        while true do
            if self.root == nil then
                break
            else
                current = (current or self.root):Next()
                if current ~= nil then
                    size = size + 1
                else
                    break
                end
            end
        end
        return size
    end

    ---@return string
    function LinkedList:ToString()
        return ("LinkedList( size=%s root=%s )"):format(#self, self.root)
    end

    ---@return void
    function LinkedList:__repr()
        repr(self.root)
    end
end

---@class MultiMap<K, V>: { [K]: V }
---@field cache table
---@field K type
---@field V type
local MultiMap = class "MultiMap" do
    ---@param K type
    ---@param V type
    function MultiMap.new(K, V)
        return constructor(MultiMap, function(self)
            self.cache = {}
            self.K = K
            self.V = V
        end)
    end

    local function TypeEquals(value, expected)
        if typeof(value) == expected then
            return true
        end
        return false
    end

    local function MapTypeError(value, expected)
        throw(Error(("MultiMapTypeError: \n\tgot: %s\n\texpected: %s"):format(typeof(value), expected)), 2)
    end

    local function AssertType(value, expected)
        if not TypeEquals(value, expected) then
            MapTypeError(value, expected)
        end
    end

    function MultiMap:Delete(key)
        AssertType(key, self.K)
        self.cache[key] = nil
        return self
    end

    ---@return Vector
    function MultiMap:Get(key)
        AssertType(key, self.K)
        return self.cache[key]
    end

    function MultiMap:Set(key, ...)
        AssertType(key, self.K)
        if self.cache[key] == nil then
            self.cache[key] = Vector(self.V)
        end

        for v in varargs(...) do
            AssertType(v, self.V)
            self.cache[key]:Add(v)
        end
        return self
    end

    function MultiMap:__repr()
        repr(self.cache)
    end
end

---@class ListTypes
return module "ListTypes" {
    Vector = Vector;
    List = List;
    Stack = Stack;
    Map = Map;
    Queue = Queue;
    Deque = Deque;
    Set = Set;
    LinkedList = LinkedList;
    LinkedNode = LinkedNode;
    MultiMap = MultiMap;
}
