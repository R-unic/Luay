Person = class "Person" do
    function Person.new(name)
        return constructor(Person, function(self)
            self.name = name
        end)
    end

    function Person:Sleep()
        print(f"{self.name} is now sleeping.")
    end
end

return singleton "Person"