import "square"

function main(argc, argv)
    local sqr = Square.new(5)
    print(sqr:Perimeter()) --> 20
    print(sqr:Area()) --> 25
end