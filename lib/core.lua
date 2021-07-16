function using(t)
    assert(t and type(t) == "table", f"cannot import library of type '{tostring(typeof(t))}'")
    for k, v in pairs(t) do
        _ENV[k] = v
    end
end

function import(module)
    local data = require(module)
    using(data)
end

---@param name string
---@return table
function singleton(name)
    local body = _ENV[name]
    local lib = body[1]
    local mod = {}
    mod[name] = lib
    return setmetatable(mod, { 
        __newindex = function(self, k, v)
            throw(luay.std.Error("cannot write to singleton"))
        end;

        __tostring = function()
            return ("<singleton '%s'>"):format(name);
        end
    })
end 

--- Creates a namespace
--- and injects it into
--- the global scope. An
--- alias for the namespace
--- is optional using
---@see NamespaceDeclaration
---@param name string
---@return [[(body: table) -> NamespaceDeclaration]]
function namespace(name)
    ---@param body table
    return function(body)
        local state = {name = name}

        ---@meta NamespaceMeta
        local meta = {
            __newindex = function(self, k, v)
                throw(luay.std.Error("cannot write to namespace"))
            end;
            ---@return string
            __tostring = function()
                return ("<namespace '%s'>"):format(state.name);
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
    return { __index = cls }
end

---@param name string
function class(name)
    return cast(setmetatable({}, {
        __call = function(self, ...)
            if not self.new then
                throw(luay.std.Error("cannot instantiate static class"), 1)
            end
            return self.new(...)
        end
    }), name)
end

local function instance(classBody)
    local meta = classmeta(classBody)
    return setmetatable({ meta = meta }, meta)
end

---@param body table
---@param initializer? function
function constructor(body, initializer)
    local self = instance(body)
    ;(initializer or function() end)(self)
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

---@param value unknown
---@param t type
function cast(value, t)
    assert(value ~= nil and type(value) == "table", "value to cast is nil or not a table")
    assert(t ~= nil and type(t) == "string", "must provide a valid type to cast to, got: " + type(t))
    value.__type = t
    return value
end

---@param err Error
---@param level integer
function throw(err, level)
    assert(type(err) == "table" and err.message, "cannot throw error of type '" + typeof(err) + "', ")
    error(colors("%{red}" + err.message), 2 + (level or 0))
end

---@param message string
---@vararg ...
---@return void
function warn(message, ...)
    local args = luay.std.Vector("string", {message, ...})
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

---@param content string
---@return Function
function lambda(content)
    assert(typeof(content) == "string", "lambda function converts a string to a function expression")
    assert(content:Includes("|") and not content:IsBlank(), "malformed lambda")

    local env = _ENV
    local components = content:Trim():Split("|")
    local body = components:At(1):Trim()
    local params = luay.std.List()
    if #components == 2 then
        params = body:Split(",")
        body = components:At(2):Trim()
    end
    
    local luaString = body:Replace("->", "return")
    return luay.util.Function(function(...)
        for i, v in pairs {...} do
            local name = params:At(i)
            if name then
                env[name] = v
            end
        end

        local f, err = load(luaString, "lambda", "t", env)
        if not f then
            throw(luay.std.Error(err))
        else
            return f(...)
        end
    end)
end