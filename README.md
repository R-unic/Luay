# Luay

## What's Different From Lua?

Luay contrasts starkly to Lua because it comes with "batteries included". This means there is utility that you could find in other languages such as Java or NodeJS.

## Kinds of Utilities

Luay is loaded with utility to make scripting in Lua as a standalone language much easier. Why you'd want to use Lua as a standalone language? Maybe because it's easy? I don't know, but it's certainly easy with Luay.

## Regular Lua Script Incompatibilities

If you write a regular Lua script that does something and exits, running Luay on it will throw an error. This is because Luay tries to execute a "main" function (or a "Main" method inside of a "Program" class) when you run a file.

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
    local doubled = nums:Map(lambda "|x| x * 2")
    repr(doubled) --> {64, 128, 256, 512}
end
```

You can also take multiple arguments and return multiple values. However, if you ever wanted to use multiple statements inside of a lambda expression (don't know why you would), you must use ";" as a delimiter between them. For example:
```lua
local doubled = nums:Map(lambda "|x| printf 'transforming {x}'; x * 2") --> transforming 32 transforming 64 ...
```

## Notes

Luay does not have a REPL yet. You can only execute files. The CLI is currently very buggy, and can only execute files in Luay's installation directory.