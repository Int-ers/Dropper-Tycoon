local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local janitor = Janitor.new()
local Net = require(ReplicatedStorage.Packages.Net)
local ObjectValues = require(ReplicatedStorage.Shared.Databases.ObjectValues)
local DatabaseService = require(script.Parent.DatabaseService)
local Tycoons = Workspace:WaitForChild("Tycoons")

local SellingEvent = Net:RemoteEvent("SellingEvent")
local SellingUI = Net:RemoteEvent("Update_SellingUI")

local InventoryUpdated = Net:RemoteEvent("InventoryUpdate_Remote")

function SetCash(player, value)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local stat = leaderstats:FindFirstChild("Tix")
        if stat then
            stat.Value = value
        end
    end
end


local SellingService = {
    PlayerSellCycleDELAY = {} :: {[Player]: number}
}

function SellingService.OnStart()
    janitor:Add(SellingEvent.OnServerEvent:Connect(SellingService.AddToSellCycle))
end

function SellingService.AddToSellCycle(Player : Player)

    local function VerifyDistance() : boolean?
        if not Player or not Player.Character or not Player.Team then return end 
        local Root = Player.Character:FindFirstChild("HumanoidRootPart")
        if not Root then return end

        local PlayerTycoon = Tycoons:FindFirstChild(Player.Team.Name)
        if not PlayerTycoon then return end
        
        local SellZone = PlayerTycoon.Scriptable__:FindFirstChild("SellZone")
        if not SellZone then return end
            
        local Distance = (Root.Position - SellZone.Position).Magnitude
        if Distance > 20 then warn("Poss Exploiter"); return end
        
        return true
    end

    local PlayerData = DatabaseService.GetPlayerData(Player)
    if not PlayerData then return end 

    if not PlayerData.Gamepasses["Auto Sell"] then 
        local allow = VerifyDistance()
        if not allow then return end
    end

    if not PlayerData.PlayerSellingCache then
        PlayerData.PlayerSellingCache = {}
    end

    for name : string ,amount : number in PlayerData.PlayerInventory do
        if not PlayerData.PlayerSellingCache[name] then
            PlayerData.PlayerSellingCache[name] = amount
            PlayerData.PlayerInventory[name] = 0
            continue
        end
        PlayerData.PlayerSellingCache[name] += amount
        PlayerData.PlayerInventory[name] = nil
    end

    InventoryUpdated:FireClient(Player, PlayerData.PlayerInventory)

end

function SellingService.StartSellCycle(Player : Player)

    
    local PlayerData = DatabaseService.GetPlayerData(Player)
    if not PlayerData then return end 

    local function SellingLoop()    
        while task.wait(SellingService.PlayerSellCycleDELAY[Player]) do
            local Multiplier = 1
            if PlayerData.Gamepasses["x2 Tix"] then
                Multiplier = 2
            end
            if not PlayerData.PlayerSellingCache then continue end
            for name, amount in PlayerData.PlayerSellingCache do
                if amount == 0 then
                    PlayerData.PlayerSellingCache[name] = nil 
                    continue
                end
                
                local ObjValue = ObjectValues[name] 
                if not ObjValue then warn(`Object: {name} has no selling value!`); continue end 
                PlayerData.Tix += (ObjValue * Multiplier)
                PlayerData.PlayerSellingCache[name] -= 1
                SetCash(Player, PlayerData.Tix)
            end
            SellingUI:FireClient(Player, PlayerData.PlayerSellingCache)
        end
    end

    if not PlayerData.Gamepasses["x2 Sell Speed"] then 
        SellingService.PlayerSellCycleDELAY[Player] = 1;
    else
        SellingService.PlayerSellCycleDELAY[Player] = .5; 
    end
    janitor:Add(task.spawn(SellingLoop))
end

function SellingService:AddItemToInventory(Player : Player, ObjName) : boolean
    local PlayerData = DatabaseService.GetPlayerData(Player)
    if not PlayerData then return false end  

    if not PlayerData.PlayerInventory[ObjName] then PlayerData.PlayerInventory[ObjName] = 1; return true end
    PlayerData.PlayerInventory[ObjName] += 1
    if PlayerData.Gamepasses["Auto Sell"] then
        SellingService.AddToSellCycle(Player)
        return true
    end

    InventoryUpdated:FireClient(Player, PlayerData.PlayerInventory)

    return true
end

return SellingService