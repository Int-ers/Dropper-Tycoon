local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DatabaseService = require(script.Parent.DatabaseService)
local TycoonDropperService = require(script.Parent.TycoonDropperService)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Net = require(ReplicatedStorage.Packages.Net)
local janitor = Janitor.new()

local TouchedButtonEvent = Net:RemoteEvent("Button_Touched_Remote")

local ButtonTouchService = {}

function ButtonTouchService.OnStart()
    
    TouchedButtonEvent.OnServerEvent:Connect(ButtonTouchService.ButtonTouched)

end

function ButtonTouchService.ButtonTouched(Player : Player, TouchedButton : BasePart)
    
    if not Player or not TouchedButton then return end
    local char = Player.Character
    if not char or not char.HumanoidRootPart then return end

    local Distance = (char.HumanoidRootPart.Position - TouchedButton.Position).Magnitude
    if Distance > 10 then warn('Exploiter likely but idc'); return end

    local Price = TouchedButton:GetAttribute("Cash")
    local Stage = TouchedButton:GetAttribute("Stage")
    if not Price or not Stage then return end
    local PlayerData = DatabaseService.GetPlayerData(Player)
    
    if PlayerData.Tix >= Price then
        PlayerData.Tix -= Price
        table.insert(PlayerData.BoughtButtons, Stage)
        table.insert(TycoonDropperService.PlayersDropSchedule[Player] , TouchedButton.Name)
        TouchedButton.Transparency = 1
        TouchedButton.CanTouch = false
        for _, objects in TouchedButton:GetChildren() do
            objects:Destroy()
        end
    end

end



return ButtonTouchService