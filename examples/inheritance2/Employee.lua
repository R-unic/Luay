import "Person"

---@class Employee : Person
Employee = class "Employee" do
    function Employee.new(name)
        Employee:extend(Person.new(name))
        return Employee:constructor(function(self)
            self.name = name
        end)
    end

    function Employee:Work()
        printf "{self.name} is now working."
    end
end

return singleton "Employee"