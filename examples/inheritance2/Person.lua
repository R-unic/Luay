---@class Person : Class
Person = class "Person" do
    function Person.new(name)
        return Person:constructor(function(self)
            self.name = name
        end)
    end

    function Person:Sleep()
        printf "{self.name} is now sleeping."
    end
end

return singleton "Person"