do  
    local function isNaN(v)
        return v ~= v
    end
    
    local function range(from, to, step)
        step = step or 1
        return function(_, lastvalue)
            local nextvalue = lastvalue + step
            if step > 0 and nextvalue <= to or step < 0 and nextvalue >= to or
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
    
    local StringBuilder = class "StringBuilder" do
        local AssertString
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

        function AssertString(str)
            assert(typeof(str) == "string", "cannot append/prepend a non-string value")
        end

        function StringBuilder:Append(str)
            AssertString(str)
            self.content = self.content + str
            return self
        end

        function StringBuilder:AppendLine(str)
            str = str or ""
            return self:Append(str + std.endl)
        end

        function StringBuilder:Prepend(str)
            AssertString(str)
            self.content = str + self.content
            return self
        end

        function StringBuilder:PrependLine(str)
            str = str or ""
            return self:Prepend(str + std.endl)
        end

        function StringBuilder:ToString()
            return self.content
        end
    end

    local HTML = class "HTML" do
        function arrows(str)
            return ("<%s>"):format(str)
        end

        function shortTag(name, attributes)
            assert(typeof(name) == "string", "expected tag name to be string")
            assert(attributes ~= nil and (typeof(attributes) == "Vector" and attributes.type == "string") or true, "expected Vector<string> of attributes")
            local tag = StringBuilder.new("<")
                :Append(name)

            if attributes then
                for attr in attributes:Values() do
                    tag:Append(" " + attr)
                end
            end
                
            tag:Append(" />")
            return tostring(tag)
        end

        function htmlTag(name, content, attributes)
            assert(typeof(name) == "string", "expected tag name to be string")
            assert(content ~= nil and typeof(content) == "string" or true, "expected content to be string")
            assert(attributes ~= nil and (typeof(attributes) == "Vector" and attributes.type == "string") or true, "expected Vector<string> of attributes")
            local tag = StringBuilder.new(arrows(name))
                :Append(content or "")
                
            if attributes then
                for attr in attributes:Values() do
                    tag:Append(" " + attr)
                end
            end

            tag:Append(arrows("/" + name))
            return tostring(tag)
        end

        function HTML:Html(content, attributes)
            return htmlTag("html", content, attributes)
        end

        function HTML:Head(content, attributes)
            return htmlTag("head", content, attributes)
        end

        function HTML:Header(content, attributes)
            return htmlTag("header", content, attributes)
        end

        function HTML:Body(content, attributes)
            return htmlTag("body", content, attributes)
        end

        function HTML:Link(attributes)
            return shortTag("link", attributes)
        end

        function HTML:FavIconLink(iconPath, attributes)
            return self:Link(std.Vector.new("string", {'rel="icon"', ('href="%s"'):format(iconPath)}):Merge(attributes))
        end

        function HTML:StylesheetLink(cssPath, attributes)
            return self:Link(std.Vector.new("string", {'rel="stylesheet"', ('href="%s"'):format(cssPath)}):Merge(attributes))
        end

        function HTML:P(content, attributes)
            return htmlTag("p", content, attributes)
        end

        function HTML:B(content, attributes)
            return htmlTag("b", content, attributes)
        end

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

        function HTML:Code(content, attributes)
            return htmlTag("code", content, attributes)
        end

        function HTML:Pre(content, attributes)
            return htmlTag("pre", content, attributes)
        end

        function HTML:Title(content, attributes)
            return htmlTag("title", content, attributes)
        end

        function HTML:Table(content, attributes)
            return htmlTag("table", content, attributes)
        end

        function HTML:Ul(content, attributes)
            return htmlTag("ul", content, attributes)
        end

        function HTML:Li(content, attributes)
            return htmlTag("li", content, attributes)
        end
    end

    local Function = class "Function" do
        function Function.new(callback)
            return constructor(Function, function(self)
                self.callback = callback

                function self.meta.__call(_, ...)
                    return self:Call(...)
                end

                function self.meta.__tostring()
                    return tostring(self.callback)
                end
            end)
        end

        function Function:Apply(args)
            return self:Call(table.unpack(args))
        end

        function Function:Bind(selfValue, ...)
            self.callback = bind(self.callback, selfValue, ...)
            return self
        end

        function Function:Call(...)
            return self.callback(...)
        end

        function Function:__repr()
            return tostring(self)
        end
    end

    local EventSubscription = class "EventSubscription" do
        function EventSubscription.new(event, callback)
            return constructor(EventSubscription, function(self)
                self.event = event
                self.callback = callback
            end)
        end

        function EventSubscription:Unsubscribe()
            self.event.listeners:Remove(self.callback)
        end
    end

    local Event = class "Event" do
        function Event.new()
            return constructor(Event, function(self)
                self.listeners = luay.std.Vector("function")
            end)
        end

        function Event:Fire(...)
            for callback in ~self.listeners do
                callback(...)
            end
        end

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