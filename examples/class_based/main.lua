Program = class "Program" do
    function Program:SayHello(name)
        printf "Hello, {name}!"
    end

    function Program:Main() --argc, argv can be put here too
        print(Process.argc)
        repr(Process.argv)
        self:SayHello "world"
        self:SayHello "John"
    end
end