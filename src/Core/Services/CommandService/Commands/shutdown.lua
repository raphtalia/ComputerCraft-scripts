return {
    Help = "",
    Flags = {},
    Handle = function()
        print("[Exit] Shutting down")
        wait(1)
        os.shutdown()
    end
}