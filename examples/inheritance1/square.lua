import "rect"

Square = class "Square" do
    function Square.new(size)
        extend(Square, Rectangle.new(size, size))
        return constructor(Square, function(self)
            self.size = size
        end)
    end

    function Square:__repr()
        print(f"Square( size={self.size} width={self.width} height={self.height} )")
    end
end

return singleton "Square"