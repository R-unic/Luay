do  
    ---@param v any
    ---@return boolean
    local function isNaN(v)
        return v ~= v
    end
    
    ---@param from number
    ---@param to number
    ---@param step number
    ---@return function
    ---@return nil
    ---@return number
    local function range(from, to, step)
        step = step or 1
        ---@return number
        return function(_, lastvalue)
            local nextvalue = lastvalue + step
            if 
                step > 0 and 
                nextvalue <= to or 
                step < 0 and 
                nextvalue >= to or
                step == 0
            then
                return nextvalue
            end
        end, nil, from - step
    end

    local function bind(fn, self, ...)
        assert(fn, "fn is nil")
        local bindArgsLength = select("#", ...)
      
        -- Simple binding, just inserts self (or one arg or any kind)
        if bindArgsLength == 0 then
            return function (...)
                return fn(self, ...)
            end
        end
      
        -- More complex binding inserts arbitrary number of args into call.
        local bindArgs = {...}
        return function (...)
            local argsLength = select("#", ...)
            local args = {...}
            local arguments = {}
            for i = 1, bindArgsLength do
                arguments[i] = bindArgs[i]
            end
            for i = 1, argsLength do
                arguments[i + bindArgsLength] = args[i]
            end
            return fn(self, table.unpack(arguments, 1, bindArgsLength + argsLength))
        end
    end
    
    ---@class StringBuilder
    local StringBuilder = class "StringBuilder" do
        local AssertString
        ---@param originalContent
        ---@return StringBuilder
        function StringBuilder.new(originalContent)
            return constructor(StringBuilder, function(self)
                AssertString(originalContent or "")
                self.content = originalContent or ""

                function self.meta.__tostring()
                    return self:ToString()
                end

                function self.meta.__len()
                    return #self.content
                end
            end)
        end

        ---@param str string
        ---@return void
        function AssertString(str)
            assert(typeof(str) == "string", "cannot append/prepend a non-string value")
        end

        ---@param str string
        ---@return StringBuilder
        function StringBuilder:Append(str)
            AssertString(str)
            self.content = self.content + str
            return self
        end

        ---@param str string
        ---@return StringBuilder
        function StringBuilder:AppendLine(str)
            str = str or ""
            return self:Append(str + luay.std.endl)
        end

        ---@param str string
        ---@return StringBuilder
        function StringBuilder:Prepend(str)
            AssertString(str)
            self.content = str + self.content
            return self
        end

        ---@param str string
        ---@return StringBuilder
        function StringBuilder:PrependLine(str)
            str = str or ""
            return self:Prepend(str + luay.std.endl)
        end

        ---@return string
        function StringBuilder:ToString()
            return self.content
        end
    end

    ---@class HTML
    local HTML = class "HTML" do
        local blockLevel = 0

        ---@param str string
        ---@return string
        local function arrows(str)
            return ("<%s>"):format(str)
        end

        ---@param name string
        ---@param attributes table
        ---@return string
        local function shortTag(name, attributes)
            assert(typeof(name) == "string", "expected tag name to be string")
            local tag = StringBuilder(("  "):rep(blockLevel))
                :Append("<" + name)

            if attributes then
                for attr in ~luay.std.Vector("string", attributes) do
                    tag:Append(" " + attr)
                end
            end
            return tostring(tag:Append(" />"))
        end

        ---@param name string
        ---@param content string
        ---@param attributes table
        ---@return string
        local function htmlTag(name, content, attributes)
            assert(typeof(name) == "string", "expected tag name to be string")
            assert(content ~= nil and typeof(content) == "string", "expected content to be string")
            assert(attributes ~= nil and (typeof(attributes) == "Vector" and attributes.type == "string") or true, "expected Vector<string> of attributes")
            local tag = StringBuilder(("  "):rep(blockLevel))
                :Append("<" + name)

            if attributes then
                for attr in attributes:Values() do
                    tag:Append(" " + attr)
                end
            end
            return tostring(
                tag
                    :Append(">" + content or "")
                    :Append(arrows("/" + name))
            )
        end

        function HTML:Input(attributes)
            return shortTag("input", attributes)
        end

        function HTML:Form(content, attributes)
            return htmlTag("form", content, attributes)
        end

        function HTML:Script(content, src)
            return htmlTag("script", "\n" + content, src and {f'src="{src}"'} or nil)
        end

        function HTML:Img(attributes)
            return shortTag("img", attributes)
        end

        function HTML:A(link, content, attributes)
            local fullAttributes = luay.std.Vector.new("string", {f'href="{link}"'})
            if attributes then
                fullAttributes = fullAttributes & attributes
            end
            return htmlTag("a", content, fullAttributes)
        end

        function HTML:Newline()
            return "\n" + ("  "):rep(blockLevel)
        end

        function HTML:BeginBlock()
            blockLevel = blockLevel + 1
        end

        function HTML:EndBlock()
            blockLevel = blockLevel - 1
        end

        function HTML:H4(content, attributes)
            return htmlTag("h4", content, attributes)
        end

        function HTML:H3(content, attributes)
            return htmlTag("h3", content, attributes)
        end

        function HTML:H2(content, attributes)
            return htmlTag("h2", content, attributes)
        end

        function HTML:H1(content, attributes)
            return htmlTag("h1", content, attributes)
        end

        ---@param content string
        ---@param attributes table
        function HTML:Html(content, attributes)
            return htmlTag("html", content, attributes)
        end

        ---@param content string
        ---@param attributes table
        function HTML:Head(content, attributes)
            return htmlTag("head", content, attributes)
        end

        ---@param content string
        ---@param attributes table
        function HTML:Header(content, attributes)
            return htmlTag("header", content, attributes)
        end

        ---@param content string
        ---@param attributes table
        function HTML:Body(content, attributes)
            return htmlTag("body", content, attributes)
        end

        ---@param attributes table
        function HTML:Link(attributes)
            return shortTag("link", attributes)
        end

        ---@param iconPath string
        ---@param attributes table
        function HTML:FavIconLink(iconPath, attributes)
            local fullAttributes = luay.std.Vector.new("string", {'rel="icon"', ('href="%s"'):format(iconPath)})
            if attributes then
                fullAttributes = fullAttributes & attributes
            end
            return self:Link(fullAttributes:ToTable())
        end

        ---@param cssPath string
        ---@param attributes table
        function HTML:StylesheetLink(cssPath, attributes)
            local fullAttributes = luay.std.Vector.new("string", {'rel="stylesheet"', ('href="%s"'):format(cssPath)})
            if attributes then
                fullAttributes = fullAttributes & attributes
            end
            return self:Link(fullAttributes:ToTable())
        end

        ---@param content string
        ---@param attributes table
        function HTML:P(content, attributes)
            return htmlTag("p", content, attributes)
        end

        ---@param content string
        ---@param attributes table
        function HTML:B(content, attributes)
            return htmlTag("b", content, attributes)
        end

        ---@param content string
        ---@param attributes table
        function HTML:I(content, attributes)
            return htmlTag("i", content, attributes)
        end

        function HTML:Br()
            return arrows "br"
        end

        function HTML:Hr()
            return arrows "hr"
        end

        function HTML:Tab()
            return "&nbsp;"
        end

        function HTML:LArr()
            return "&lt;"
        end

        function HTML:RArr()
            return "&gt;"
        end

        ---@param content string
        ---@param attributes table
        function HTML:Code(content, attributes)
            return htmlTag("code", content, attributes)
        end

        ---@param content string
        ---@param attributes table
        function HTML:Pre(content, attributes)
            return htmlTag("pre", content, attributes)
        end

        ---@param content string
        ---@param attributes table
        function HTML:Title(content, attributes)
            return htmlTag("title", content, attributes)
        end

        ---@param content string
        ---@param attributes table
        function HTML:Table(content, attributes)
            return htmlTag("table", content, attributes)
        end

        ---@param content string
        ---@param attributes table
        function HTML:Ul(content, attributes)
            return htmlTag("ul", content, attributes)
        end

        ---@param content string
        ---@param attributes table
        function HTML:Li(content, attributes)
            return htmlTag("li", content, attributes)
        end
    end

    ---@class Function
    ---@field callback function | Function
    local Function = class "Function" do
        ---@param callback function | Function
        ---@return Function
        function Function.new(callback)
            return constructor(Function, function(self)
                self.callback = callback

                ---@param first Function
                ---@param second Function
                ---@return function
                function self.meta.__band(first, second)
                    ---@vararg ...
                    ---@return ...
                    return function(...)
                        local res = luay.std.List()
                        for v in varargs(first(...))  do
                            res:Add(v)
                        end
                        for v in varargs(second(...)) do
                            res:Add(v)
                        end
                        return res:Unpack()
                    end
                end

                ---@vararg ...
                ---@return ...
                function self.meta.__call(_, ...)
                    return self:Call(...)
                end

                ---@return string
                function self.meta.__tostring()
                    return tostring(self.callback):CapitalizeFirst()
                end
            end)
        end

        ---@param args table | Vector | List | Set | Stack
        ---@return ...
        function Function:Apply(args)
            return self:Call(args.Unpack and args:Unpack() or table.unpack(args))
        end

        ---@param selfValue unknown
        ---@vararg ...
        ---@return Function
        function Function:Bind(selfValue, ...)
            self.callback = self.callback.Bind and self:Bind(selfValue, ...) or bind(self.callback, selfValue, ...)
            return self
        end

        ---@vararg ...
        ---@return ...
        function Function:Call(...)
            return self.callback(...)
        end

        ---@return void
        function Function:__repr()
            print(tostring(self))
        end
    end

    ---@class EventSubscription
    ---@field event Event
    ---@field callback function | Function
    local EventSubscription = class "EventSubscription" do
        ---@return EventSubscription
        function EventSubscription.new(event, callback)
            return constructor(EventSubscription, function(self)
                self.event = event
                self.callback = callback
            end)
        end

        ---@return void
        function EventSubscription:Unsubscribe()
            self.event.listeners:Remove(self.callback)
        end
    end

    ---@class Event
    ---@field listeners Vector
    local Event = class "Event" do
        ---@return Event
        function Event.new()
            return constructor(Event, function(self)
                self.listeners = luay.std.Vector("function")
            end)
        end

        ---@vararg ...
        ---@return void
        function Event:Fire(...)
            for callback in ~self.listeners do
                callback(...)
            end
        end

        ---@param callback function | Function
        ---@return EventSubscription
        function Event:Subscribe(callback)
            self.listeners:Add(callback)
            return EventSubscription(self, callback)
        end
    end

    namespace "util" {
        StringBuilder = StringBuilder;
        HTML = HTML;
        Function = Function;
        Event = Event;

        isNaN = isNaN;
        range = range;
    }
end