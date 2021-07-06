import "Person"

Employee = class "Employee" do
    function Employee.new(name)
        extend(Employee, Person.new(name))
        return constructor(Employee, function(self)
            self.name = name
        end)
    end

    function Employee:Work()
        print(f"{self.name} is now working.")
    end
end

return singleton "Employee"