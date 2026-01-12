local HttpService = game:GetService("HttpService")
local PhysicsService = game:GetService("PhysicsService")
-- local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DatabaseService = require(script.Parent.DatabaseService)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ObjectValues = require(ReplicatedStorage.Shared.Databases.ObjectValues)
local Tycoons = workspace:WaitForChild("Tycoons")
local FolderObjects = ReplicatedStorage:WaitForChild("Objects")
local DroppableObjects = FolderObjects:WaitForChild("DropperObjects")
local janitor = Janitor.new()

local DROPPER_DEBOUNCE_TIME = 5
local MAX_DROPPED_ITEMS = 1000

local function RandomPointInPart(part: BasePart)
    local size = part.Size
    local pos = part.Position

    -- random offset inside bounds
    local offset = Vector3.new(
        (math.random() - 0.5) * size.X,
        (math.random() - 0.5) * size.Y,
        (math.random() - 0.5) * size.Z
    )

    -- convert offset to world space using CFrame
    return part.CFrame:PointToWorldSpace(offset)
end

local TycoonDropperService = {
    PlayersDropSchedule = {} :: {[Player] : {string}}
}

function SetPlayerDropSchedule(Player : Player , PlayerData, Buttons)
    
    local DropSchedule = {}

    for _,Stage in PlayerData.BoughtButtons do   
        for _, button : BasePart in Buttons do
            local buttonStage = button:GetAttribute("Stage")
            if not buttonStage then continue end

            if buttonStage ~= Stage then continue end

            table.insert(DropSchedule, button.Name)
        end
    end

    TycoonDropperService.PlayersDropSchedule[Player] = DropSchedule
end

function TycoonDropperService.OnStart()
    


end


function TycoonDropperService.BeginDropper(Player : Player)

    local playerTeamName = Player.Team.Name
    local PlayerTycoon = Tycoons:FindFirstChild(playerTeamName)
    local PlayerData = DatabaseService.GetPlayerData(Player)
    
    local DropperPart = PlayerTycoon.Scriptable__.DropperPart
    local DroppablesFolder = PlayerTycoon:FindFirstChild("TycoonDroppables")
    local Buttons = PlayerTycoon.Scriptable__.BUTTONS:GetChildren()

    PhysicsService:RegisterCollisionGroup(`{Player.Team.Name}_DropperWalls`)
    PhysicsService:RegisterCollisionGroup(`{Player.Team.Name}_Droppables`)
    PhysicsService:CollisionGroupSetCollidable(`{Player.Team.Name}_DropperWalls`, `{Player.Team.Name}_Droppables`, true)

    local function Dropper()

        while TycoonDropperService.PlayersDropSchedule[Player] do
            local sched = TycoonDropperService.PlayersDropSchedule[Player]
            for _, Item : Model in sched do
                if not DroppableObjects:FindFirstChild(Item) then
                    continue
                end
                if #DroppablesFolder:GetChildren() >= MAX_DROPPED_ITEMS then task.wait(.1); continue end
                local ItemClone : Model = DroppableObjects[Item]:Clone()
                if not ItemClone or not ItemClone.PrimaryPart then return end
                ItemClone:PivotTo(CFrame.new(RandomPointInPart(DropperPart)))
                ItemClone.Parent = DroppablesFolder

                ItemClone:SetAttribute("Server", true)
                ItemClone:SetAttribute("ItemId", HttpService:GenerateGUID(false))
                ItemClone.PrimaryPart.Anchored = true
                ItemClone.PrimaryPart.CanCollide = false
                ItemClone.PrimaryPart.Transparency = 1

                
                -- CollectionService:AddTag(ItemClone, `{playerTeamName}_DroppedAssets`)
                ItemClone:AddTag(`{playerTeamName}_DroppedAssets`)
                if ObjectValues[ItemClone.Name] then
                    ItemClone:SetAttribute("Value" , ObjectValues[ItemClone.Name])
                end
                ItemClone.PrimaryPart.CollisionGroup = `{playerTeamName}_DroppedAssets`

                task.wait(.125)
            end
            task.wait(DROPPER_DEBOUNCE_TIME)
        end
    end

    SetPlayerDropSchedule(Player, PlayerData, Buttons)
    janitor:Add(task.spawn(Dropper))

    -- PhysicsService:UnregisterCollisionGroup(`{playerTeamName}_DropperWalls`)
    -- PhysicsService:UnregisterCollisionGroup(`{playerTeamName}_DroppedAssets`)
end



return TycoonDropperService