local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SellingService = require(script.Parent.SellingService)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local janitor = Janitor.new()
local Net = require(ReplicatedStorage.Packages.Net)


local TouchedEvent = Net:RemoteEvent("DroppedPartTouchEvent")


local DroppedTouchService = {}

function DroppedTouchService.OnStart()
    
    janitor:Add(TouchedEvent.OnServerEvent:Connect(DroppedTouchService.PartTouched))

end

function DroppedTouchService.PartTouched(Player : Player, Obj : Model)
    
    if not Player or not Player.Character then return end 
    if not Obj or not Obj.PrimaryPart then return end
    local HumanoidRoot = Player.Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRoot then return end

    local Distance = (HumanoidRoot.Position - Obj.PrimaryPart.Position).Magnitude
    if Distance > 10 then warn("Poss exploiter"); return end

    local Success = SellingService:AddItemToSellInventory(Player , Obj.Name)
    if Success then Obj:Destroy(); return end
    return
end


return DroppedTouchService