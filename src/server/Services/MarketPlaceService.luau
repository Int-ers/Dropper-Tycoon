local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local MarketPlaceDB = require(ReplicatedStorage.Shared.Databases.MarketPlaceDB)
local janitor = Janitor.new()
local DatabaseService = require(script.Parent.DatabaseService)


function CheckOwnership(Player : Player , GPID : number)
    local owns

    for i = 1 , 3 do 
        local success, error = pcall(function()
            owns = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GPID)
        end)

        if success then
            break
        end

        warn(`Attempt {i}: {error}`)
    end

    return owns
end

local MarketPlaceService = {}

function MarketPlaceService.OnStart()

    janitor:Add(Players.PlayerAdded:Connect(MarketPlaceService.CheckOwnedProducts))
    janitor:Add(MarketplaceService.PromptGamePassPurchaseFinished:Connect(MarketPlaceService.ProductPurchased))

end

function MarketPlaceService.CheckOwnedProducts(Player : Player)
    
    local PlayerData = DatabaseService.AwaitPlayerData(Player)
    if not PlayerData then return end 

    for ProductName, ProductID in MarketPlaceDB.Gamepass_GPIDs do

        if PlayerData.Gamepasses[ProductName] and PlayerData.Gamepasses[ProductName] == true then continue end
        
        local owns = CheckOwnership(Player, ProductID)
        if owns then
            PlayerData.Gamepasses[ProductName] = true
        end

    end
end

function MarketPlaceService.ProductPurchased(Player : Player, GPID : number, bought : boolean)

    print("ran here!")
    print(bought)

    local PlayerData = DatabaseService.GetPlayerData(Player)
    if not bought then warn("not boight"); return end

    local owns = CheckOwnership(Player, GPID)

    if not owns then return end
    
    local GamepassInformation = MarketplaceService:GetProductInfo(GPID, Enum.InfoType.GamePass)
    if not GamepassInformation then return end 
    print("past gamepass info")

    PlayerData.Gamepasses[GamepassInformation.Name] = true
    print("set player data true!")

end 


return MarketPlaceService