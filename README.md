# Luay

## What's Different From Lua?

Luay contrasts starkly to Lua because it comes with "batteries included". This means there is a plethora of utility that's similar to utility you could find in other languages such as Java or NodeJS.

## Kinds of Utilities

Luay includes utilities such as Java's StringBuilder class, Node's EventEmitter class, data structure classes (map, list, stack, vector), and more.

## Main Method

Luay brings a feature to Lua that many other programming languages support, the "main" method. A Luay program must have an entry point, so it looks for a global function called "main". If it cannot find "main", it then looks for a global class called "Program", subsequently a "Main" method inside of the "Program" class. If it doesn't find either, the following error is thrown:
```s
[Luay] Your program lacks a 'main' function or 'Program' class with 'Main' method, therefore it can not run.
```

## Strings

Strings in Luay support a limited set of standard arithmetic operators. These include: +, unary -, unary ~, ^, and >>.  
Here's an example of what each operator does:
```lua
-- concatenation
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

Luay does not have a REPL yet. You can only execute files. The CLI is currently very buggy, and can only execute files in Luay's installation directory.