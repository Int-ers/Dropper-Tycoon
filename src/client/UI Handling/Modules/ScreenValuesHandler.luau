local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local janitor = Janitor.new()
local Net = require(ReplicatedStorage.Packages.Net)
local numberformatutil = require(ReplicatedStorage.Packages.numberformatutil)
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui


local InventoryUpdated = Net:RemoteEvent("InventoryUpdate_Remote")

local ScreenValuesHandler = {}


function ScreenValuesHandler.OnStart()

    local timeout = 0
    local timeout1 = 0
    
    local Currencies = PlayerGui:FindFirstChild("Currencies")
    repeat task.wait(1); Currencies = PlayerGui:FindFirstChild("Currencies"); timeout += 1 until Currencies or timeout > 5

    local leaderstats = Player:FindFirstChild("leaderstats")
    repeat task.wait(1); leaderstats = Player:FindFirstChild("leaderstats"); timeout1 += 1 until Currencies or timeout1 > 5
    
    janitor:Add(InventoryUpdated.OnClientEvent:Connect(function(InventoryData)
        local UI = Currencies.CollectedItems
        local total = 0

        for _, amount in InventoryData do 
            total += amount
        end
        
        UI.TextLabel.Text = total
    end))

    janitor:Add(leaderstats.Tix.Changed:Connect(function()
        local UI = Currencies.Money
        local Tix = leaderstats.Tix

        UI.Tix.Text = numberformatutil.suffix(Tix.Value)
    end))





    local UI = Currencies.Money
    local Tix = leaderstats.Tix
    UI.Tix.Text = numberformatutil.suffix(Tix.Value)
end



return ScreenValuesHandler