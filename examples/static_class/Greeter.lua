Greeter = class "Greeter" do
    function Greeter:CreateGenerator(greeting)
        return function(name)
            printf "{greeting}, {name}!"
        end
    end
end

return singleton "Greeter"