local Debris = game:GetService("Debris")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Tycoons = Workspace:WaitForChild("Tycoons")
local ButtonUI = ReplicatedStorage:WaitForChild("ButtonUI")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local MarketPlaceDB = require(ReplicatedStorage.Shared.Databases.MarketPlaceDB)
local janitor = Janitor.new()
local Player = Players.LocalPlayer


function GetGamepassDetails(GPID)
    if GPID == 0 then return end

    local GPIDAssetData

    local success, error = pcall(function()
        GPIDAssetData = MarketplaceService:GetProductInfo(GPID, Enum.InfoType.GamePass)
    end)

    if not success then warn(error); return end

    local IsForSale = GPIDAssetData.IsForSale or false
    local Price = GPIDAssetData.PriceInRobux

    return IsForSale , Price
end

local GamepassPadsController = {}

function GamepassPadsController.OnStart()
    
    repeat task.wait(.1); until Player.Team ~= nil
    local PlayerTycoon = Tycoons:FindFirstChild(Player.Team.Name)
    repeat task.wait(1); PlayerTycoon = Tycoons:FindFirstChild(Player.Team.Name); until PlayerTycoon

    local Products : Model = PlayerTycoon.Scriptable__.Products
    if not Products then warn(`Cannot find products model for: {Player.Name} on team {Player.Team.Name}`); return end
    repeat task.wait(.1) until #Products:GetChildren() > 8
    
    for _, ProductPad in Products:GetChildren() do
        local GPID = MarketPlaceDB.Gamepass_GPIDs[ProductPad.Name]
        if not GPID then warn(`No GPID for gamepass: {ProductPad.Name} ({GPID})`); continue end

        local IsForSale , Price = GetGamepassDetails(GPID)

        if not IsForSale then Debris:AddItem(ProductPad, 0); continue end
        local UI = ButtonUI:Clone()
        if not UI.Frame or not UI.Frame.ItemPrice or not UI.Frame.ItemName then warn("missing parts of UI"); return end
        UI.Frame.ItemPrice.Text = `{Price} Robux`
        UI.Frame.ItemName.Text = ProductPad.Name
        UI.Parent = ProductPad
        UI.Adornee = ProductPad

        janitor:Add(ProductPad.Touched:Connect(function(hit)
            GamepassPadsController:PadTouched(ProductPad, hit)
        end))
    end
end

function GamepassPadsController:PadTouched(Button : BasePart , hit : BasePart)

    if not hit or not hit.Parent or not Button then return end
    
    if not hit.Parent:FindFirstChild("Humanoid") then return end

    local GPID = MarketPlaceDB.Gamepass_GPIDs[Button.Name]
    if not GPID then return end 

    MarketplaceService:PromptGamePassPurchase(Player, GPID)
end





return GamepassPadsController