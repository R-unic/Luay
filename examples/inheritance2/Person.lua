Person = class "Person" do
    function Person.new(name)
        return constructor(Person, function(self)
            self.name = name
        end)
    end

    function Person:Sleep()
        printf "{self.name} is now sleeping."
    end
end

return singleton "Person"