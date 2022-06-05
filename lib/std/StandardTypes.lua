return function(Lists)
    ---@class Function : function
    ---@field callback Function
    local Function = class "Function" do
        ---@param callback Function
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
                        local res = Lists.List()
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
                    ---@type String
                    local str = tostring(self.callback)
                    return str:CapitalizeFirst()
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

    ---@class String : string
    ---@field content? string
    local String = class "String" do
        ---@param content string
        ---@return String
        function String.new(content)
            return constructor(String, function(self)
                self.content = content or ""
            end)
        end

        --- Calls `predicate` for each
        --- character in the string. If
        --- `predicate` returns true,
        --- append the current character
        --- to the result returned by `:Filter`.
        ---@param predicate function
        ---@return String
        function String:Filter(predicate)
            local res = ""
            for i = 1, #self do
                local v = self:CharAt(i)
                if predicate(v, i) then
                    res = res + v
                end
            end
            return res
        end

        --- Calls `transform` for each
        --- character in the string and 
        --- appends the string returned
        --- by `transform`.
        ---@param transform function
        ---@return String
        function String:Map(transform)
            local res = ""
            for i = 1, #self do
                res = res + transform(self:CharAt(i), i)
            end
            return res
        end

        --- Trims a string from leading
        --- and trailing whitespaces.
        ---@return String
        function String:Trim()
            local s = self:GetContent()
            local _, i1 = s:find("^%s*")
            local i2 = s:find("%s*$")
            return self[{i1 + 1;i2 - 1}]
        end

        --- Returns itself
        ---@return String
        function String:GetContent()
            return self.content or self
        end

        --- Capitalizes the first
        --- character of the string
        --- and returns the result.
        ---@return String
        function String:CapitalizeFirst()
            local first = self[1]
            local rest = self[{2;#self}]
            return first:upper() + rest
        end


        --- Returns an iterator that
        --- returns each character of
        --- the string. Use the unary `~`
        --- operator on a string as
        --- an alias for this method.
        ---@return function
        function String:Chars()
            local i = 0
            return function()
                i = i + 1
                if i <= #self then
                    return self[i]
                end
            end
        end

        --- Splits a string into a
        --- `List` of strings, each
        --- element delimited by `sep`.
        ---@param sep string
        ---@return List
        function String:Split(sep)
            local res = Lists.Vector("string")
            if not sep then
                for c in ~self do
                    res:Add(c)
                end
            else
                for str in self:gmatch("([^" + sep + "]+)") do
                    res:Add(str)
                end
            end
            return res
        end

        --- Returns a tuple of
        --- each character inside
        --- of the string.
        ---@return ...
        function String:Unpack()
            local chars = Lists.Vector("string")
            for c in ~self do
                chars:Add(c)
            end
            return chars:Unpack()
        end

        --- Replaces each occurence of 
        --- `content` with `replacement` 
        --- and returns the result.
        ---@param content string
        ---@param replacement string
        ---@return String
        function String:Replace(content, replacement)
            return self:GetContent():gsub(content, replacement)
        end

        --- Returns true if there are
        --- any occurences of `sub`
        --- inside of the string,
        --- false otherwise.
        ---@param sub string
        ---@return boolean
        function String:Includes(sub)
            return self:GetContent():find(sub) and true or false
        end

        --- Returns true if the string
        --- is a valid e-mail address,
        --- false otherwise.
        ---@return boolean
        function String:IsEmail()
            return self:GetContent():match("[A-Za-z0-9%.%%%+%-%_]+@[A-Za-z0-9%.%%%+%-%_]+%.%w%w%w?%w?") ~= nil
        end

        --- Returns true if each character
        --- in the string is uppercase, false 
        --- otherwise.
        ---@return boolean
        function String:IsUpper()
            return not self:GetContent():find("%l")
        end

        --- Returns true if each character
        --- in the string is lowercase, false 
        --- otherwise.
        ---@return boolean
        function String:IsLower()
            return not self:GetContent():find("%u")
        end

        --- Returns true if each character
        --- in the string is a whitespace 
        --- (\n, \r, \t, and space), false 
        --- otherwise.
        ---@return boolean
        function String:IsBlank()
            return not self:IsAlphaNumeric() and self:Includes("%s+") or self == ""
        end

        ---@return boolean
        String.IsEmpty = String.IsBlank
        ---@return boolean
        String.IsWhite = String.IsBlank

        --- Returns true if each character
        --- in the string is a letter, false 
        --- otherwise.
        ---@return boolean
        function String:IsAlpha()
            return self:GetContent():find("%A")
        end

        --- Returns true if the string is
        --- a valid number, false otherwise.
        ---@return boolean
        function String:IsNumeric()
            return tonumber(self:GetContent()) and true or false
        end

        ---@return boolean
        String.IsDigit = String.IsNumeric

        --- Returns true if each character
        --- in the string is a letter or 
        --- the string is a valid number, 
        --- false otherwise.
        ---@return boolean
        function String:IsAlphaNumeric()
            return self:IsAlpha() or self:IsNumeric()
        end

        ---@return boolean
        String.IsAlphaNum = String.IsAlphaNumeric

        --- Returns a new string enclosed in 
        --- `wrap` repeated `repetitions` times.
        ---@param wrap string
        ---@param repetitions? integer
        ---@return String
        function String:Wrap(wrap, repetitions)
            wrap = tostring(wrap):rep(repetitions or 1)
            return wrap + self:GetContent() + wrap
        end

        --- Encloses a string in quotation marks
        ---@return String
        function String:Quote()
            return self:GetContent():Wrap('"')
        end

        --- Returns the character at the 
        --- position `idx` in the string.
        ---@param idx integer
        ---@return String
        function String:CharAt(idx)
            return self:GetContent()[idx]
        end
    end

    ---@class EventSubscription
    ---@field event Event
    ---@field callback Function
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
                self.listeners = Lists.Vector("function")
            end)
        end

        ---@vararg ...
        ---@return void
        function Event:Fire(...)
            for callback in ~self.listeners do
                callback(...)
            end
        end

        ---@param callback Function
        ---@return EventSubscription
        function Event:Subscribe(callback)
            self.listeners:Add(callback)
            return EventSubscription(self, callback)
        end
    end

    setmetatable(string, { __index = String })

    ---@class EventEmitter : Class
    ---@field listeners Map
    local EventEmitter = class "EventEmitter" do
        ---@return EventEmitter
        function EventEmitter.new()
            return constructor(EventEmitter, function(self)
                self.listeners = Lists.Map("string", "Vector")
            end)
        end

        ---@param event string
        ---@return Vector
        function EventEmitter:GetListener(event)
            local callbacks = self.listeners:Get(event)
            if not callbacks then
                self.listeners:Set(event, Lists.Vector("function"))
                return self:GetListener(event)
            end
            return self.listeners:Get(event)
        end

        ---@param event string
        ---@return integer
        function EventEmitter:ListenerCount(event)
            return #self:GetListener(event)
        end

        ---@param event string
        ---@param callback function
        ---@return EventEmitter
        function EventEmitter:AddListener(event, callback)
            self:GetListener(event):Add(callback)
            return self
        end

        ---@param event string
        ---@param callback function
        ---@return EventEmitter
        function EventEmitter:RemoveListener(event, callback)
            self:GetListener(event):Remove(callback)
            return self
        end

        ---@param event string
        ---@vararg ...
        ---@return EventEmitter
        function EventEmitter:Emit(event, ...)
            local callbacks = self:GetListener(event)
            for callback in ~callbacks do
                callback(...)
            end
            return self
        end

        ---@param event string
        ---@param callback function
        ---@return EventEmitter
        function EventEmitter:On(event, callback)
            return self:AddListener(event, callback)
        end

        ---@param event string
        ---@param callback function
        ---@return EventEmitter
        function EventEmitter:Once(event, callback)
            local function doOnce(...)
                callback(...)
                self:Off(event, doOnce)
            end
            return self:On(event, doOnce)
        end

        ---@param event string
        ---@param callback function
        ---@return EventEmitter
        function EventEmitter:Off(event, callback)
            return self:RemoveListener(event, callback)
        end

        ---@param self ClassInstance
        ---@return void
        function EventEmitter:Destroy()
            self.listeners = nil
            self.meta.__index = function()
                throw(Error("EventEmitter no longer exists."))
            end
            
            self.meta.__newindex = function()
                throw(Error("EventEmitter no longer exists."))
            end
        end
    end

    ---@class StandardTypes
    return module "StandardTypes" {
        String = String;
        Function = Function;
        Event = Event;
        EventEmitter = EventEmitter;
    }
end