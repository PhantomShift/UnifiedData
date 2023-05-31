local HttpService = game:GetService("HttpService")

local Shared = require(script.Parent.Shared)
local Server = {}
local Proxies = {}
local DataFolder = script.Parent.DataFolder

export type AttributeValue = Shared.AttributeValue
export type DataKey = Shared.DataKey
export type DataTable = Shared.DataTable
local SerializeDataTable = Shared.SerializeDataTable

--[=[
    @class ServerProxy
    @server

    Layer that manages automatically modifying and accessing the underlying folder which actually contains the data.
    The main difference between client and server is that the server is allowed to modify it as it pleases,
    while [ClientProxy] is completely read-only, enforced by `table.freeze`.

    Additionally, ServerProxy is rather bare-bones compared to [ClientProxy] because this module is not
    intended to share data between scripts on the server.
    
    Proxies are intended to have their type overridden to facilitate auto-completion, such as in the following example.
    ```lua
    type Score = {PlayerName: string, Value: number}
    -- Server.CreateTable returns a ServerProxy with the given data
    -- Either override using :: operation
    local scoreProxy = Server.CreateTable(Player.UserId, {PlayerName = Player.Name, Value = 0}) :: Score
    -- Or by specifying the type of the variable
    local scoreProxy: Score = Server.CreateTable(Player.UserId, {PlayerName = Player.Name, Value = 0})
    ```
    By doing so, the developer can read and modify the data as they would with a normal table while the
    underlying metamethods handle the Folders and Attributes in the background,
    facilitating replication to the clients.
]=]
local ServerProxy = {}

--- @prop __folder Folder
--- @within ServerProxy
--- @private
--- Underlying folder that contains subfolders and attributes that contains the serialized [DataTable]

--- @prop __child_proxies {[DataKey]: ClientProxy}
--- @within ServerProxy
--- @private
--- Cached proxies that are sub-tables of the relevant [DataTable]

--- @prop __valid boolean
--- @within ServerProxy
--- @private
--- Boolean indicating that the underlying `__folder` still exists.

function ServerProxy.new(folder: Folder)
    local t = {
        __folder = folder,
        __valid = folder.Parent ~= nil,
        __child_proxies = {}
    }
    if folder.Parent then
        folder.Destroying:Once(function()
            t.__valid = false
        end)
    end
    return setmetatable(t, ServerProxy)
end

export type ServerProxy = typeof(ServerProxy.new(Instance.new("Folder")))

function ServerProxy.__index(self: ServerProxy, key: DataKey)
    if self.__child_proxies[key] ~= nil and self.__child_proxies[key].__valid then return self.__child_proxies[key] end
    if self.__folder:GetAttribute(tostring(key)) ~= nil then
        return self.__folder:GetAttribute(tostring(key))
    end
    if self.__folder:FindFirstChild(tostring(key)) ~= nil then
        local childProxy = ServerProxy.new(self.__folder:FindFirstChild(key))
        self.__child_proxies[key] = childProxy
        return childProxy
    end
    return nil
end

--- @within ServerProxy
--- @server
--- @method __newindex
--- @param key DataKey
--- @param value (AttributeValue | DataTable)?
--- It should be noted that existing sub-tables are fully replaced and
--- destroys the underlying folder, replacing it with a new one. As such,
--- any references to the old proxy are invalidated
--- (indicated by private field [ServerProxy.__valid] on the server and [ClientProxy:IsValid] on the client)
function ServerProxy.__newindex(self: ServerProxy, key: DataKey, value: (AttributeValue | DataTable)?)
    if self.__folder:FindFirstChild(tostring(key)) then
        self.__folder:FindFirstChild(tostring(key)):Destroy()
    end
    if type(value) == "table" then
        SerializeDataTable(key, value).Parent = self.__folder
    else
        self.__folder:SetAttribute(tostring(key), value :: AttributeValue?)
    end
    Shared.UpdateExpectedChildren(self.__folder)
end

--- @within ServerProxy
--- @method __iter
--- @return DataKey, (AttributeValue | ClientProxy)
--- Uses the same underlying implementation of [ClientProxy:Iterate] to iterate through the proxy; see page for details
ServerProxy.__iter = Shared.IterateProxy

--- @within UnifiedData
--- @server
--- Serializes the given table `t` or creates an empty one and returns a `ServerProxy` that points to the "root"
--- of the given table.
function Server.CreateTable(key: DataKey, t: DataTable?) : ServerProxy
    assert(DataFolder:FindFirstChild(tostring(key)) == nil, `Attempted to create data table with key {key} when it already exists`)
    local folder = SerializeDataTable(key, t or {})
    folder.Parent = DataFolder

    local proxy = ServerProxy.new(folder)
    Proxies[key] = proxy
    return proxy
end

--- @within UnifiedData
--- @server
function Server.GetProxy(key: DataKey) : ServerProxy?
    return Proxies[key]
end

--- @within UnifiedData
--- @server
function Server.RemoveTable(key: DataKey)
    local folder = DataFolder:FindFirstChild(tostring(key))
    if folder ~= nil then
        Proxies[key] = nil
        folder:Destroy()
    end
end

return Server