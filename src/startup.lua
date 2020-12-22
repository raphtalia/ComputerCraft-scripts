if fs.exists("sys") then
    -- Operating system already installed
    print("Start")
else
    -- Need to install operating system
    local isBootedFromFloppy

    if fs.exists("disk") and fs.exists("disk/startup") then
        isBootedFromFloppy = true
    end

    if isBootedFromFloppy then
        -- Install using floppy
        print("Installing from disk")
    else
        -- Install using Http
        print("Installing from Github")
        shell.run("pastebin", "run", "wPtGKMam", "raphtalia", "ComputerCraft-scripts", "src", ".")
        shell.run("mv", "sysPackage/ComputerCraft-scripts/src", "")
        shell.run("mv", "sysPackage/ComputerCraft-scripts/startup", "")
    end
end

return true