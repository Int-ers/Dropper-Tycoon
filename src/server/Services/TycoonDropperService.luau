local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DatabaseService = require(script.Parent.DatabaseService)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ObjectValues = require(ReplicatedStorage.Shared.Databases.ObjectValues)
local Tycoons = workspace:WaitForChild("Tycoons")
local FolderObjects = ReplicatedStorage:WaitForChild("Objects")
local DroppableObjects = FolderObjects:WaitForChild("DropperObjects")
local janitor = Janitor.new()

local DROPPER_DEBOUNCE_TIME = 5



local TycoonDropperService = {
    PlayersDropSchedule = {} :: {[Player] : {string}}
}

function SetPlayerDropSchedule(Player : Player , PlayerData, Buttons)
    
    local DropSchedule = {"Silver Tetramino of Accomplishment"}

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
    local DropperWalls = PlayerTycoon.Scriptable__:FindFirstChild("DropperWalls")
    local Buttons = PlayerTycoon.Scriptable__.BUTTONS:GetChildren()

    PhysicsService:RegisterCollisionGroup(`{playerTeamName}_DropperWalls`)
    PhysicsService:RegisterCollisionGroup(`{playerTeamName}_DroppedAssets`)
    for _,part : BasePart in DropperWalls:GetChildren() do
        part.CollisionGroup = `{playerTeamName}_DropperWalls`
    end

    PhysicsService:CollisionGroupSetCollidable(`{playerTeamName}_DropperWalls`, `{playerTeamName}_DroppedAssets`, true)

    local function Dropper()



        while TycoonDropperService.PlayersDropSchedule[Player] do
            local sched = TycoonDropperService.PlayersDropSchedule[Player]
            for _, Item : Model in sched do
                
                if not DroppableObjects:FindFirstChild(Item) then
                    continue
                end
                local ItemClone : Model = DroppableObjects[Item]:Clone()
                if not ItemClone or not ItemClone.PrimaryPart then return end
                ItemClone:PivotTo(DropperPart.CFrame)
                ItemClone.Parent = DroppablesFolder
                
                -- CollectionService:AddTag(ItemClone, `{playerTeamName}_DroppedAssets`)
                ItemClone:AddTag(`{playerTeamName}_DroppedAssets`)
                if ObjectValues[ItemClone.Name] then
                    ItemClone:SetAttribute("Value" , ObjectValues[ItemClone.Name])
                end
                ItemClone.PrimaryPart.CollisionGroup = `{playerTeamName}_DroppedAssets`
            end
            task.wait(DROPPER_DEBOUNCE_TIME)
        end
    end

    SetPlayerDropSchedule(Player, PlayerData, Buttons)
    task.spawn(Dropper)

    PhysicsService:UnregisterCollisionGroup(`{playerTeamName}_DropperWalls`)
    PhysicsService:UnregisterCollisionGroup(`{playerTeamName}_DroppedAssets`)
end



return TycoonDropperService