# Luay

## Installation

To install Luay, you must first clone the repository. A pre-built binary exists inside of the `bin` folder, and a `build.cmd` file is provided if you want to build Luay. To make sure everything is set up properly, first visit the `luaypath` file in your cloned repository, then set the file's content (defaults to `$HOME/Luay`) to the path of your cloned repository.

## What's Different From Lua?

Luay contrasts starkly to Lua because it comes with "batteries included". This means there is a plethora of utility that's similar to utility you could find in other languages such as Java or NodeJS.

## Kinds of Utilities

Luay includes utilities such as Java's StringBuilder class, Node's EventEmitter class, data structure classes (map, list, stack, vector), and more. Also see <a href="#main-method">Main Method</a>.

## Main Method

Luay brings a feature to Lua that many other programming languages support, the `main` method. A Luay program must have an entry point, so it looks for a global function called `main`. If it cannot find `main`, it then looks for a global class called `Program`, subsequently a `Main` method inside of the `Program` class. If it doesn't find either, the following error is thrown:
```
[Luay] Your program lacks a 'main' function or 'Program' class with 'Main' method, therefore it can not run.
```

## Strings

 Strings in Luay support a limited set of standard arithmetic operators to manipulate strings with. These include: `+`, unary `-`, unary `~`, `*`, and `>>`.  
Here's what each operator does:
```lua
-- standard concatenation
print("hello " + "world") --> hello world

-- reverse concatenation
print("bar" >> "foo") --> foobar

-- reverse
print(-"abcdefg") --> gfedcba

-- repeat
print("xyz" * 4) --> xyzxyzxyzxyz

-- iteration
for char in ~"hello world" do
    io.write(char) --> hello world
end
```

## Data Structures

Luay's standard library (see <a href="#stdio">StdIO</a>) comes with many data structure classes so you don't have to make them yourself. These include: `Vector<T>`, `List`, `Map`, `Stack`, `Queue`, `Deque`, `Set`, `Pair`, `KeyValuePair`, `StrictPair`, and `StrictKeyValuePair`. Yeah, it's a handful, and more are coming. Each index-value styled data structure can be iterated over using the `~` operator, as seen in <a href="#strings">Strings</a>. Otherwise, most data structures have a :Keys or :Indices method to iterate over keys and values.

## StdIO

Luay's standard library can be included in your program by calling
```lua
using(luay.std)
```

When calling `using(lib)`, you should always do it at top-level, not in your main function or any other scope.
Luay's standard library includes standard input and output "streams" (they're just classes with overloaded operators) which you can use to call IO operations with some syntactical sugar. Note that these input/output streams are also stored in the Process library, which is half implemented in C++, half in Luay. This means that `Process.stdout` and `Process.stdin` are aliases for `std.lout` and `std.lin`. Here's a simple example of a program that asks the user a question via the command line to demonstrate standard input:
```lua
using(luay.std)

function askContinue()
    local answer
    while answer ~= "y" and answer ~= "n" do
        answer = lin >> "continue with this operation (y/n)? "
    end

    if answer == "y" then
        print "continuing..."
    else
        print "not continuing..."
    end
end

function main()
    local cmd
    while not cmd or cmd:IsBlank() do
        cmd = lin >> "What do you want to do?\n"
    end
    askContinue()

    local nextCmd
    while not nextCmd or nextCmd:IsBlank() do
        nextCmd = lin >> "What do you want to do now?\n"
    end
    askContinue()

    printf "doing {cmd}"
    printf "doing {nextCmd}"
    print "exiting"
end
```

## Object Oriented

Object oriented programming is made easy in Luay using a set of functions to create classes. Since Luay is only an embedded version of Lua, changing the grammar could cause more problems than just incompatibility with <a href="#main-method">Main Methods</a>. Thus, we have these functions in Luay: `class(name: string) -> Class`, `extend(class: Class, super: instanceof Class) -> void`, `constructor(class: Class, body?: function) -> ClassInstance`, and `namespace(name: string) -> ((body: table) -> {alias = (name: string) -> void})`. Here's each one of them in use, to show you the syntax:

1. Single Class
```lua
Animal = class "Animal" do
    function Animal.new(name)
        return constructor(Animal, function(self)
            self.name = name
        end)
    end

    function Animal:Speak(sound)
        printf "The {self.name} says: {sound}"
    end
end

local dog = Animal("Dog")
dog:Speak("Woof!") --> The Dog says: Woof!
```

Now let's make a class for the dog itself.

2. Inheritance
```lua
...

Dog = class "Dog" do
    function Dog.new(breed)
        extend(Dog, Animal("Dog"))
        return constructor(Dog, function(self)
            self.breed = breed
        end)
    end

    function Dog:Bark()
        self:Speak("Woof!")
    end
end

local dog2 = Dog("Border Collie")
dog2:Bark() --> The Dog says: Woof!
print(dog.breed) --> Border Collie
```

Onto static classes. Static classes are different than classes with static and regular methods. Static classes contain only static methods and have no constructor. Static classes are different from classes with regular methods and static methods because you can encapsulate state in a static class (in an easier manner). A good example of a static class is the `Program` class that Luay looks for if a `main` function is not found.

3. Static Classes
```lua
using(luay.std)

Program = class "Program" do
    Program.mode = "default"

    function Program:DoOperation()
        if self.mode == "default" then
            print "doing things normally..."
        elseif self.mode == "verbose" then
            print "doing things LOUDLY..."
        elseif self.mode == "silent" then
            print "doing things *quietly*..."
        else
            throw(Error(f"Invalid mode: '{self.mode}'"))
        end
    end

    function Program:Main(argc, argv)
        local args = Vector("string", argv)
        args:Shift()

        if args:First() then
            self.mode = args:First():lower()
        end

        self:DoOperation()
    end
end
```

3. Classes with Static and Regular Methods
```lua
using(luay.std)

Array = class "Array" do
    function Array.new()
        return constructor(Array, function(self)
            self.cache = {}
        end)
    end

    function Array.from(tab)
        local arr = Array()
        for v in values(tab) do
            arr:Add(v)
        end
        return arr
    end 

    function Array:Add(value)
        table.insert(self.cache, value)
        return self
    end

    function Array:Remove(idx)
        table.remove(self.cache, idx)
        return self
    end

    function Array:__repr()
        repr(self.cache)
    end
end

local arr = Array.from {"foo", "bar", "baz"}
arr:Add("luay")
repr(arr) --> {"foo", "bar", "baz", "luay"}
arr:Remove(2)
repr(arr)--> {"foo", "baz", "luay"}
```

## Lambdas

Yes, you read that right. Lambdas are a shorthand way of writing an anonymous function that represents data. For example, say I have a list of numbers. I want to double each value in that list. Normally, you could do it like this in standard Luay:
```lua
using(luay.std)

function main()
    local nums = List {32, 64, 128, 256}
    local doubled = nums:Map(function(x) 
        return x * 2 
    end)
    repr(doubled) --> {64, 128, 256, 512}
end
```

With lambdas, everything becomes much conciser:
```lua
using(luay.std)

function main()
    local nums = List {32, 64, 128, 256}
    local doubled = nums:Map(lambda "|x| -> x * 2")
    repr(doubled) --> {64, 128, 256, 512}
end
```

You can also take multiple arguments and return multiple values. If you ever wanted to use multiple statements inside of a lambda expression, treat "->" as a "return" statement. For example:
```lua
local doubled = nums:Map(lambda "|x| printf 'transforming {x}' -> x * 2") --> transforming 32 transforming 64 ...
```

## Notes

Luay does not have a REPL yet. You can only execute files, and the CLI is currently slightly buggy.