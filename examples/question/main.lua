using(std)

function askContinue()
    local answer
    while answer ~= "y" and answer ~= "n" do
        answer = lin >> "continue with this operation (y/n)? "
    end

    if answer == "y" then
        print "continuing..."
    else
        print "not continuing..."
    end
end

function main()
    local cmd
    while not cmd or cmd:IsBlank() do
        cmd = lin >> "What do you want to do?\n"
    end
    askContinue()

    local nextCmd
    while not nextCmd or nextCmd:IsBlank() do
        nextCmd = lin >> "What do you want to do now?\n"
    end
    askContinue()

    printf "doing {cmd}"
    printf "doing {nextCmd}"
    print "exiting"
end