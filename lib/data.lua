_G.assert = function(condition, err, lvl)
    if not condition then
        error(err, 3 + (lvl or 0))
    end
end

--string util
local mtstr = getmetatable("")
function mtstr.__add(a, b)
    return a .. b
end

function mtstr.__shr(a, b)
    return b .. a
end

function mtstr.__bnot(a)
    return a:Chars()
end

function mtstr.__mul(a, b)
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

function values(t)
    local i = 0
    return function()
        i = i + 1
        if i <= #t then
            return t[i]
        end
    end
end

function varargs(...)
    return pairs {...}
end