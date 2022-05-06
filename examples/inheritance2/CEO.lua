import "Employee"

---@class CEO : Employee
CEO = class "CEO" do
    ---@return CEO
    function CEO.new(name)
        CEO:extend(Employee.new(name))
        return CEO:constructor(function(self)
            self.name = name
        end)
    end

    function CEO:Invest(amount)
        printf "{self.name} is now investing ${amount}."
    end
end

return singleton "CEO"