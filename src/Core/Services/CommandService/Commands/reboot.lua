local ParallelService = require("ParallelService")

return {
    Help = "",
    Flags = {},
    Handle = function()
        print("[Exit] Rebooting")
        wait(1)
        os.reboot()
    end
}