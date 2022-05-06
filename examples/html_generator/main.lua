function main()
    ---@type fun(): String
    local line = lambda "|| -> util.HTML:Newline()"
    
    util.HTML:BeginBlock()

    util.HTML:BeginBlock()
    local headContent =
        line() +
        util.HTML:StylesheetLink("styles.css") +
        line()
    util.HTML:EndBlock()

    local head = line() + util.HTML:Head(headContent)

    util.HTML:BeginBlock()

    util.HTML:BeginBlock()
    local formContent = 
        line() +
        util.HTML:Input {'type="button"', 'value="Open my Other Document in New Window"', 'onclick="openWindow()"'} + 
        line()
    util.HTML:EndBlock()

    local bodyContent =
        line() +
        util.HTML:H1("My Document") +
        line() +
        util.HTML:A("https://document.com", "My Other Document") +
        line() +
        util.HTML:P("This document will go over some very important things.") +
        line() +
        util.HTML:Script([[
        function openWindow() {
            window.open("https://document.com");
        }
        ]]) +
        line() +
        util.HTML:Form(formContent) +
        line()
    util.HTML:EndBlock()

    local body = line() + util.HTML:Body(bodyContent)

    util.HTML:EndBlock()
    local html = util.HTML:Html(head + body + line())

    print(html)
end