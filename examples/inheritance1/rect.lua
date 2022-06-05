Rectangle = class "Rectangle" do
    function Rectangle.new(width, height)
        return constructor(Rectangle, function(self)
            self.width = width
            self.height = height
        end)
    end

    function Rectangle:Perimeter()
        return self.width * 2 + self.height * 2
    end

    function Rectangle:Area()
        return self.width * self.height
    end

    function Rectangle:__repr()
        print(f"Rectangle( width={self.width} height={self.height} )")
    end
end

return singleton "Rectangle"