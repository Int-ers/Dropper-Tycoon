local Players = game:GetService("Players")
Players.CharacterAutoLoads = false
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerDataStructure = require(ReplicatedStorage.Shared.Databases.PlayerDataStructure)
local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)

local PlayerStore = ProfileStore.New("PlayerStoreTesting38", PlayerDataStructure)
local Profiles: { [Player]: typeof(PlayerStore:StartSessionAsync()) } = {}

local PlayerDataController = {}

function PlayerDataController.OnStart()
	for _, player in Players:GetPlayers() do
		task.spawn(PlayerDataController.PlayerAdded, player)
	end

	Players.PlayerAdded:Connect(PlayerDataController.PlayerAdded)
	Players.PlayerRemoving:Connect(PlayerDataController.PlayerRemoving)
end

function PlayerDataController.PlayerAdded(player: Player)
	-- Start a profile session for this player's data:

	local profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	-- Handling new profile session or failure to start it:

	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from PROFILE_TEMPLATE (optional)

		profile.OnSessionEnd:Connect(function()
			Profiles[player] = nil
			player:Kick(`Profile session end - Please rejoin`)
		end)

		if player.Parent == Players then
			Profiles[player] = profile
			print(`Profile loaded for {player.DisplayName}!`)
		else
			-- The player has left before the profile session started
			profile:EndSession()
		end
	else
		-- This condition should only happen when the Roblox server is shutting down
		player:Kick(`Profile load fail - Please rejoin`)
	end
end

function PlayerDataController.PlayerRemoving(player: Player)
	local profile = Profiles[player]
	if profile ~= nil then
		profile:EndSession()
	end
end

function PlayerDataController.AwaitPlayerData(player: Player, Timeout: number?)
	local TimeoutTime = os.time() + (Timeout or 120)

	while player:IsDescendantOf(Players) and os.time() < TimeoutTime do
		local playerProfile = Profiles[player]

		if playerProfile then
			return playerProfile.Data
		end

		task.wait(0.125)
	end

	return nil
end

function PlayerDataController.GetPlayerData(player: Player)
	return Profiles[player].Data or nil
end

return PlayerDataController
