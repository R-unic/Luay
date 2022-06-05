---@diagnostic disable-next-line: duplicate-doc-alias
---@alias void nil

Inf = math.huge

---@param t table
---@param element unknown
---@return number
local function indexOf(t, element)
    local res
    for i, v in pairs(t) do
        if v == element then
            res = i
            break
        end
    end
    return res
end

---@param t table
---@param sep string
---@return string
local function join(t, sep)
    local res = ""
    for v in list(t) do
        res = res + v
        if indexOf(t, v) ~= #t then
            res = res + sep
        end
    end
    return res
end

---@vararg string
function printf(...)
    local strs = {...}
    print(f(join(strs, "\t")))
end

---@return number
function tick()
    return os.time(os.date("*t"))
end

---@param n number
---@return boolean
function isFinite(n)
    return n ~= Inf
end

---@param v any
---@return boolean
function isNaN(v)
    return v ~= v
end

---@return void
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
            if i ~= "meta" then
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
                h = h + 1
            end
        end
        if has_table or string_keys then
            io.write('\n')
            for j=1, level do
                if j > 1 then
                    io.write('  ')
                end
            end
        end
        io.write('}\n')
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
        io.write((not tostring(data) or tostring(data) == "") and "nil" or tostring(data))
    end

    io.flush()
end

---@param from number
---@param to number
---@param step number
---@return function
---@return nil
---@return number
function range(from, to, step)
    step = step or 1
    ---@return number
    return function(_, lastvalue)
        local nextvalue = lastvalue + step
        if 
            step > 0 and 
            nextvalue <= to or 
            step < 0 and 
            nextvalue >= to or
            step == 0
        then
            return nextvalue
        end
    end, nil, from - step
end

---@param fn Function
---@param self table
---@param ... any
---@return Function
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

---@param t table
function using(t)
    assert(t and type(t) == "table", f"cannot import library of type '{tostring(typeof(t))}'")
    for k, v in pairs(t) do
        _ENV[k] = v
    end
end

---@param module string
function import(module)
    local data = require(module)
    using(data)
end

---@param name string
---@return table
function singleton(name)
    local body = _ENV[name]
    local mod = {}
    mod[name] = body
    return setmetatable(mod, { 
        __newindex = function(self, k, v)
            throw(std.Error("cannot write to singleton"))
        end;

        __tostring = function()
            return ("<singleton \"%s\">"):format(name);
        end
    })
end 

--- Only for looks, equivalent to 
--- just returning a string indexed 
--- table. Usage: 
--- ```return module "Animals" {
---     Dog = Dog;
---     Cat = Cat;
--- }```
---
---@param name string
---@return fun(body: table): { Name: string }
function module(name)
    ---@param body table
    ---@return { Name: string }
    return function(body)
        return setmetatable(body, {
            Name = name;
            __tostring = function(self)
                return ("<module \"%s\""):format(self.Name)
            end;
        })
    end 
end 

--- Creates a namespace
--- and injects it into
--- the global scope. An
--- alias for the namespace
--- is optional using
---@see NamespaceDeclaration
---@param name string
---@return function
function namespace(name)
    ---@param body table
    return function(body)
        local state = {name = name}
        local meta = {
            __newindex = function(self, k, v)
                throw(std.Error("cannot write to namespace"))
            end;
            ---@return string
            __tostring = function()
                return ("<namespace \"%s\">"):format(state.name);
            end
        }

        
        local namespaceBody = setmetatable(body, meta)
        _ENV[name] = namespaceBody
        ---@class NamespaceDeclaration
        return {
            --- Sets an alias for the
            --- namespace when tostring
            --- is called on it.
            ---@param self NamespaceDeclaration
            ---@param alias string
            alias = function(self, alias)
                state.name = alias
            end
        }
    end
end

---@param self table
---@param instance table
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

local function classmeta(cls)
    return { 
        __index = cls;
        __tostring = function(self)
            if self.ToString then
                return self:ToString()
            else
                return "<AnonClass>"
            end
        end
    }
end

---@param name string
function class(name)
    return cast(setmetatable({}, {
        __call = function(self, ...)
            if not self.new then
                throw(std.Error("cannot instantiate static class"), 1)
            end
            return self.new(...)
        end;
    }), name)
end

---@return ClassInstance
local function instance(classBody)
    local meta = classmeta(classBody)
    ---@class ClassInstance
    ---@field meta table
    return setmetatable({ meta = meta }, meta)
end

---@param body table
function constructor(body, initializer)
    local self = instance(body)
    ;(initializer or function(_) end)(self)
    self.meta.__metatable = {}
    return self
end

---@deprecated since 7/9/21
---@param body table
function defaultConstructor(body)
    return constructor(body, function(self) end)
end

---@param value any
function typeof(value)
    if type(value) == "table" and value.__type then
        return value.__type
    else
        return type(value)
    end
end

---@param value any
---@param t type
function instanceof(value, t)
    return typeof(value) == t
end

---@class Class
local _ = {
    extend = extend;
    constructor = constructor;
}

---@param value unknown
---@param t type
---@return Class | any
function cast(value, t)
    assert(value ~= nil and type(value) == "table", "value to cast is nil or not a table")
    assert(t ~= nil and type(t) == "string", "must provide a valid type to cast to, got: " + type(t))
    value.__type = t
    if (
        t ~= "nil" and
        t ~= "number" and
        t ~= "string" and
        t ~= "boolean" and
        t ~= "table" and
        t ~= "function" and
        t ~= "thread" and
        t ~= "userdata"
    ) then
        value.extend = extend
        value.constructor = constructor
    end
    return value
end

---@param err Error
---@param level? integer
function throw(err, level)
    assert(type(err) == "table" and err.message, "cannot throw error of type '" + typeof(err) + "', ")
    error(colors("%{red}" + err.message), 2 + (level or 0))
end

---@param message string
---@vararg ...
---@return void
function warn(message, ...)
    local args = std.Vector("string", {message, ...})
    print(args:Map(lambda "|m| -> colors('%{yellow}' + m)"):Join("\t"))
end

---@param name string
function enum(name)
    return function(body)
        assert(type(body) == "table", "cannot create enum with body of type '" + type(body) + "'")
        _ENV[name] = table.inverse(body)
    end
end

---@param fn function
function getfenv(fn)
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
end

---@param fn function
---@param env table
function setfenv(fn, env)
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
end

---@param collection table
function list(collection)
    local index = 0
    local count = #collection
          
    return function()
       index = index + 1
       if index <= count then
          return collection[index]
       end
    end
 end

---@param content String
---@return Function
function lambda(content)
    assert(typeof(content) == "string", "lambda function converts a string to a function expression")
    assert(content:Includes("|") and not content:IsBlank(), "malformed lambda")

    local env = _ENV
    local components = content:Trim():Split("|")
    local body = components:At(1):Trim()
    local params = std.List()
    if #components == 2 then
        params = body:Split(",")
        body = components:At(2):Trim()
    end
    
    local luaString = body:Replace("->", "return")
    return std.Function(function(...)
        for i, v in pairs {...} do
            local name = params:At(i)
            if name then
                env[name] = v
            end
        end

        local f, err = load(luaString, "lambda", "t", env)
        if not f then
            throw(std.Error(err))
        else
            return f(...)
        end
    end)
end

---@class Error : Class
---@field message string
Error = class "Error" do
    ---@param message string
    function Error.new(message)
        return Error:constructor(function(self)
            self.message = message or "std::Error thrown!"
        end)
    end
end