---@param condition any
---@param err string
---@param lvl integer
---@return void
_G.assert = function(condition, err, lvl)
    if not condition then
        error(err, 3 + (lvl or 0))
    end
end

--string util
local mtstr = getmetatable("")
---@param a string
---@param b string
---@return string
function mtstr.__add(a, b)
    return a .. b
end

---@param a string
---@param b string
---@return string
function mtstr.__shr(a, b)
    return b .. a
end

---@param a string
---@return function
function mtstr.__bnot(a)
    return a:Chars()
end

---@param a string
---@param b string
---@return string
function mtstr.__mul(a, b)
    return a:rep(b)
end

---@param a string
---@param b string
---@return string
function mtstr.__unm(a, b)
    return a:reverse()
end

---@param a string
---@param b string
---@return Vector
function mtstr.__div(a, b)
    return a:Split(b)
end

local old_mtIndex = mtstr.__index
---@param str string
---@param i integer | table
---@return string
function mtstr.__index(str, i)
    if type(i) == "number" then
        local char = str:sub(i, i)
        return (char and char ~= "") and char or nil
    elseif type(i) == "table" then
        local sub = str:sub(i[1], i[2])
        return sub
    elseif type(old_mtIndex) == "table" then 
        return old_mtIndex[i]
    else if type(old_mtIndex) == nil then
        return old_mtIndex[i]
    end
        return old_mtIndex(str, i)
    end
end

--table util
---@param t table
---@return table
function table.inverse(t)
    assert(type(t) == "table", "cannot inverse table of type '" + typeof(t) + "'")
    local r = {}
    for k, v in pairs(t) do
        r[v] = k
    end
    return r
end

---@param t table
---@return function
function values(t)
    local i = 0
    ---@return any
    return function()
        i = i + 1
        if i <= #t then
            return t[i]
        end
    end
end

---@vararg ...
---@return function
function varargs(...)
    return values {...}
end

colors = require "ansicolors"