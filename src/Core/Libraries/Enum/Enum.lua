local newEnumItem = require(script.Directory.. "/EnumItem.lua").new

local Enum = {}
function Enum:__tostring()
    return self.Name
end

function Enum:__index(i)
    local v = self.EnumItems[i]

    if v then
        return v
    else
        error(("%s is not a valid member of \"%s\""):format(i, "Enum.".. self.Name), 2)
    end
end

function Enum:__newindex(i)
    error(i.. " cannot be assigned to", 2)
end

function Enum.new(enumName, enumItemsList)
    local enum = setmetatable(
        {
            Name = enumName,
            EnumItems = {}
        },
        Enum
    )

    for i, v in pairs(enumItemsList) do
        local enumItemName, enumItemValue

        local t = type(i)
        if t == "number" then
            enumItemName = v
            enumItemValue = i

            if type(v) ~= "string" then
                error("Expected string as value when key is a number", 4)
            end
        elseif t == "string" then
            enumItemName = i
            enumItemValue = v
        else
            error("Expected number or string as key", 4)
        end

        enum.EnumItems[enumItemName] = newEnumItem(enumItemName, enumItemValue, enum)
    end

    return enum
end

function Enum:GetEnumItems()
    local list = {}

    for _,enumItem in pairs(self.EnumItems) do
        table.insert(list, enumItem)
    end

    return list
end

return Enum