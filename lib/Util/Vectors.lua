local Vec2 = class "Vec2" do
    ---@param x? number
    ---@param y? number
    function Vec2.new(x, y)
        return Vec2:constructor(function(self)
            self.x = x or 0
            self.y = y or 0

            function self.meta.__add(vec)
                return Vec2.new(self.x + vec.x, self.y + vec.y)
            end

            function self.meta.__sub(vec)
                return Vec2.new(self.x - vec.x, self.y - vec.y)
            end

            function self.meta.__mul(vec)
                if typeof(vec) == "Vec2" then
                    return Vec2.new(self.x * vec.x, self.y * vec.y)
                elseif typeof(vec) == "number" then
                    return Vec2.new(self.x * vec, self.y * vec)
                else
                    throw(std.Error("Vec2 can only be multiplied by another Vec2 or a number."))
                end
            end

            function self.meta.__div(vec)
                if typeof(vec) == "Vec2" then
                    return Vec2.new(self.x / vec.x, self.y / vec.y)
                elseif typeof(vec) == "number" then
                    return Vec2.new(self.x / vec, self.y / vec)
                else
                    throw(std.Error("Vec2 can only be divided by another Vec2 or a number."))
                end
            end

            function self.meta.__unm()
                return Vec2.new(0 - self.x, 0 - self.y)
            end
        end)
    end

    function Vec2:Magnitude()
        return self.x + self.y
    end

    ---@param b Vec2
    ---@return number
    function Vec2:Dot(b)
        return self:Magnitude() + b:Magnitude()
    end

    ---@param b Vec2
    ---@return number
    function Vec2:Cross(b)
        return (self.x * b.y) - (self.y * b.x)
    end

    ---@param b Vec2
    ---@param t number
    ---@return Vec2
    function Vec2:Lerp(b, t)
        return Vec2.new(util.lerp(self.x, b.x, t), util.lerp(self.y, b.y, t))
    end

    function Vec2:ToString()
        return ("<Vec2: x=%s, y=%s>"):format(self.x, self.y)
    end

    --static
    Vec2.zero = Vec2.new()
    Vec2.one = Vec2.new(1, 1)
end

---@class Vec3 : Class
---@field zero Vec3
---@field one Vec3
---@field x number
---@field y number
---@field z number
local Vec3 = class "Vec3" do
    ---@param x? number
    ---@param y? number
    ---@param z? number
    ---@return Vec3
    function Vec3.new(x, y, z)
        return Vec3:constructor(function(self)
            self.x = x or 0
            self.y = y or 0
            self.z = z or 0

            function self.meta.__add(vec)
                return Vec3.new(self.x + vec.x, self.y + vec.y, self.z + vec.z)
            end

            function self.meta.__sub(vec)
                return Vec3.new(self.x - vec.x, self.y - vec.y, self.z - vec.z)
            end

            function self.meta.__mul(vec)
                if typeof(vec) == "Vec3" then
                    return Vec3.new(self.x * vec.x, self.y * vec.y, self.z * vec.z)
                elseif typeof(vec) == "number" then
                    return Vec3.new(self.x * vec, self.y * vec, self.z * vec)
                else
                    throw(std.Error("Vec3 can only be multiplied by another Vec3 or a number."))
                end
            end

            function self.meta.__div(vec)
                if typeof(vec) == "Vec3" then
                    return Vec3.new(self.x / vec.x, self.y / vec.y, self.z / vec.z)
                elseif typeof(vec) == "number" then
                    return Vec3.new(self.x / vec, self.y / vec, self.z / vec)
                else
                    throw(std.Error("Vec3 can only be divided by another Vec3 or a number."))
                end
            end

            function self.meta.__unm()
                return Vec3.new(0 - self.x, 0 - self.y, 0 - self.z)
            end
        end)
    end

    function Vec3:Magnitude()
        return self.x + self.y + self.z
    end

    ---@param b Vec3
    ---@return number
    function Vec3:Dot(b)
        return self:Magnitude() + b:Magnitude()
    end

    ---@param b Vec3
    ---@return Vec3
    function Vec3:Cross(b)
        return Vec3.new(
            self.y * b.z - self.z * b.y,
            self.z * b.x - self.x * b.z,
            self.x * b.y - self.y * b.x
        )
    end

    ---@param b Vec3
    ---@param t number
    ---@return Vec3
    function Vec3:Lerp(b, t)
        return Vec3.new(util.lerp(self.x, b.x, t), util.lerp(self.y, b.y, t), util.lerp(self.z, b.z, t))
    end

    function Vec3:ToString()
        return ("<Vec3: x=%s, y=%s, z=%s>"):format(self.x, self.y, self.z)
    end

    --static
    Vec3.zero = Vec3.new()
    Vec3.one = Vec3.new(1, 1, 1)
end

---@class VectorsModule
return module "Vectors" {
    Vec2 = Vec2;
    Vec3 = Vec3;
}
