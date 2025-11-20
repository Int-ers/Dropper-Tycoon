local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Net = require(ReplicatedStorage.Packages.Net)
local numberformatutil = require(ReplicatedStorage.Packages.numberformatutil)
local janitor = Janitor.new()
local ButtonUI = ReplicatedStorage:WaitForChild("ButtonUI")
local Player = Players.LocalPlayer

local RemoveUIEvent = Net:RemoteEvent("RemoveUI_Event")

local AFFORDABLE_COLOR = Color3.new(0.313725, 0.992157, 0)
local NOT_AFFORDABLE_COLOR = Color3.new(0.941176, 0.027451, 0.027451)


function CreateUI(Name : string, Price : number, robux : boolean?) : BillboardGui

    local NewUI = ButtonUI:Clone()
    NewUI.Frame.ItemName.Text = Name
    NewUI.Frame.ItemPrice.Text = numberformatutil.suffix(Price)

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

    janitor:Add(Tix.Changed:Connect(ButtonUIHandler.UpdateButtonUIs))
    janitor:Add(RemoveUIEvent.OnClientEvent:Connect(ButtonUIHandler.RemoveUI))
    
    repeat task.wait(.5) until #CollectionService:GetTagged(`{Player.Team.Name}_Buttons`) == 112
    ButtonUIHandler.UpdateButtonUIs()

end

function ButtonUIHandler.UpdateButtonUIs()
    local Buttons = CollectionService:GetTagged(`{Player.Team.Name}_Buttons`)

    for _, Button in Buttons do
        local Value = Player.leaderstats.Tix.Value
        if Button.Transparency == 1 then
            local currentUI = Button:FindFirstChild("ButtonUI")
            if currentUI then currentUI:Destroy(); continue end
        end
        
        local Price = Button:GetAttribute("Cash")
        if not Price then warn("cash value not found"); continue end 

        local currentUI = Button:FindFirstChild("ButtonUI")
        if not currentUI then
            if Button.Transparency == 1 then continue end
            currentUI = CreateUI(Button.Name, Price);
            currentUI.Parent = Button
            currentUI.Adornee = Button
        end

        if Value >= Price then
            currentUI.Frame.ItemPrice.BackgroundColor = BrickColor.new(AFFORDABLE_COLOR)
        else
            currentUI.Frame.ItemPrice.BackgroundColor = BrickColor.new(NOT_AFFORDABLE_COLOR)
        end

    end

end

function ButtonUIHandler.RemoveUI(Button)
    if not Button then return end  
    local UI = Button:FindFirstChild("ButtonUI")
    if UI then UI:Destroy(); return end
end
return ButtonUIHandler