local RunService = game:GetService("RunService")

--[=[
    @class UnifiedData
    Module for managing *trivial* data between server and client.
    All data is based on the server being the sole authority over data
    and is meant to be as a simple as possible to use by essentially
    simulating a shared table between the server and client utilizing
    attributes and folders.
    
    The intended use-case is for when the server has a large but mostly non-volatile amount of data that needs to be synced
    to all clients and it is inconvenient to facilitate when all one is doing is effectively modifying tables.
    With the intended goal being as simple to handle as possible, the code is not particularly optimized.

    The module is expected to be imported as follows
    ```lua
    -- Server
    local UnifiedData = require(path.to.module.Server)

    -- Client
    local UnifiedData = require(path.to.module.Client)

    -- Alternative, though not recommended as it will not export types
    local UnifiedData = require(path.to.module).Server
    local UnifiedData = require(path.to.module).Client
    ```
]=]
local UnifiedData = {}

if RunService:IsServer() then
    UnifiedData.Server = require(script.Server)
else
    UnifiedData.Client =  require(script.Client)
end

return UnifiedData
