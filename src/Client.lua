local HttpService = game:GetService("HttpService")

local Shared = require(script.Parent.Shared)
local Client = {}
local Proxies = {}
local DataFolder = script.Parent.DataFolder

export type AttributeValue = Shared.AttributeValue
export type DataKey = Shared.DataKey
export type DataTable = Shared.DataTable
local DeserializeDataTable = Shared.DeserializeDataTable

--[=[
    @class ClientProxy
    @__index = ClientProxyMethods
    @client
    
    Layer that manages automatically accessing the underlying folder which actually contains the serialized [DataTable].
    Similar to [ServerProxy], although client proxies are instead read-only (enforced by `table.freeze`) and have
    some additional tools and events to facilitate ease of use as a recipient.

    Similar to [ServerProxy], ClientProxy is meant to have its type overridden to facilitate autocompletion.
    This is particularly useful for ClientProxy as it has some methods and values that [ServerProxy] does not contain.
    ```lua
    local Player = game.Players.LocalPlayer
    local UnifiedData = require(path.to.module.Client)
    type ScoreTable = {[string]: {current: number, delta: number}}
    local ScoresProxy = UnifiedData.WaitForProxy("scores") :: ScoreTable & UnifiedData.ClientProxy
    ```
    By overriding the type such as above, `ScoreProxy` will have methods such as [ClientProxy:IsValid]
    and fields such as [ClientProxy.Changed] while still maintaining the tables own fields
    as suggestions.
]=]
local ClientProxy = {}
local ClientProxyMethods = {}
ClientProxy.__index = ClientProxyMethods

--- @prop Changed RBXScriptSignal
--- @within ClientProxy
--- Fires whenever a value is modified, sends relevant index [DataKey]

--- @prop Destroying RBXScriptSignal
--- @within ClientProxy
--- Fires when the relevant data has been removed, sends relevant index [DataKey]

--- @prop __folder Folder
--- @within ClientProxy
--- @private
--- Underlying folder that contains subfolders and attributes that contains the serialized [DataTable]

--- @prop __child_proxies {[DataKey]: ClientProxy}
--- @within ClientProxy
--- @private
--- Cached proxies that are sub-tables of the relevant [DataTable]

function ClientProxy.new(folder: Folder)
    local changed = Instance.new("BindableEvent")
    local t = {
        __folder = folder,
        __child_proxies = {},
        Changed = changed.Event,
        Destroying = folder.Destroying
    }
    folder.AttributeChanged:Connect(function(attribute)
        changed:Fire(tonumber(attribute) or attribute)
    end)
    folder.DescendantAdded:Connect(function(descendant)
        changed:Fire(tonumber(descendant.Name) or descendant.Name)
    end)
    folder.DescendantRemoving:Connect(function(descendant)
        changed:Fire(tonumber(descendant.Name) or descendant.Name)
    end)
    folder.Destroying:Once(function()
        changed:Destroy()
    end)
    return table.freeze(setmetatable(t, ClientProxy))
end

export type ClientProxy = typeof(ClientProxy.new(Instance.new("Folder"))) & typeof(ClientProxyMethods)
ClientProxyMethods = ClientProxyMethods :: ClientProxy -- Coerces `self` in methods to ClientProxy

function ClientProxy.__index(self: ClientProxy, key: DataKey)
    if ClientProxyMethods[key] ~= nil then return ClientProxyMethods[key] end
    if self.__child_proxies[key] ~= nil and self.__child_proxies[key]:IsValid() then return self.__child_proxies[key] end
    if self.__folder:GetAttribute(tostring(key)) ~= nil then
        return self.__folder:GetAttribute(tostring(key))
    end
    if self.__folder:FindFirstChild(tostring(key)) ~= nil then
        local childProxy = ClientProxy.new(self.__folder:FindFirstChild(key))
        self.__child_proxies[key] = childProxy
        return childProxy
    end
    return nil
end

function ClientProxy.__eq(self: ClientProxy, other: ClientProxy)
    return self.__folder == other.__folder
end

--- @within ClientProxy
--- @return DataTable
--- Returns a copy of the underlying data which can be freely modified by the client.
function ClientProxyMethods:CloneAsOwned() : DataTable
    return select(2, DeserializeDataTable(self.__folder))
end

--- @within ClientProxy
--- @return () -> DataKey?, (AttributeValue | ClientProxy)?
--- Returns an iterator that goes over the values of the proxy.
--- For some semblance of consistency,  prioritizes number indices first,
--- then non-table values, and finally table values.
---
--- For convenience, this is also used as the underlying implementation
--- for the `__iter` metamethod for use in generalized `for` loops,
--- such as in the following example.
--- ```lua
--- local UnifiedData = require(path.to.module).Client
--- local proxy = UnfiedData.GetProxy("SomeData")
--- for k, v in proxy do
---     print(k, v, typeof(v)) --> DataKey, AttributeValue | ClientProxy, typeof(AttributeValue) | "table"
--- end
--- ```
function ClientProxyMethods:Iterate() : (DataKey?, (AttributeValue | ClientProxy)?)
    return Shared.IterateProxy(self)
end

--- @within ClientProxy
--- @return boolean
--- Returns `true` if the underlying folder still exists, otherwise returns `false`
function ClientProxyMethods:IsValid()
    return self.__folder.Parent ~= nil
end

--- @within ClientProxy
--- @return boolean
--- Returns `true` if all children of underlying folder have replicated, otherwise returns `false`
function ClientProxyMethods:IsLoaded()
    local expectedChildren = HttpService:JSONDecode(self.__folder:GetAttribute("__expected_children"))
    if #expectedChildren == 0 then return true end
    for _, childName in pairs(expectedChildren) do
        if self.__folder:FindFirstChild(childName) == nil then
            return false
        end
    end

    return true
end

--- @within ClientProxy
--- @return ClientProxy?
--- @yields
--- @param timeout -- Default of 5
--- @param pollRate -- Default of 1/60
--- Returns the ClientProxy immediately if [ClientProxy:IsLoaded] resolves to true,
--- otherwise halts the thread until it has fully replicated and then returns the proxy.
--- Returns `nil` if [ClientProxy:IsLoaded] does not resolve within `timeout` seconds,
--- default of 5 seconds
function ClientProxyMethods:WaitForLoaded(timeout: number?, pollRate: number?)
    local loaded = false
    local endTime = time() + (timeout or 5)
    local pollRate = pollRate or 1/60
    repeat
        task.wait(pollRate)
        loaded = self:IsLoaded()
    until loaded or time() > endTime
    return if loaded then self else nil
end

--- @within ClientProxy
--- Fires given `callback` when ClientProxy[key] is changed to a new value, passing the new value to `callback`.
function ClientProxyMethods:OnKeyChanged(key: DataKey, callback: ((AttributeValue | ClientProxy)?) -> ()) : RBXScriptConnection
    return self.Changed:Connect(function(changedKey)
        if changedKey == key then
            callback(self[key])
        end
    end)
end

--- @within ClientProxy
--- @method __iter
--- @return DataKey, (AttributeValue | ClientProxy)
--- See [ClientProxy:Iterate] for details
ClientProxy.__iter = Shared.IterateProxy

--- @within UnifiedData
--- @client
--- If the data exists, returns its relevant [ClientProxy] or creates a new one.
--- Otherwise returns `nil`.
function Client.GetProxy(key: DataKey) : ClientProxy?
    if Proxies[key] then return Proxies[key] end
    if DataFolder:FindFirstChild(tostring(key)) then
        local proxy = ClientProxy.new(DataFolder:FindFirstChild(tostring(key)))
        proxy.Destroying:Once(function()
            Proxies[key] = nil
        end)
        Proxies[key] = proxy
        return proxy
    end
    return nil
end

--- @within UnifiedData
--- @client
--- @param callback -- Callback to be fired when the server adds a new table
function Client.OnKeyAdded(callback: (DataKey) -> ())
    return DataFolder.ChildAdded:Connect(function(child)
        callback(tonumber(child.Name) or child.Name)
    end)
end

--- @within UnifiedData
--- @client
--- @param callback -- Callback to be fired when the server removes a table
function Client.OnKeyRemoved(callback: (DataKey) -> ())
    return DataFolder.ChildRemoved:Connect(function(child)
        callback(tonumber(child.Name) or child.Name)
    end)
end

--- @within UnifiedData
--- @client
--- @yields
--- @return ClientProxy?
--- Essentially a wrapper around Client.GetProxy that will block the thread until `timeout` seconds occur (default of 5)
--- if the relevant data doesn't yet exist. May yield for up to 5 seconds longer than given `timeout` to ensure
--- proxy has loaded.
function Client.WaitForProxy(key: DataKey, timeout: number?) : ClientProxy?
    local proxy = Client.GetProxy(key)
    if proxy ~= nil then return proxy end

    timeout = timeout or 5
    -- Would probably be best to use something like a promise but I'd like to refrain from using external dependencies
    local bv = Instance.new("BindableEvent")
    task.delay(timeout, function()
        bv:Fire()
    end)
    local onAdded = Client.OnKeyAdded(function(dataKey)
        if key == dataKey then
            bv:Fire()
        end
    end)

    bv.Event:Wait()
    bv:Destroy()
    onAdded:Disconnect()

    return Client.GetProxy(key):WaitForLoaded()
end

return Client