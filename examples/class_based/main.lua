Program = {} do
    function Program:SayHello(name)
        print(f"Hello, {name}!")
    end

    function Program:Main(argc, argv)
        print(argc)
        repr(argv)
        print(process.argc)
        repr(process.argv)
        self:SayHello("world")
        self:SayHello("John")
    end
end