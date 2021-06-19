return {
    Help = "",
    Flags = {},
    Handle = function(command)
        for i,v in pairs(command.Flags) do
            print(i,v)
        end
    end
}