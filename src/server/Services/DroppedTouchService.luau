local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local SellingService = require(script.Parent.SellingService)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local janitor = Janitor.new()
local Tycoons = Workspace:WaitForChild("Tycoons")
local Net = require(ReplicatedStorage.Packages.Net)


local TouchedEvent = Net:RemoteEvent("DroppedPartTouchEvent")


local DroppedTouchService = {}

function DroppedTouchService.OnStart()
    
    janitor:Add(TouchedEvent.OnServerEvent:Connect(DroppedTouchService.PartTouched))

end

function DroppedTouchService.PartTouched(Player : Player, ItemId : string) 
    if not Player or not Player.Team then return end
    local PlayerTycoon = Tycoons:FindFirstChild(Player.Team.Name)
    if not PlayerTycoon then return end

    local TycoonDroppablesFolder = PlayerTycoon.TycoonDroppables
    if not TycoonDroppablesFolder then return end

    for _, part : Model in TycoonDroppablesFolder:GetChildren() do
        if part:GetAttribute("ItemId") == ItemId then
            local Success = SellingService:AddItemToInventory(Player , part.Name)
            if Success then Debris:AddItem(part, 0); return end
        end
    end

end


return DroppedTouchService