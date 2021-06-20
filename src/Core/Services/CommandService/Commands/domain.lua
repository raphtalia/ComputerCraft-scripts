return {
    Help = "",
    Flags = {},
    Handle = function(command)
        local subcommand = command.Arguments[1]
        local domainName = command.Arguments[2]

        if subcommand == "join" then
            print("Joining domain", domainName)
        elseif subcommand == "create" then
            print("Creating domain", domainName)
        elseif subcommand == "leave" then
            print("Leaving domain")
        end
    end
}