Greeter = class "Greeter" do
    function Greeter:CreateGenerator(greeting)
        return function(name)
            local g = greeting
            printf "{g}, {name}!"
        end
    end
end

return singleton "Greeter"