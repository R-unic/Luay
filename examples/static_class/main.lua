using(luay.std)

import "Greeter"

Program = class "Program" do
    function Program:Main(argc, argv)
        local greetInEnglish = Greeter:CreateGenerator("Hello")
        greetInEnglish("world")
        greetInEnglish("John")

        local greetInSpanish = Greeter:CreateGenerator("Hola")
        greetInSpanish("mundo")
        greetInSpanish("Juan")
    end
end