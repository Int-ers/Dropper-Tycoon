local Players = game:GetService("Players")
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

local SellingService = {
    PlayerSellingCache = {} :: {[Player] : {[string] : number}},
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

        local PlayerTycoon = Tycoons:FindFirstChild(Player.Team)
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

    for name : string ,amount : number in PlayerData.PlayerSellingInventory do
        if SellingService.PlayerSellingCache[Player][name] then
            local leftOver = (amount - SellingService.PlayerSellingCache[Player][name])
            print(leftOver)
            if leftOver <= 0 then return end
            SellingService.PlayerSellingCache[Player][name] += leftOver
        else
            SellingService.PlayerSellingCache[Player][name] = amount
        end
    end
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

            for name, amount in SellingService.PlayerSellingCache[Player] do
                if amount == 0 then
                    SellingService.PlayerSellingCache[Player][name] = nil 
                    continue
                end
                
                local ObjValue = ObjectValues[name] 
                if not ObjValue then warn("Object has no selling value!"); return end 
                PlayerData.Tix += (ObjValue * Multiplier)
                SellingService.PlayerSellingCache[Player][name] -= 1
                PlayerData.PlayerSellingInventory[name] -= 1
            end
            SellingUI:FireClient(Player)
        end
    end

    if not PlayerData.Gamepasses["x2 Sell Speed"] then 
        SellingService.PlayerSellCycleDELAY[Player] = 1;
    else
        SellingService.PlayerSellCycleDELAY[Player] = .5; 
    end
    SellingLoop()
end

function SellingService:AddItemToSellInventory(Player : Player, ObjName) : boolean
    local PlayerData = DatabaseService.GetPlayerData(Player)
    if not PlayerData then return false end  

    if not PlayerData.PlayerSellingInventory[ObjName] then PlayerData.PlayerSellingInventory[ObjName] = 1; return true end
    PlayerData.PlayerSellingInventory[ObjName] += 1
    if PlayerData.Gamepasses["Auto Sell"] then
        SellingService.AddToSellCycle(Player)
    end
    return true
end

return SellingService