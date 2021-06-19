local EnumItem = {}
function EnumItem:__tostring()
    return ("Enum.%s.%s"):format(tostring(self.Enum), self.Name)
end

function EnumItem:__newindex(i)
    error(i.. " cannot be assigned to", 2)
end

function EnumItem.new(name, value, enum)
    local enumItem = setmetatable(
        {
            Name = name,
            Value = value,
            Enum = enum,
        },
        EnumItem
    )

    return enumItem
end

return EnumItem