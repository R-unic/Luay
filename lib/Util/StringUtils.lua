local StringBuilder = class "StringBuilder" do
    local AssertString
    ---@param originalContent string
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
        return self:Append(str + std.endl)
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
        return self:Prepend(str + std.endl)
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
    ---@param attributes? table
    ---@return string
    local function shortTag(name, attributes)
        assert(typeof(name) == "string", "expected tag name to be string")
        local tag = StringBuilder(("  "):rep(blockLevel))
            :Append("<" + name)

        if attributes then
            for attr in ~std.Vector("string", attributes) do
                tag:Append(" " + attr)
            end
        end
        return tostring(tag:Append(" />"))
    end

    ---@param name string
    ---@param content string
    ---@param attributes? Vector
    ---@return string
    local function htmlTag(name, content, attributes)
        assert(typeof(name) == "string", "expected tag name to be string")
        assert(content ~= nil and typeof(content) == "string", "expected content to be string")
        ---@diagnostic disable-next-line: need-check-nil
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
                :Append(">" + (content or ""))
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
        local fullAttributes = std.Vector.new("string", {f'href="{link}"'})
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
    ---@param attributes? table
    function HTML:Html(content, attributes)
        return htmlTag("html", content, attributes)
    end

    ---@param content string
    ---@param attributes? table
    function HTML:Head(content, attributes)
        return htmlTag("head", content, attributes)
    end

    ---@param content string
    ---@param attributes? table
    function HTML:Header(content, attributes)
        return htmlTag("header", content, attributes)
    end

    ---@param content string
    ---@param attributes? table
    function HTML:Body(content, attributes)
        return htmlTag("body", content, attributes)
    end

    ---@param attributes? table
    function HTML:Link(attributes)
        return shortTag("link", attributes)
    end

    ---@param iconPath string
    ---@param attributes? table
    function HTML:FavIconLink(iconPath, attributes)
        local fullAttributes = std.Vector.new("string", {'rel="icon"', ('href="%s"'):format(iconPath)})
        if attributes then
            fullAttributes = fullAttributes & attributes
        end
        return self:Link(fullAttributes:ToTable())
    end

    ---@param cssPath string
    ---@param attributes? table
    function HTML:StylesheetLink(cssPath, attributes)
        local fullAttributes = std.Vector.new("string", {'rel="stylesheet"', ('href="%s"'):format(cssPath)})
        if attributes then
            fullAttributes = fullAttributes & attributes
        end
        return self:Link(fullAttributes:ToTable())
    end

    ---@param content string
    ---@param attributes? table
    function HTML:P(content, attributes)
        return htmlTag("p", content, attributes)
    end

    ---@param content string
    ---@param attributes? table
    function HTML:B(content, attributes)
        return htmlTag("b", content, attributes)
    end

    ---@param content string
    ---@param attributes? table
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
    ---@param attributes? table
    function HTML:Code(content, attributes)
        return htmlTag("code", content, attributes)
    end

    ---@param content string
    ---@param attributes? table
    function HTML:Pre(content, attributes)
        return htmlTag("pre", content, attributes)
    end

    ---@param content string
    ---@param attributes? table
    function HTML:Title(content, attributes)
        return htmlTag("title", content, attributes)
    end

    ---@param content string
    ---@param attributes? table
    function HTML:Table(content, attributes)
        return htmlTag("table", content, attributes)
    end

    ---@param content string
    ---@param attributes? table
    function HTML:Ul(content, attributes)
        return htmlTag("ul", content, attributes)
    end

    ---@param content string
    ---@param attributes? table
    function HTML:Li(content, attributes)
        return htmlTag("li", content, attributes)
    end
end

---@class StringUtils
return module "StringUtils" {
    StringBuilder = StringBuilder;
    HTML = HTML;
}
