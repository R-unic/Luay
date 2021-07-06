import "Employee"

CEO = class "CEO" do
    function CEO.new(name)
        extend(CEO, Employee.new(name))
        return constructor(CEO, function(self)
            self.name = name
        end)
    end

    function CEO:Invest(amount)
        print(f"{self.name} is now investing ${amount}.")
    end
end

return singleton "CEO"