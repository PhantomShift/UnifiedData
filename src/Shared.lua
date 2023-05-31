--- @type AttributeValue string | boolean | number | UDim | UDim2 | BrickColor | Color3 | Vector2 | Vector3 | NumberSequence | ColorSequence | NumberRange | Rect
--- @within UnifiedData
--- As the data replication is based on using Instance Attributes,
--- only values that can be stored as Attributes are valid types to use.
---
--- In the future, storing references to Instances may be facilitated using ObjectValues in the underlying code.

--- @type DataKey number | string
--- @within UnifiedData

--- @type DataTable {[DataKey]: AttributeValue | DataTable}
--- @within UnifiedData

export type AttributeValue = string | boolean | number | UDim | UDim2 | BrickColor | Color3 | Vector2 | Vector3 | NumberSequence | ColorSequence | NumberRange | Rect
export type DataKey = number | string
export type DataTable = {[DataKey]: AttributeValue | DataTable}

local HttpService = game:GetService("HttpService")

local Shared = {}

function Shared.UpdateExpectedChildren(folder: Folder)
    local childNames = {}
    for _, c in pairs(folder:GetChildren()) do
        table.insert(childNames, c.Name)
    end
    folder:SetAttribute("__expected_children", HttpService:JSONEncode(childNames))
end

function Shared.SerializeDataTable(name: DataKey, t: DataTable)
    local root = Instance.new("Folder")
    root.Name = tostring(name)
    for key, value in pairs(t) do
        if type(value) == "table" then
            Shared.SerializeDataTable(key, value).Parent = root
        else
            root:SetAttribute(tostring(key), value)
        end
    end
    Shared.UpdateExpectedChildren(root)

    return root
end

function Shared.DeserializeDataTable(folder: Folder)
    local name: DataKey = tonumber(folder.Name) or folder.Name
    local t = {}
    for attr, value: AttributeValue in pairs(folder:GetAttributes()) do
        if attr == "__expected_children" then continue end
        t[tonumber(attr) or attr] = value
    end
    for _, child in pairs(folder:GetChildren()) do
        local key, value = Shared.DeserializeDataTable(child)
        t[tonumber(key) or key] = value
    end

    return name, t
end

function Shared.IterateProxy(self)
    local children = {}
    for _, child in pairs(self.__folder:GetChildren()) do
        children[tonumber(child.Name) or child.Name] = child
    end
    local attributes = {} 
    for attribute, value in pairs(self.__folder:GetAttributes()) do
        attributes[tonumber(attribute) or attribute] = value
    end
    local currentIndex = 0
    local co = coroutine.create(function()
        while true do
            currentIndex += 1
            local result
            if children[currentIndex] ~= nil then
                result = children
                result[currentIndex] = nil
            elseif attributes[currentIndex] ~= nil then
                result = attributes[currentIndex]
                attributes[currentIndex] = nil
            end
            if result then
                coroutine.yield(currentIndex, result)
            else
                break
            end
        end
        for key, value in pairs(attributes) do
            coroutine.yield(key, value)
        end
        for key, _ in pairs(children) do
            coroutine.yield(key, self[key])
        end
        coroutine.yield(nil)
    end)
    return function()
        local _bool, index, value = coroutine.resume(co)
        return index, value
    end
end

return Shared