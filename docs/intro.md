# Example
In this very simple example, we'll create the best game ever conceived;
it rewards you for simply existing!

Or in boring words, the player's score goes up as they stay in the game.

### Assumptions
The client and server should have access to the same `UnifiedData` ModuleScript. In this example, it'll just be a direct child of `ReplicatedStorage`.

The code under [Server](#server) is located in `ServerScriptService` while the code under [Client](#client) is located in `StarterPlayerScripts`.

### Server
```lua
--!strict
local Players = game.Players

-- We specifically grab the Server code for UnifiedData
local UnifiedData = require(game.ReplicatedStorage.UnifiedData.Server)

-- The second argument of CreateTable is optional;
-- We could set it if say we wanted the creator to start with 9999 score
-- This returns a ServerProxy; however by overriding the return type,
-- it prevents mistakes when using strict type-checking
local ScoreTable = UnifiedData.CreateTable("Score") :: {[string]: number}

local function onPlayerJoined(player: Player)
	if ScoreTable[player.Name] == nil then ScoreTable[player.Name] = 0 end
	task.spawn(function()
		while player.Parent ~= nil do
			wait(1)
			ScoreTable[player.Name] = ScoreTable[player.Name] + 1
		end
	end)
end
for _, player in pairs(Players:GetPlayers()) do
	onPlayerJoined(player)
end
Players.PlayerAdded:Connect(onPlayerJoined)
```

### Client
```lua
-- Here we grab the Client code for UnifiedData
local UnifiedData = require(game.ReplicatedStorage.UnifiedData.Client)
local Player = game.Players.LocalPlayer

-- We could potentially use UnifiedData.GetProxy instead, however
-- there's a chance that the data hasn't replicated yet, necessitating
-- that we use UnifiedData.WaitForProxy instead.
local ScoreTable = UnifiedData.WaitForProxy("Score")
ScoreTable.Changed:Connect(function(name)
	if name == Player.Name then
		print(`Score is now {ScoreTable[name]}`)
	end
end)

wait(10)

print(`My score is currently {ScoreTable[Player.Name]}`)
```

With all the code in place, when testing in studio you should see print statements in the output reporting the score for you, while effectively all you've done is make a table and modify it on the server and read from it on the client.