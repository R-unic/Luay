using(luay.util)

function main()
    local line = HTML.Newline
    
    HTML:BeginBlock()

    HTML:BeginBlock()
    local headContent =
        line() +
        HTML:StylesheetLink("styles.css") +
        line()
    HTML:EndBlock()

    local head = line() + HTML:Head(headContent)

    HTML:BeginBlock()

    HTML:BeginBlock()
    local formContent = 
        line() +
        HTML:Input {'type="button"', 'value="Open my Other Document in New Window"', 'onclick="openWindow()"'} + 
        line()
    HTML:EndBlock()

    local bodyContent =
        line() +
        HTML:H1("My Document") +
        line() +
        HTML:A("https://document.com", "My Other Document") +
        line() +
        HTML:P("This document will go over some very important things.") +
        line() +
        HTML:Script([[
        function openWindow() {
            window.open("https://document.com");
        }
        ]]) +
        line() +
        HTML:Form(formContent) +
        line()
    HTML:EndBlock()

    local body = line() + HTML:Body(bodyContent)

    HTML:EndBlock()
    local html = HTML:Html(head + body + line())

    print(html)
end