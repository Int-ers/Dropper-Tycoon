local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Teams = game:GetService("Teams")
local Net = require(ReplicatedStorage.Packages.Net)
local DatabaseService = require(ServerScriptService["Main Server"].Services.DatabaseService)
local SellingService = require(ServerScriptService["Main Server"].Services.SellingService)
local TycoonDropperService = require(ServerScriptService["Main Server"].Services.TycoonDropperService)

local TutorialRemote = Net:RemoteEvent("Initiate_Tutorial")
local TutorialCompletion = Net:RemoteEvent("Completed_Tutorial")

local PlayerJoinController = {}

function GetAvailableTeam()
    local Spawns = CollectionService:GetTagged("Spawn")
    for _,spawnBlock in Spawns do
        if not spawnBlock:GetAttribute("Claimed") then
            return spawnBlock
        end
    end
    return false
end

function CreateLeaderstats(Player : Player, Data : {Cash: number, Rebirths: number, BoughtButtons: {number}})
    
    local Folder = Instance.new("Folder")
    Folder.Name = "leaderstats"

    local CashValue = Instance.new("IntValue")
    CashValue.Name = "Tix"
    CashValue.Value = Data.Cash

    local RebirthsValue = Instance.new("IntValue")
    RebirthsValue.Name = "Rebirths"
    RebirthsValue.Value = Data.Rebirths

    CashValue.Parent = Folder
    RebirthsValue.Parent = Folder
    Folder.Parent = Player

end

function PlayerJoinController.OnStart()
    Players.PlayerAdded:Connect(PlayerJoinController.PlayerJoined)
    TutorialCompletion.OnServerEvent:Connect(PlayerJoinController.CompletedTutorial)
end

function PlayerJoinController.PlayerJoined(Player : Player)
    
    local AvailTeam = GetAvailableTeam()
    if not AvailTeam then
        warn("no team??!")
        Player:Kick("No teams available, please join a new server! Sorry for the inconvenience.")
        return
    end

    local Team = Teams:FindFirstChild(AvailTeam.Name)
    Player.Team = Team

    AvailTeam:SetAttribute("Claimed", true)

    local Buttons = CollectionService:GetTagged(`{AvailTeam.Name}_Buttons`)
    local PlayerData = DatabaseService.AwaitPlayerData(Player, 10)
    local PlotOwner = AvailTeam.Parent:FindFirstChild("PlotOwner")

    if not PlotOwner or not PlotOwner:FindFirstChild("BillboardGui") then
        print("cant find ")
        return
    end

    PlotOwner.BillboardGui.TextLabel.Text = `{Player.Name}'s Plot`

    if not PlayerData then
        Player:Kick("Some error with your data, please rejoin!")
        return
    end

    CreateLeaderstats(Player, PlayerData)
    Player:LoadCharacter()
    if PlayerData.newPlayer then
        TutorialRemote:FireClient(Player)
    end

    if not PlayerData.BoughtButtons then 
        TycoonDropperService.BeginDropper(Player)
        return 
    end
    for _,Stage in PlayerData.BoughtButtons do
        for _, button : BasePart in Buttons do
            local buttonStage = button:GetAttribute("Stage")
            if not buttonStage then continue end

            if buttonStage ~= Stage then continue end

            button.Transparency = 1
            button.CanTouch = false
        end
    end
    TycoonDropperService.BeginDropper(Player)
    SellingService.StartSellCycle(Player)
end

function PlayerJoinController.CompletedTutorial(Player : Player)
    local PlayerData = DatabaseService.GetPlayerData(Player)
    if not PlayerData then
        warn(`Error getting {Player.Name}'s data`)
        return
    end

    PlayerData.newPlayer = false
end

return PlayerJoinController