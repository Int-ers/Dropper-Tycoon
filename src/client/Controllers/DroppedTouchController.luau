local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ClientDuplicates = Workspace:WaitForChild("ClientDuplicates")
local ClientObjects = ReplicatedStorage:WaitForChild("Objects")
local Objects = ClientObjects:WaitForChild("DropperObjects")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Net = require(ReplicatedStorage.Packages.Net)
local ClientAudioBridge = require(ReplicatedStorage["Main Client"].Bridges.ClientAudioBridge)
local janitor = Janitor.new()

local ItemCache = {


} :: {[string] : Model}


local TouchedEvent = Net:RemoteEvent("DroppedPartTouchEvent")

function CreateDuplicate(Name, ID, Position : CFrame) : Model?

    if not ItemCache[Name] then
        local Obj : Model = Objects:FindFirstChild(Name)
        if not Obj then warn(`No item found: {Name}`); return end
        repeat task.wait(.1) until Obj.PrimaryPart 

        ItemCache[Name] = Obj
    end
    
    local Clone = ItemCache[Name]:Clone()
    Clone.Parent = ClientDuplicates
    Clone:SetAttribute("ItemId", ID)
    Clone:SetAttribute("Client", true)

    Clone.PrimaryPart:PivotTo(Position)

    return Clone

end

local DroppedTouchController = {}

function DroppedTouchController.OnStart()

    local spawntimeout = 0

    repeat task.wait(.1) until Player.Team ~= nil
    janitor:Add(CollectionService:GetInstanceAddedSignal(`{Player.Team.Name}_DroppedAssets`):Connect(DroppedTouchController.ObjectTagAdded))

    repeat task.wait(.1); spawntimeout += 0.1; until #CollectionService:GetTagged(`{Player.Team.Name}_DroppedAssets`) > 0 or spawntimeout > 5
    local DroppedParts = CollectionService:GetTagged(`{Player.Team.Name}_DroppedAssets`)
    
    for _, part : Model in DroppedParts do
        local timeout = 0
        repeat task.wait(.1); timeout += .1; until part.PrimaryPart or timeout > 5
        if not part.PrimaryPart then
            print("no primary part, timed out.")
            continue
        end

        local ClientPart = CreateDuplicate(part.Name, part:GetAttribute("ItemId"), part.PrimaryPart.CFrame)
        if not ClientPart then return end

        janitor:Add(ClientPart.PrimaryPart.Touched:Connect(function(hit)
            DroppedTouchController.PartTouched(ClientPart, hit)
        end))
    end

end

function DroppedTouchController.ObjectTagAdded(Obj : Model)
    if not Obj or not Obj.PrimaryPart then
        return
    end
    local ClientPart = CreateDuplicate(Obj.Name, Obj:GetAttribute("ItemId"), Obj.PrimaryPart.CFrame)
    if not ClientPart then return end

    janitor:Add(ClientPart.PrimaryPart.Touched:Connect(function(hit)
        DroppedTouchController.PartTouched(ClientPart, hit)
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
    
    TouchedEvent:FireServer(Obj:GetAttribute("ItemId"))
    Debris:AddItem(Obj, 0)
    ClientAudioBridge:PlayAudio("Pop")

end




return DroppedTouchController