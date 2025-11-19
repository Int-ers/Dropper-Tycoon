local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Tycoons = Workspace:FindFirstChild("Tycoons")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local janitor = Janitor.new()
local Net = require(ReplicatedStorage.Packages.Net)

local SellingEvent = Net:RemoteEvent("SellingEvent")
local SellingUI = Net:RemoteEvent("Update_SellingUI")

local PlayerTycoon
local Sellzone : BasePart
local UI
local Template : TextLabel
local HoldingFrame

local SellZoneController = {}

function SellZoneController.OnStart()
    
    janitor:Add(SellingUI.OnClientEvent:Connect(SellZoneController.UpdateUI))

    repeat task.wait(1) until Tycoons:FindFirstChild(Player.Team.Name)

    PlayerTycoon = Tycoons[Player.Team.Name]
    Sellzone = PlayerTycoon.Scriptable__:WaitForChild("SellZone")
    UI = Sellzone:WaitForChild("Gui")
    
    Template = UI.template
    HoldingFrame = UI.HoldingFrame

    janitor:Add(Sellzone.Touched:Connect(function(hit)
        local Player = Players:GetPlayerFromCharacter(hit.Parent)
        if not Player then return end 
        
        SellingEvent:FireServer()
    end))
end

function SellZoneController.UpdateUI(SellCycle : {[string] : number}) 

    for _, item in HoldingFrame:GetChildren() do
        if not item:IsA("UIListLayout") then
            item:Destroy()
        end
    end
    local isSome = false
    for name, amount in SellCycle do
        if amount == 0 then continue end
        isSome = true
        local clone = Template:Clone()
        clone.Text = `{name} x{amount}`
        clone.Parent = HoldingFrame
        clone.Visible = true
    end
    UI.Enabled = isSome

end


return SellZoneController