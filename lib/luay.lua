--string util
local mtstr = getmetatable("")
function mtstr.__add(a, b)
    return a .. b
end

function mtstr.__shl(a, b)
    return a .. b
end

function mtstr.__shr(a, b)
    return b .. a
end

function mtstr.__bnot(a)
    return a:Chars()
end

function mtstr.__pow(a, b)
    return a:rep(b)
end

function mtstr.__unm(a, b)
    return a:reverse()
end

local old_mtIndex = mtstr.__index
function mtstr.__index(str, i)
    if type(i) == "number" then
        local char = str:sub(i, i)
        return (char and char ~= "") and char or nil
    elseif type(i) == "table" then
        local sub = str:sub(i[1], i[2])
        return sub
    elseif type(old_mtIndex) == "table" then 
        return old_mtIndex[i]
    else 
        return old_mtIndex(str, i)
    end
end

--table util
function table.inverse(t)
    assert(type(t) == "table", "cannot inverse table of type '" + type(t) + "'")
    local r = {}
    for k, v in pairs(t) do
        r[v] = k
    end
    return r
end

function isNaN(v)
    return v ~= v
end

function repr(data, level)
    if not level then
        level = 1
    end

    local data_type = type(data)

    if data_type == 'table' then
        if level == nil then
            level = 1
        end

        if data.__repr ~= nil then
            return data:__repr()
        end

        local length = 0
        local has_table = false
        local string_keys = false
        for i, v in pairs(data) do
            if type(v) == 'table' then
                has_table = true
            end
            if type(i) ~= 'number' then
                string_keys = true
            end
            length = length + 1
        end

        io.write('{')

        local iter_func = nil
        if string_keys then
            iter_func = pairs
        else
            iter_func = ipairs
        end

        local h = 1
        for i, v in iter_func(data) do
            if has_table or string_keys then
                io.write('\n  ')
                for j=1, level do
                    if j > 1 then
                        io.write('  ')
                    end
                end
            end
            if string_keys then
                io.write('[')
                repr(i, level + 1)
                io.write('] = ')
            end
            if type(v) == 'table' then
                repr(v, level + 1)
            else
                repr(v, level + 1)
            end
            if h < length then
                io.write(', ')
            end
            h = h + 1
        end
        if has_table or string_keys then
            io.write('\n')
            for j=1, level do
                if j > 1 then
                    io.write('  ')
                end
            end
        end
        io.write('}')
    elseif data_type == 'string' then
        io.write("'")
        for char in data:gmatch('.') do
            local num = string.byte(char)
            if (num >= 0 and num <= 8) or num == 11 or num == 12 or (num >= 14 and num <= 31) or num >= 127 then
                io.write('\\x')
                io.write(('%02X'):format(num))
            elseif num == 92 or num == 39 then
                io.write('\\')
                io.write(char)
            elseif num == 9 then
                io.write('\\t')
            elseif num == 10 then
                io.write('\\n')
            elseif num == 13 then
                io.write('\\r')
            else
                io.write(char)
            end
        end
        io.write("'")
    elseif data_type == 'nil' then
        io.write('nil')
    else
        io.write(tostring(data))
    end

    if level == 1 or data_type == 'table' then
        io.write('\n')
    end

    io.flush()
end

function range(from, to, step)
    step = step or 1
    return function(_, lastvalue)
        local nextvalue = lastvalue + step
        if step > 0 and nextvalue <= to or step < 0 and nextvalue >= to or
            step == 0
        then
            return nextvalue
        end
    end, nil, from - step
end

function using(t)
    for k, v in pairs(t) do
        _ENV[k] = v
    end
end

function import(module)
    using(require(module))
end

function singleton(name)
    local body = _ENV[name]
    local lib = body[1]
    local mod = {}
    mod[name] = lib
    return setmetatable(mod, { 
        __newindex = function(self, k, v)
            throw(std.Error.new("Cannot write to singleton"))
        end;

        __tostring = function()
            return f"<singleton '{name}'>"
        end
    })
end 

function namespace(name)
    return function(body)
        _ENV[name] = setmetatable(body, { 
            __newindex = function(self, k, v)
                throw(std.Error.new("Cannot write to namespace"))
            end;

            __tostring = function()
                return f"<namespace '{name}'>"
            end
        })
    end
end

function extend(self, instance)
    self.__super = instance
    setmetatable(self, {
        __index = function(self, k)
            local v = instance[k]
            if not v then
                local function getV(i)
                    local s = i.__super ~= nil and setmetatable(i.__super, self) or nil
                    if not s then return end

                    local superMeta = setmetatable({}, s.meta)
                    local meta = setmetatable({}, i.meta)
                    return meta[k] or superMeta[k] or getV(s)
                end
                return getV(self)
            else
                return v
            end
        end 
    })
end

function classmeta(meta)
    return { __index = meta }
end

function class(name)
    return cast({}, name)
end

function instance(classBody)
    local meta = classmeta(classBody)
    return setmetatable({ meta = meta }, meta)
end

function constructor(body, initializer)
    local self = instance(body)
    initializer(self)
    return self
end

function defaultConstructor(body)
    return constructor(body, function(self) end)
end

function typeof(v)
    if type(v) == "table" and v.__type then
        return v.__type
    else
        return type(v)
    end
end

function instanceof(v, t)
    return typeof(v) == t
end

function cast(v, t)
    assert(v ~= nil and type(v) == "table", "value to cast is nil or not a table")
    assert(t ~= nil and type(t) == "string", "must provide a valid type to cast to, got: " + type(t))
    v.__type = t
    return v
end

function throw(err, fn)
    assert(type(err) == "table" and err.message ~= nil, "cannot throw error of type '" + typeof(err) + "', ")
    error(err.message)
end

function enum(name)
    return function(body)
        assert(type(body) == "table", "cannot create enum with body of type '" + type(body) + "'")
        _G[name] = table.inverse(body)
    end
end

--[[
    namespace util
]]
do
    local StringBuilder = class "StringBuilder" do
        local AssertString
        function StringBuilder.new(originalContent)
            return constructor(StringBuilder, function(self)
                AssertString(originalContent or "")
                self.content = originalContent or ""

                function self.meta.__tostring()
                    return self:ToString()
                end

                function self.meta.__len()
                    return #self.content
                end
            end)
        end

        function AssertString(str)
            assert(typeof(str) == "string", "cannot append/prepend a non-string value")
        end

        function StringBuilder:Append(str)
            AssertString(str)
            self.content = self.content + str
            return self
        end

        function StringBuilder:AppendLine(str)
            str = str or ""
            return self:Append(str + std.endl)
        end

        function StringBuilder:Prepend(str)
            AssertString(str)
            self.content = str + self.content
            return self
        end

        function StringBuilder:PrependLine(str)
            str = str or ""
            return self:Prepend(str + std.endl)
        end

        function StringBuilder:ToString()
            return self.content
        end
    end

    local HTML = class "HTML" do
        function arrows(str)
            return ("<%s>"):format(str)
        end

        function shortTag(name, attributes)
            assert(typeof(name) == "string", "expected tag name to be string")
            assert(attributes ~= nil and (typeof(attributes) == "Vector" and attributes.type == "string") or true, "expected std.Vector<string> of attributes")
            local tag = StringBuilder.new("<")
                :Append(name)

            if attributes then
                for attr in attributes:Values() do
                    tag:Append(" " + attr)
                end
            end
                
            tag:Append(" />")
            return tostring(tag)
        end

        function htmlTag(name, content, attributes)
            assert(typeof(name) == "string", "expected tag name to be string")
            assert(content ~= nil and typeof(content) == "string" or true, "expected content to be string")
            assert(attributes ~= nil and (typeof(attributes) == "Vector" and attributes.type == "string") or true, "expected std.Vector<string> of attributes")
            local tag = StringBuilder.new(arrows(name))
                :Append(content or "")
                
            if attributes then
                for attr in attributes:Values() do
                    tag:Append(" " + attr)
                end
            end

            tag:Append(arrows("/" + name))
            return tostring(tag)
        end

        function HTML:Html(content, attributes)
            return htmlTag("html", content, attributes)
        end

        function HTML:Head(content, attributes)
            return htmlTag("head", content, attributes)
        end

        function HTML:Header(content, attributes)
            return htmlTag("header", content, attributes)
        end

        function HTML:Body(content, attributes)
            return htmlTag("body", content, attributes)
        end

        function HTML:Link(attributes)
            return shortTag("link", attributes)
        end

        function HTML:FavIconLink(iconPath, attributes)
            return self:Link(std.Vector.new("string", {'rel="icon"', ('href="%s"'):format(iconPath)}):Merge(attributes))
        end

        function HTML:StylesheetLink(cssPath, attributes)
            return self:Link(std.Vector.new("string", {'rel="stylesheet"', ('href="%s"'):format(cssPath)}):Merge(attributes))
        end

        function HTML:P(content, attributes)
            return htmlTag("p", content, attributes)
        end

        function HTML:B(content, attributes)
            return htmlTag("b", content, attributes)
        end

        function HTML:I(content, attributes)
            return htmlTag("i", content, attributes)
        end

        function HTML:Br()
            return arrows "br"
        end

        function HTML:Hr()
            return arrows "hr"
        end

        function HTML:Tab()
            return "&nbsp;"
        end

        function HTML:LArr()
            return "&lt;"
        end

        function HTML:RArr()
            return "&gt;"
        end

        function HTML:Code(content, attributes)
            return htmlTag("code", content, attributes)
        end

        function HTML:Pre(content, attributes)
            return htmlTag("pre", content, attributes)
        end

        function HTML:Title(content, attributes)
            return htmlTag("title", content, attributes)
        end

        function HTML:Table(content, attributes)
            return htmlTag("table", content, attributes)
        end

        function HTML:Ul(content, attributes)
            return htmlTag("ul", content, attributes)
        end

        function HTML:Li(content, attributes)
            return htmlTag("li", content, attributes)
        end
    end

    namespace "util" {
        StringBuilder = StringBuilder;
        HTML = HTML;
    }
end

--[[
    namespace std
]]
do
    function bind(fn, self, ...)
        assert(fn, "fn is nil")
        local bindArgsLength = select("#", ...)
      
        -- Simple binding, just inserts self (or one arg or any kind)
        if bindArgsLength == 0 then
            return function (...)
                return fn(self, ...)
            end
        end
      
        -- More complex binding inserts arbitrary number of args into call.
        local bindArgs = {...}
        return function (...)
            local argsLength = select("#", ...)
            local args = {...}
            local arguments = {}
            for i = 1, bindArgsLength do
                arguments[i] = bindArgs[i]
            end
            for i = 1, argsLength do
                arguments[i + bindArgsLength] = args[i]
            end
            return fn(self, table.unpack(arguments, 1, bindArgsLength + argsLength))
        end
    end

    local String = class "String" do
        function String.new(content)
            return constructor(String, function(self)
                self.content = content
            end)
        end
    
        function String:GetContent()
            return self.content or self
        end

        function String:CapitalizeFirst()
            local first = self[1]
            local rest = self[{2;#self}]
            return first:upper() + rest
        end

        function String:Chars()
            local i = 0
            return function()
                i = i + 1
                if i <= #self then
                    return self[i]
                end
            end
        end

        function String:Split(sep)
            sep = sep or "%s"
            local res = {}
            for str in self:gmatch("([^" + sep + "]+)") do
                table.insert(res, str)
            end
            return std.List.new(res)
        end

        function String:Occurences(sub)
            return select(2, self:gsub(sub, sub))
        end

        function String:Replace(content, replacement)
            local res = self:GetContent():gsub(content, replacement)
            return res
        end

        function String:Includes(sub)
            return self:GetContent():find(sub) and true or false
        end

        function String:IsEmail()
            return self:GetContent():match("[A-Za-z0-9%.%%%+%-%_]+@[A-Za-z0-9%.%%%+%-%_]+%.%w%w%w?%w?") ~= nil
        end

        function String:IsUpper()
            return not self:GetContent():find("%l")
        end

        function String:IsLower()
            return not self:GetContent():find("%u")
        end

        function String:IsBlank()
            return self:GetContent():Occurences("%w") == 0
        end

        function String:IsAlpha()
            return not self:GetContent():find("%A")
        end

        function String:IsNumeric()
            return tonumber(self:GetContent()) and true or false
        end

        function String:Surround(wrap)
            return wrap + self:GetContent() + wrap
        end

        function String:Quote()
            return ("%q"):format(self:GetContent())
        end
    
        function String:CharAt(idx)
            return self:GetContent()[idx]
        end
    end
    
    setmetatable(string, { __index = String })
    
    local Vector = class "Vector" do
        function Vector.new(T, base)
            return constructor(Vector, function(self)
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
            end)
        end
    
        local function TypeEquals(value, expected)
            if typeof(value) == expected then
                return true
            end
            return false
        end
    
        local function VectorTypeError(value, expected)
            throw(std.Error.new(("VectorTypeError: \n\tgot: %s\n\texpected: %s"):format(typeof(value), expected)))
        end

        local function AssertType(self, value)
            if not TypeEquals(value, self.type) then
                VectorTypeError(value, self.type)
            end
        end

        function Vector:Combine(vec)
            assert(
                TypeEquals(vec, "Vector") and vec.type == "string",
                "expected to merge std.Vector<" + self.type + ">"
            )

            for v in vec:Values() do
                self:Add(v)
            end
        end
    
        function Vector:Add(value)
            AssertType(self, value)
            table.insert(self.cache, value)
        end
    
        function Vector:First()
            return self.cache[1]
        end
    
        function Vector:Last()
            return self.cache[#self.cache]
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
    
        function Vector:Indices()
            return pairs(self.cache)
        end
    
        function Vector:Values()
            return std.values(self.cache)
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
    
    local List = class "List" do
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
            end)
        end

        function List:Join(sep)
            local res = ""
            self:ForEach(function(v)
                res = res + tostring(v)
            end)
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
            return std.values(self.cache)
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
    
    local Stack = class "Stack" do
        function Stack.new()
            return constructor(Stack, function(self)
                self.cache = {}

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

        function Stack:Size()
            return #self:ToTable()
        end
    
        function Stack:ToString()
            return ("Stack( size=%s )"):format(self:Size())
        end
    
        function Stack:__repr()
            repr(self.cache)
        end
    end
    
    local Map = class "Map" do
        function Map.new(K, V)
            assert(K and typeof(K) == "string", "Map must have key type")
            assert(V and typeof(V) == "string", "Map must have value type")
            return constructor(Map, function(self)
                self.cache = {}
                self.K = K
                self.V = V

                function self.meta.__tostring()
                    return self:ToString()
                end

                function self.meta.__len()
                    return self:Size()
                end

                function self.meta.__bnot()
                    return self:Keys()
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
            throw(std.Error.new(("MapTypeError: \n\tgot: %s\n\texpected: %s"):format(type(value), expected)))
        end
        
        local function AssertType(value, expected)
            if not TypeEquals(value, expected) then
                MapTypeError(value, expected)
            end
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
            return std.values(self.cache)
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

    local Queue = class "Queue" do
        function Queue.new()
            return constructor(Queue, function(self)
                self.cache = {}

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

        function Queue:Add(value)
            table.insert(self.cache, value)
        end
    
        function Queue:Remove()
            table.remove(self.cache, #self.cache)
        end

        function Queue:Indices()
            return pairs(self.cache)
        end
    
        function Queue:Values()
            return std.values(self.cache)
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

    local Deque = class "Deque" do
        function Deque.new()
            extend(Deque, Queue.new())
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

        function Deque:AddFirst(value)
            table.insert(self.cache, 1, value)
        end

        function Deque:RemoveFirst()
            table.remove(self.cache, 1)
        end

        function Deque:AddLast(value)
            self:Add(value)
        end

        function Deque:RemoveLast()
            self:Remove()
        end

        function Deque:Indices()
            return pairs(self.cache)
        end
    
        function Deque:Values()
            return std.values(self.cache)
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

    local Pair = class "Pair" do
        function Pair.new(first, second)
            return constructor(Pair, function(self)
                self.first = first
                self.second = second

                function self.meta.__bnot()
                    return std.values {self.first, self.second}
                end
            end)
        end
    end

    local KeyValuePair = class "KeyValuePair" do
        function KeyValuePair.new(first, second)
            assert(typeof(first) == "string", "key in KeyValuePair must be a string")
            return constructor(KeyValuePair, function(self)
                self.first = first
                self.second = second

                function self.meta.__bnot()
                    return std.values {self.first, self.second}
                end
            end)
        end
    end

    local StrictPair = class "StrictPair" do
        function StrictPair.new(T1, T2, first, second)
            assert(typeof(first) == T1, "first value in StrictPair must be of type '" + T1 + "'")
            assert(typeof(second) == T2, "second value in StrictPair must be of type '" + T2 + "'")
            return constructor(StrictPair, function(self)
                self.first = first
                self.second = second

                function self.meta.__bnot()
                    return std.values {self.first, self.second}
                end
            end)
        end
    end

    local StrictKeyValuePair = class "StrictKeyValuePair" do
        function StrictKeyValuePair.new(V, first, second)
            assert(typeof(first) == "string", "key in StrictKeyValuePair must be a string")
            assert(typeof(second) == V, "value in StrictKeyValuePair must be of type '" + V + "'")
            return constructor(StrictKeyValuePair, function(self)
                self.first = first
                self.second = second

                function self.meta.__bnot()
                    return std.values {self.first, self.second}
                end
            end)
        end
    end

    local Set = class "Set" do
        function Set.new()
            return constructor(Set, function(self)
                self.cache = {}

                function self.meta.__bnot()
                    return self:Values()
                end
            end)
        end

        local function SetAlreadyContains(value)
            throw(std.Error.new("Set already contains value '" + tostring(value) + "'"))
        end

        function Set:Has(value)
            local res = false
            self:ForEach(function(v, i)
                if v == value then
                    res = true
                end
            end)
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
            return std.values(self.cache)
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
    
    local EventEmitter = class "EventEmitter" do
        function EventEmitter.new()
            return constructor(EventEmitter, function(self)
                self.listeners = Map.new("string", "Vector")
            end)
        end

        function EventEmitter:ListenerCount(event)
            local callbacks = self.listeners:Get(event)
            return #callbacks
        end
    
        function EventEmitter:AddListener(event, callback)
            local callbacks = self.listeners:Get(event)
            if not callbacks then
                self.listeners:Set(event, Vector.new("function"))
                return self:AddListener(event, callback)
            end
    
            callbacks:Add(callback)
            return self
        end
    
        function EventEmitter:RemoveListener(event, callback)
            local callbacks = self.listeners:Get(event)
            if not callbacks then
                return self.listeners:Set(event, Vector.new("function"))
            end
    
            callbacks:Remove(callback)
            return self
        end
    
        function EventEmitter:Emit(event, ...)
            local callbacks = self.listeners:Get(event)
            for callback in callbacks:Values() do
                callback(...)
            end

            return self
        end
    
        function EventEmitter:On(event, callback)
            return self:AddListener(event, callback)
        end
    
        function EventEmitter:Once(event, callback)
            local call 
            call = function(...)
                callback(...)
                self:Off(event, call)
            end
    
            return self:On(event, call)
        end
    
        function EventEmitter:Off(event, callback)
            return self:RemoveListener(event, callback)
        end
    end
    
    local Error = class "Error" do
        function Error.new(message)
            return constructor(Error, function(self)
                self.message = message or "std.Error thrown!"
            end)
        end
    end

    local Input = class "Input" do
        function Input.new()
            return constructor(Input, function(self)
                function self.meta.__shr(_, prompt)
                    io.write(prompt)
                    io.flush()
                    return io.read()
                end
            end)
        end
    end

    local Output = class "Output" do
        function Output.new()
            return constructor(Output, function(self)
                function self.meta.__shl(output, content)
                    io.write(content)
                    return content
                end
            end)
        end
    end
    
    do
        extend(Process, EventEmitter.new())
        function Process:Exit(code)
            self:Emit("exit", code or 1)
            throw(Error.new(""))
        end
    end

    do
        local StreamBase = class "StreamBase" do
            function StreamBase.new()
                extend(StreamBase, EventEmitter.new())
                return defaultConstructor(StreamBase)
            end
    
            function StreamBase:Pipe(dest, opts)
                local onData, onDrain, onEnd, onClose, onError, cleanup
    
                function onData(chunk)
                    if dest.writable then
                        if dest:Write() and self.Pause then
                            self:Pause()
                        end
                    end
                end
    
                function onDrain()
                    if self.readable and self.Resume then
                        self:Resume()
                    end
                end
    
                self:On("data", onData)
                dest:On("drain", onDrain)
    
                local didOnEnd = false
                function onEnd()
                    if didOnEnd then return end
                    didOnEnd = true
                    dest:End()
                end
    
                function onClose()
                    if didOnEnd then return end
                    didOnEnd = true
    
                    if typeof(dest.Destroy) == "function" then
                        dest:Destroy()
                    end
                end
    
                if not dest.isStdIO and (not opts or opts._end ~= false) then
                    self:On("end", onEnd)
                    self:On("close", onClose)
                end
    
                function onError(err)
                    cleanup()
                    if self:ListenerCount("error") == 0 then
                        throw(err)
                    end
                end
    
                self:On("error", onError)
                dest:On("error", onError)
    
                function cleanup()
                    self:Off("data", onData)
                    dest:Off("drain", onDrain)
    
                    self:Off("end", onEnd)
                    self:Off("close", onClose)
    
                    self:Off("error", onError)
                    dest:Off("error", onError)
    
                    self:Off("end", cleanup)
                    self:Off("close", cleanup)
                    dest:Off("close", cleanup)
                end
    
                self:On("end", cleanup)
                self:On("close", cleanup)
                dest:On("close", cleanup)
                dest:Emit("pipe", self)
    
                return dest
            end
        end

        local ReadableState = class "ReadableState" do
            function ReadableState.new(opts, stream)
                return constructor(ReadableState, function(self)
                    opts = opts or {}
                    
                    local hwm = opts.highWaterMark
                    local defaultHwm = 16
                    if not opts.objectMode then
                        defaultHwm = 16 * 1024
                    end

                    self.highWaterMark = hwm or defaultHwm
                    self.buffer = {}
                    self.length = 0
                    self.pipes = nil
                    self.pipesCount = 0
                    self.flowing = nil
                    self.ended = false
                    self.endEmitted = false
                    self.reading = false
                    self.sync = true
                    self.needReadable = false
                    self.emittedReadable = false
                    self.readableListening = false
                    self.objectMode = not not opts.readableObjectMode
                    if instanceof(stream, "Duplex") then
                        self.objectMode = self.objectMode or (not not opts.readableObjectMode)
                    end

                    self.ranOut = false
                    self.awaitDrain = 0
                    self.readingMore = false
                end)
            end    
        end

        local Readable = class "Readable" do
            function Readable.new(opts)
                return constructor(Readable, function(self)
                    extend(Readable, StreamBase.new())
                    self.readableState = ReadableState.new(opts, self)
                end)
            end

            local len, readableAddChunk, chunkInvalid, onEofChunk, emitReadable,
                maybeReadMore, needMoreData, roundUpToNextPowerOf2, howMuchToRead,
                endReadable, fromList, emitReadable_, flow, maybeReadMore_, resume,
                resume_, pipeOnDrain

            function Readable:Push(chunk)
                return readableAddChunk(self, self.readableState, chunk, false)
            end

            function Readable:Unshift(chunk)
                return readableAddChunk(self, self.readableState, chunk, "", true)
            end

            function Readable:Read(n)
                local state = self.readableState
                local nOrig = n

                if typeof(n) ~= "number" or n > 0 then
                    state.emittedReadable = false
                end

                if 
                    n == 0 and 
                    state.needReadable and 
                    (state.length >= state.highWaterMark or state.ended) 
                then
                    if state.length == 0 and state.ended then
                        endReadable(self)
                    else
                        emitReadable(self)
                    end
                    return nil
                end

                n = howMuchToRead(n, state)

                if n == 0 and state.ended then
                    if state.length == 0 then
                        endReadable(self)
                    end
                    return nil
                end

                local doRead = state.needReadable
                if state.length == 0 or state.length - n < state.highWaterMark then
                    doRead = true
                end

                if state.ended or state.reading then
                    doRead = false
                end

                if doRead then
                    state.reading = true
                    state.sync = true

                    if state.length == 0 then
                        state.needReadable = true
                    end

                    self:_Read(state.highWaterMark)
                    state.sync = false
                end

                if doRead and not state.reading then
                    n = howMuchToRead(nOrig, state)
                end

                local ret
                if n > 0 then
                    ret = fromList(n, state)
                end

                if ret == nil then
                    state.needReadable = true
                    n = 0
                end

                state.length = state.length - n
                if state.length == 0 and not state.ended then
                    state.needReadable = true
                end

                if
                    nOrig ~= n and
                    state.ended and
                    state.length == 0
                then
                    endReadable(self)
                end

                if ret ~= nil then
                    self:Emit("data", ret)
                end

                return ret
            end

            --abstract method, meant to be overridden
            function Readable:_Read(n)
                self:Emit("error", Error.new("not implemented"))
            end

            function Readable:Pipe(dest, pipeOpts)
                local state = self.readableState

                local onUnpipe, onEnd, cleanup, onData, onError, onClose, onFinish, onDrain, unpipe
                local endFn

                function onUnpipe(readable)
                    if self == readable then
                        cleanup()
                    end
                end

                function onEnd()
                    dest:End()
                end

                function cleanup()
                    dest:Off("close", onClose)
                    dest:Off("finish", onFinish)
                    dest:Off("drain", onDrain)
                    dest:Off("error", onError)
                    dest:Off("unpipe", onUnpipe)
                    
                    self:Off("end", onEnd)
                    self:Off("end", cleanup)
                    self:Off("data", onData)

                    if
                        state.awaitDrain and
                        (not dest.writableStream or dest.writableStream.needDrain)
                    then
                        onDrain()
                    end
                end

                function onData(chunk)
                    local ret = dest:Write(chunk)
                    if ret == false then
                        self.readableState.awaitDrain = self.readableState.awaitDrain + 1
                        self:Pause()
                    end
                end

                function onError(err)
                    unpipe()
                    dest:Off("error", onError)
                    if dest:ListenerCount("error") == 0 then
                        dest:Emit("error", err)
                    end
                end

                function onClose()
                    dest:Off("finish", onFinish)
                    unpipe()
                end

                function onFinish()
                    dest:Off("close", onClose)
                    unpipe()
                end

                function unpipe()
                    self:Unpipe(dest)
                end

                if state.pipesCount == 0 then
                    state.pipes = dest
                elseif state.pipesCount == 1 then
                    state.pipes = {state.pipes, dest}
                else
                    table.insert(state.pipes, dest)
                end
                state.pipesCount = state.pipesCount + 1

                local doEnd = (not pipeOpts or pipeOpts._end ~= false) and
                    dest ~= Process.stdout and
                    dest ~= Process.stderr

                if doEnd then
                    endFn = onEnd
                else
                    endFn = cleanup
                end

                if state.endEmitted then
                    coroutine.wrap(endFn)()
                else
                    self:Once("end", endFn)
                end

                dest:On("unpipe", onUnpipe)

                onDrain = pipeOnDrain(self)
                dest:On("drain", onDrain)
                self:On("data", onData)
                dest:Once("close", onClose)
                dest:Once("finish", onFinish)

                dest:Emit("pipe", self)
                if not state.flowing then
                    self:Resume()
                end

                return dest
            end

            function Readable:Unpipe(dest)
                local state = self.readableState
                if state.pipesCount == 0 then
                    return self
                end

                if state.pipesCount == 1 then
                    if dest and dest ~= state.pipes then
                        return self
                    end

                    if not dest then
                        dest = state.pipes
                    end

                    state.pipes = nil
                    state.pipesCount = 0
                    state.flowing = false
                    if dest then
                        dest:Emit("unpipe", self)
                    end

                    return self
                end

                if not dest then
                    local dests = state.pipes
                    local len = state.pipesCount
                    state.pipes = nil
                    state.pipesCount = 0
                    state.flowing = false

                    for i in range(1, len, 1) do
                        dests[i]:Emit("unpipe", self)
                    end

                    return self
                end

                local i
                for j, pipe in ipairs(state.pipes) do
                    if pipe == dest then
                        i = j
                    end
                end

                if i == nil then
                    return self
                end

                table.remove(state.pipes, i)
                state.pipesCount = state.pipesCount - 1
                if state.pipesCount == 1 then
                    state.pipes = state.pipes[1]
                end

                dest:Emit("unpipe", self)
                return self
            end

            function Readable:On(event, callback)
                local res = StreamBase.On(self, event, callback)

                if event == "data" and self.readableState.flowing then
                    self:Resume()
                end

                if event == "readable" and self.readable then
                    local state = self.readableState
                    if not state.readableListening then
                        state.readableListening = true
                        state.emittedReadable = false
                        state.needReadable = true
                        if not state.reading then
                            local _self = self
                            coroutine.wrap(function()
                                _self:Read(0)
                            end)()
                        elseif state.length then
                            emitReadable(self, state)
                        end
                    end
                end

                return res
            end

            Readable.AddListener = Readable.On

            function Readable:Resume()
                local state = self.readableState
                if not state.flowing then
                    state.flowing = true
                    if not state.reading then
                        self:Read(0)
                    end
                    resume(self, state)
                end
                return self
            end

            function Readable:Pause()
                if self.readableState.flowing ~= false then
                    self.readableState.flowing = false
                    self:Emit("pause")
                end
                return self
            end

            function Readable:Wrap(stream)
                local state = stream.readableState
                local paused = false

                stream:On("end", function()
                    self:Emit("end")
                    self:Push(nil)
                end)

                stream:On("data", function(chunk)
                    if chunk == nil or not state.objectMode and len(chunk) == 0 then
                        return
                    end

                    local ret = self:Push(chunk)
                    if not ret then
                        paused = true
                        stream:Pause()
                    end
                end)

                for i in pairs(stream) do
                    if typeof(stream[i]) == "function" and self[i] == nil then
                        self[i] = stream[i]
                    end
                end

                local events = {"error", "close", "destroy", "resume", "pause"}
                for v in std.values(events) do
                    stream:On(v, bind(self.Emit, self, v))
                end

                self._Read = function()
                    if paused then
                        paused = false
                        stream:Resume()
                    end
                end

                return self
            end

            function fromList(n, state)
                local list = state.buffer
                local length = state.length
                local objectMode = not not state.objectMode
                local ret

                if len(list) == 0 then
                    return nil
                end
            
                if length == 0 then
                    ret = nil
                elseif objectMode then
                    ret = table.remove(list, 1)
                elseif not n or n >= length then
                    ret = table.concat(list, "")
                    state.buffer = {}
                else
                    if n < len(list[1]) then
                        local buf = list[1]
                        ret = buf[{1;n}]
                        list[1] = buf[{n+1;-1}]
                    elseif n == len(list[1]) then
                        ret = table.remove(list, 1)
                    else
                        local tmp = {}
                        local c = 0
                        for i in range(1, len(list), 1) do
                            if n - c >= len(list[1]) then
                                c = c + list[1]
                                table.insert(tmp, table.remove(list, 1))
                            else
                                c = n
                                table.insert(tmp, list[1][{1;n-c}])
                                list[1] = list[1][{n+1;-1}]
                                break
                            end
                        end
                        ret = table.concat(tmp)
                    end
                end
                return ret
            end

            function endReadable(stream)
                local state = stream.readableState
                if state.length == 0 then
                    throw(Error.new("endReadable() called on non-empty stream"))
                end

                if not state.endEmitted then
                    state.ended = true
                    coroutine.wrap(function()
                        if not state.endEmitted and state.length == 0 then
                            state.endEmitted = true
                            stream.readable = false
                            stream:Emit("end")
                        end
                    end)
                end
            end

            function flow(stream)
                local state = stream.readableState
                if state.flowing then
                    local chunk = stream:Read()
                    while chunk ~= nil and state.flowing do
                        chunk = stream:Read()
                    end
                end
            end

            function resume_(stream, state)
                state.resumeScheduled = false
                stream:Emit("resume")
                flow(stream)
                if state.flowing and not state.reading then
                    stream:Read(0)
                end
            end

            function resume(stream, state)
                if not state.resumeScheduled then
                    state.resumeScheduled = true
                    coroutine.wrap(resume_)(stream, state)
                end
            end

            function pipeOnDrain(src)
                return function()
                    local state = src.readableState
                    if state.awaitDrain ~= 0 then
                        state.awaitDrain = state.awaitDrain - 1
                    end

                    if state.awaitDrain == 0 and src:ListenerCount("data") ~= 0 then
                        state.flowing = true
                        flow(src)
                    end
                end
            end

            function maybeReadMore_(stream, state)
                local len = state.length
                while 
                    not state.reading and 
                    not state.flowing and 
                    not state.ended and 
                    state.length < state.highWaterMark 
                do
                    stream:Read(0)
                    if len == state.length then
                        break
                    else
                        len = state.length
                    end
                end
                state.readingMore = false
            end

            function maybeReadMore(stream, state)
                if not state.readingMore then
                    state.readingMore = true
                    coroutine.wrap(function()
                        maybeReadMore_(stream, state)
                    end)()
                end
            end

            function emitReadable_(stream)
                stream:Emit("readable")
                flow(stream)
            end

            function emitReadable(stream)
                local state = stream.readableState
                state.needReadable = false

                if not state.emittedReadable then
                    coroutine.wrap(function()
                        emitReadable_(stream)
                    end)()
                else
                    emitReadable_(stream)
                end
            end

            function onEofChunk(stream, state)
                state.ended = true
                emitReadable(stream)
            end

            function chunkInvalid(state, chunk)
                local err
                if typeof(chunk) ~= "string" and chunk and not state.objectMode then
                    err = Error.new("Invalid non-string/buffer chunk")
                end
                return err
            end

            function readableAddChunk(stream, state, chunk, addToFront)
                local err = chunkInvalid(state, chunk)
                if err then
                    stream:Emit("error", err)
                elseif chunk == nil then
                    state.reading = false
                    if not state.ended then
                        onEofChunk(stream, state)
                    end
                elseif state.objectMode or chunk or len(chunk) > 0 then
                    if state.ended and not addToFront then
                        local e = Error.new("stream:Push() after EOF")
                        stream:Emit("error", e)
                    else
                        if not addToFront then
                            state.reading = false
                        end

                        if state.flowing and state.length == 0 and not state.sync then
                            stream:Emit("data", chunk)
                            stream:Read(0)
                        else
                            if state.objectMode then
                                state.length = state.length + 1
                            else
                                state.length = state.length + len(chunk)
                            end

                            if addToFront then
                                table.insert(state.buffer, 1, chunk)
                            else
                                table.insert(state.buffer, chunk)
                            end

                            if state.needReadable then
                                emitReadable(stream)
                            end
                        end
                        maybeReadMore(stream, state)
                    end
                elseif not addToFront then
                    state.reading = false
                end

                return needMoreData(state)
            end

            function needMoreData(state)
                return not state.ended and (
                    state.needReadable or 
                    state.length < state.highWaterMark or
                    state.length == 0
                )
            end

            local MAX_HWM = 0x800000
            function roundUpToNextPowerOf2(n)
                if n >= MAX_HWM then
                    n = MAX_HWM
                else
                    n = n - 1
                    local p = 1
                    while p < 32 do
                        n = n | n >> p
                        p = p << 1
                    end
                    n = n + 1
                end
                return n
            end

            function howMuchToRead(n, state)
                if state.length == 0 and state.ended then
                    return 0
                end

                if state.objectMode then
                    if n == 0 then
                        return 0
                    else
                        return 1
                    end
                end

                if isNaN(n) or not n then
                    if state.flowing and len(state.buffer) > 0 then
                        return len(state.buffer[1])
                    else
                        return state.length
                    end
                end

                if n <= 0 then
                    return 0
                end

                if n > state.highWaterMark then
                    state.highWaterMark = roundUpToNextPowerOf2(n)
                end

                if n > state.length then
                    if not state.ended then
                        state.needReadable = true
                        return 0
                    else
                        return state.length
                    end
                end

                return n
            end

            function len(buf)
                if typeof(buf) == "string" then
                    return buf:len()
                elseif typeof(buf) == "table" then
                    return #buf
                else
                    return -1
                end
            end
        end

        namespace "Stream" {
            Stream = StreamBase;
            ReadableState = ReadableState;
            Readable = Readable;
        }
    end
    
    namespace "std" {
        String = String;
        EventEmitter = EventEmitter;
        Error = Error;
        Vector = Vector;
        List = List;
        Stack = Stack;
        Map = Map;
        Queue = Queue;
        Deque = Deque;

        Stream = Stream;
    
        repr = repr;
    
        stdout = Output.new();
        stdin = Input.new();
        endl = "\n";
    
        values = function(t)
            local i = 0
            return function()
                i = i + 1
                if i <= #t then
                    return t[i]
                end
            end
        end;
        
        printf = function(str, ...)
            print(str:format(...))
        end;
    
        getfenv = function(fn)
            local i = 1
            while true do
                local name, val = debug.getupvalue(fn, i)
                if name == "_ENV" then
                return val
                elseif not name then
                break
                end
                i = i + 1
            end
        end;

        setfenv = function(fn, env)
            local i = 1
            while true do
                local name = debug.getupvalue(fn, i)
                if name == "_ENV" then
                    debug.upvaluejoin(fn, i, (function()
                        return env
                    end), 1)
                    break
                elseif not name then
                    break
                end
                i = i + 1
            end
            return fn
        end;
    }

    _ENV.Stream = nil
end

f = {} do
    local load = load

    local function scan_using(scanner, arg, searched)
    local i = 1
    repeat
        local name, value = scanner(arg, i)
        if name == searched then
            return true, value
        end
        i = i + 1
    until name == nil
    return false
    end

    local function snd(_, b) return b end

    local function format(_, str)
    local outer_env = _ENV and (snd(scan_using(debug.getlocal, 3, "_ENV")) or snd(scan_using(debug.getupvalue, debug.getinfo(2, "f").func, "_ENV")) or _ENV) or std.getfenv(2)
    return (str:gsub("%b{}", function(block)
        local code, fmt = block:match("{(.*):(%%.*)}")
        code = code or block:match("{(.*)}")
        local exp_env = {}
        setmetatable(exp_env, { __index = function(_, k)
            local level = 6
            while true do
                local funcInfo = debug.getinfo(level, "f")
                if not funcInfo then break end
                local ok, value = scan_using(debug.getupvalue, funcInfo.func, k)
                if ok then return value end
                ok, value = scan_using(debug.getlocal, level + 1, k)
                if ok then return value end
                level = level + 1
            end
            return rawget(outer_env, k)
        end })
        local fn, err = load("return "+code, "expression `"+code+"`", "t", exp_env)
        if fn then
            return fmt and string.format(fmt, fn()) or tostring(fn() or "")
        else
            error(err, 0)
        end         
    end))
    end

    setmetatable(f, {
        __call = format
    })
end