local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Loader = require(ReplicatedStorage.Packages.Loader)

local Success, Response = pcall(function()
	local LoadedServices = Loader.LoadDescendants(ServerScriptService["Main Server"].Services)
	local LoadedControllers = Loader.LoadDescendants(ServerScriptService["Main Server"].Controllers)

	Loader.SpawnAll(LoadedServices, "OnStart")
	Loader.SpawnAll(LoadedControllers, "OnStart")

	-- local LoadedSharedFacilitators = Loader.LoadDescendants(ReplicatedStorage["Main Client"].Bridges)

	-- Loader.SpawnAll(LoadedSharedFacilitators, "OnStart")
end)

if not Success then
	function kickPlayer(player: Player)
		player:Kick("An error occurred whilst starting the server. Error: \n" .. Response)
	end

	for _, player: Player in pairs(Players:GetPlayers()) do
		kickPlayer(player)
	end

	Players.PlayerAdded:Connect(kickPlayer)
end
