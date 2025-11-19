local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Net = require(ReplicatedStorage.Packages.Net)
local janitor = Janitor.new()

local TouchedEvent = Net:RemoteEvent("DroppedPartTouchEvent")

local DroppedTouchController = {}

function DroppedTouchController.OnStart()
    task.wait(3)
    for _, team in Teams:GetChildren() do
        janitor:Add(CollectionService:GetInstanceAddedSignal(`{team.Name}_DroppedAssets`):Connect(DroppedTouchController.ObjectTagAdded))


        local DroppedParts = CollectionService:GetTagged(`{team.Name}_DroppedAssets`)
        
        for _, part : Model in DroppedParts do
            if not part or not part.PrimaryPart then
                continue
            end
            janitor:Add(part.PrimaryPart.Touched:Connect(function(hit)
                DroppedTouchController.PartTouched(part, hit)
            end))
        end

    end
end

function DroppedTouchController.ObjectTagAdded(Obj : Model)
    if not Obj or not Obj.PrimaryPart then
        return
    end
    janitor:Add(Obj.PrimaryPart.Touched:Connect(function(hit)
        DroppedTouchController.PartTouched(Obj, hit)
    end))
end

function DroppedTouchController.PartTouched(Obj : Model, TouchedPart : BasePart)

    if not TouchedPart or not Obj then
        return
    end
    
    local Player : Player = Players:GetPlayerFromCharacter(TouchedPart.Parent)
    if not Player then
        return
    end

    TouchedEvent:FireServer(Obj)

end




return DroppedTouchController