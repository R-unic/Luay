using(luay.std)
using(luay.util)

function main()
    local sum = lambda "|x,y| -> x + y"
    print(sum(5, 3))
end