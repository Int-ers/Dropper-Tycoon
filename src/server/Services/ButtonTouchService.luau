local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DatabaseService = require(script.Parent.DatabaseService)
local TycoonDropperService = require(script.Parent.TycoonDropperService)
local Net = require(ReplicatedStorage.Packages.Net)

local TouchedButtonEvent = Net:RemoteEvent("Button_Touched_Remote")
local SoundEvent = Net:RemoteEvent("Sound_Event")
local RemoveUIEvent = Net:RemoteEvent("RemoveUI_Event")

function SetCash(player, value)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local stat = leaderstats:FindFirstChild("Tix")
        if stat then
            stat.Value = value
        end
    end
end

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
        SoundEvent:FireClient(Player, "Bought")
        RemoveUIEvent:FireClient(Player, TouchedButton)
        TouchedButton.CanTouch = false
        for _, objects in TouchedButton:GetChildren() do
            Debris:AddItem(objects, 0)
        end
        SetCash(Player, PlayerData.Tix)
    end

end



return ButtonTouchService