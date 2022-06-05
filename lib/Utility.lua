local VecModule = require "Util.Vectors"
local StringUtils = require "Util.StringUtils"

---@class util
---@field StringBuilder StringBuilder
---@field HTML HTML
---@field Vec2 Vec2
---@field Vec3 Vec3
---@field assertType fun(t: type, eMsg: string, ...: any): void
---@field lerp fun(a: number, b: number, t: number): number
util = {}
namespace "util" {
    StringBuilder = StringUtils.StringBuilder;
    HTML = StringUtils.HTML;
    Vec2 = VecModule.Vec2;
    Vec3 = VecModule.Vec3;

    assertType = function(t, eMsg, ...)
        assert(typeof(eMsg) == "string", "Error message must be a string.")
        for v in list {...} do
            assert(typeof(v) == t, f(eMsg))
        end
    end;
    lerp = function(a, b, t)
        return a + (b - a) * t
    end
}