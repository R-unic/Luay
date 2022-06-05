function askContinue()
    local answer
    while answer ~= "y" and answer ~= "n" do
        answer = std.lin >> "continue with this operation (y/n)? "
    end

    if answer == "y" then
        print "continuing..."
    else
        print "not continuing..."
    end
end

function ask(question)
    local response
    while not response or response:IsBlank() do
        response = std.lin >> question + "\n"
    end
    return response
end

function main()
    local cmd = ask("What do you want to do?")
    askContinue()

    local nextCmd = ask("What do you want to do now?")
    askContinue()

    printf "{cmd}ing"
    printf "{nextCmd}ing"
    print "exiting"
end