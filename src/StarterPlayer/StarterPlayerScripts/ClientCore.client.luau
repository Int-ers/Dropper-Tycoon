local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Packages.Loader)

local Success, Response = pcall(function()
	local LoadedServices = Loader.LoadDescendants(ReplicatedStorage["Main Client"].Bridges)
	local LoadedControllers = Loader.LoadDescendants(ReplicatedStorage["Main Client"].Controllers)
	local UIModules = Loader.LoadDescendants(ReplicatedStorage["Main Client"]["UI Handling"].Modules)

	Loader.SpawnAll(LoadedServices, "OnStart")
	Loader.SpawnAll(LoadedControllers, "OnStart")
	Loader.SpawnAll(UIModules, "OnStart")
end)

if not Success then
	function kickPlayer(player: Player)
		player:Kick("An error occurred whilst starting the client. Error: \n" .. Response)
	end
	print("client error")
	kickPlayer(LocalPlayer)
end
