# Luay

## What's Different From Lua?

Luay contrasts starkly to Lua because it comes with "batteries included". This means there is utility that you could find in other languages such as Java or NodeJS.

## Kinds of Utilities

Luay is loaded with utility to make scripting in Lua as a standalone language much easier. Why you'd want to use Lua as a standalone language? Maybe because it's easy? I don't know, but it's certainly easy with Luay.

## Regular Lua Script Incompatibilities

If you write a regular Lua script that does something and exits, running Luay on it will throw an error. This is because Luay tries to execute a "main" function (or a "Main" method inside of a "Program" class) when you run a file.

## Strings

Strings in Luay support a limited set of standard arithmetic operators. These include: +, unary -, unary ~, ^, <<, and >>.  
Here's an example of what each operator does:
<pre>
-- concatenation
print("hello " + "world") --> hello world
print("hello " << "world") --> hello world

-- reverse concatenation
print("bar" >> "foo") --> foobar

-- reverse
print(-"abcdefg") --> gfedcba

-- repeat
print("xyz" ^ 4) --> xyzxyzxyzxyz

-- iteration
for char in ~"hello world" do
    io.write(char) --> hello world
end
</pre>

## Notes

Luay does not have a REPL yet. You can only execute files. The CLI is currently very buggy, and can only execute files in Luay's installation directory.