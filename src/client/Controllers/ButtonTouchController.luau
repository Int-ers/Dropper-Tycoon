local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Net = require(ReplicatedStorage.Packages.Net)
local janitor = Janitor.new()
local Player = Players.LocalPlayer

local TouchedButtonEvent = Net:RemoteEvent("Button_Touched_Remote")

local ButtonTouchController = {}

function ButtonTouchController.OnStart()

    repeat task.wait(.1); print("waiting!"); print(Player.Team) until Player.Team ~= nil 

    local CurrentlyTagged = CollectionService:GetTagged(`{Player.Team.Name}_Buttons`)
    for _, button in CurrentlyTagged do
        janitor:Add(button.Touched:Connect(ButtonTouchController.Touched))
    end

    CollectionService:GetInstanceAddedSignal(`{Player.Team.Name}_Buttons`):Connect(ButtonTouchController.ObjectAdded)
        


end

function ButtonTouchController.ObjectAdded(Obj : BasePart)
    if not Obj then return end

    janitor:Add(Obj.Touched:Connect(function(hit)
        ButtonTouchController.Touched(Obj , hit)
    end))

end

function ButtonTouchController.Touched(Object : BasePart, hit : BasePart)
    
    if not Object or not hit then return end 

    local Player : Player = Players:GetPlayerFromCharacter(hit.Parent)
    if not Player then return end

    TouchedButtonEvent:FireServer(Object)
end




return ButtonTouchController