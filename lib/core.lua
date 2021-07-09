function using(t)
    assert(t and type(t) == "table", f"cannot import library of type '{tostring(typeof(t))}'")
    for k, v in pairs(t) do
        _ENV[k] = v
    end
end

function import(module)
    local data = require(module)
    using(data)
    return
end

function singleton(name)
    local body = _ENV[name]
    local lib = body[1]
    local mod = {}
    mod[name] = lib
    return setmetatable(mod, { 
        __newindex = function(self, k, v)
            throw(std.Error("Cannot write to singleton"))
        end;

        __tostring = function()
            return f"<singleton '{name}'>"
        end
    })
end 

function namespace(name)
    return function(body)
        local state = {name = name}

        local meta = { 
            __newindex = function(self, k, v)
                throw(std.Error("Cannot write to namespace"))
            end;

            __tostring = function()
                return ("<namespace '%s'>"):format(state.name);
            end
        }

        _ENV[name] = setmetatable(body, meta)
        return {
            alias = function(_, alias)
                state.name = alias
            end
        }
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

local function classmeta(cls)
    return { __index = cls }
end

function class(name)
    return cast(setmetatable({}, {
        __call = function(self, ...)
            return self.new(...)
        end
    }), name)
end

local function instance(classBody)
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

function throw(err, level)
    assert(type(err) == "table" and err.message ~= nil, "cannot throw error of type '" + typeof(err) + "', ")
    error(err.message, 2 + (level or 0))
end

function enum(name)
    return function(body)
        assert(type(body) == "table", "cannot create enum with body of type '" + type(body) + "'")
        _ENV[name] = table.inverse(body)
    end
end

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

function lambda(content)
    assert(typeof(content) == "string", "lambda function converts a string to a function expression")
    assert(content:Includes("|") and not content:IsBlank(), "malformed lambda")

    local components = content:Trim():Split("|")
    local body = components:At(1):Trim()
    local params = luay.std.List()
    if #components == 2 then
        params = body:Split(",")
        body = components:At(2):Trim()
    end
    
    local luaString = body:Replace("->", "return")
    return luay.util.Function(function(...)
        local env = _ENV
        for i, v in varargs(...) do
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