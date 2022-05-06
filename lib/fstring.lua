f = {} do
    local load = load

    local function scanUsing(scanner, arg, searched)
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
        local outer_env = _ENV and (snd(scanUsing(debug.getlocal, 3, "_ENV")) or snd(scanUsing(debug.getupvalue, debug.getinfo(2, "f").func, "_ENV")) or _ENV) or getfenv(2)
        return (str:gsub("%b{}", function(block)
            local code, fmt = block:match("{(.*):(%%.*)}")
            code = code or block:match("{(.*)}")
            local expEnv = {}
            setmetatable(expEnv, { __index = function(_, k)
                local level = 1
                while true do
                    local funcInfo = debug.getinfo(level, "f")
                    if not funcInfo then break end
                    local ok, value = scanUsing(debug.getupvalue, funcInfo.func, k)
                    if ok then return value end
                    ok, value = scanUsing(debug.getlocal, level + 1, k)
                    if ok then return value end
                    level = level + 1
                end
                return rawget(outer_env, k)
            end })
            local fn, err = load("return "..code, "expression `"..code.."`", "t", expEnv)
            if fn then
                return fmt and fmt:format(fn()) or tostring(fn() or "nil")
            else
                throw(std.Error(err))
            end         
        end))
    end

    setmetatable(f, {
        __call = format
    })
end