local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local janitor = Janitor.new()
local ButtonUI = ReplicatedStorage:WaitForChild("ButtonUI")
local Player = Players.LocalPlayer

function CreateUI(Name : string, Price : number, robux : boolean?) : BillboardGui

    local NewUI = ButtonUI:Clone()
    NewUI.Frame.ItemName.Text = Name
    NewUI.Frame.ItemPrice.Text = Price

    if robux then
        NewUI.Frame.ItemPrice.Text = `{Price} robux`
    end

    return NewUI

end

local ButtonUIHandler = {}

function ButtonUIHandler.OnStart()
    local timeout = 0

    repeat task.wait(.1); timeout += .1 until Player:FindFirstChild("leaderstats") or timeout > 5
    
    local leaderstats = Player:FindFirstChild("leaderstats")
    if not leaderstats then warn("player leaderstats not loaded, timed-out waiting."); return end

    local Tix : IntValue = leaderstats.Tix

    janitor:Add(Tix:GetPropertyChangedSignal("Value"):Connect(ButtonUIHandler.UpdateButtonUIs))

end

function ButtonUIHandler.UpdateButtonUIs()

    local Value = Player.leaderstats.Tix.Value
    
    local Buttons = CollectionService:GetTagged(`{Player.Team.Name}_Buttons}`)
    for _, Button in Buttons do
        
        local Price = Button:GetAttribute("Cash")
        if not Price then warn("cash value not found"); return end 

        if Value >= Price then
            
            local currentUI = Button:FindFirstChild("ButtonUI")
            if not currentUI then CreateUI(Button.Name, Price).Parent = Button; return end

            currentUI.Enabled = true

        else
            local currentUI = Button:FindFirstChild("ButtonUI")
            if not currentUI then return end 
            currentUI.Enabled = false
        end

    end

end


return ButtonUIHandler