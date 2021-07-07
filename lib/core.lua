function using(t)
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
        _ENV[name] = setmetatable(body, { 
            __newindex = function(self, k, v)
                throw(std.Error("Cannot write to namespace"))
            end;

            __tostring = function()
                return ("<namespace '%s'>"):format(name);
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

local function classmeta(cls)
    return { __index = cls }
end

---@param name string
---@return Class
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

function throw(err, fn)
    assert(type(err) == "table" and err.message ~= nil, "cannot throw error of type '" + typeof(err) + "', ")
    error(err.message)
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