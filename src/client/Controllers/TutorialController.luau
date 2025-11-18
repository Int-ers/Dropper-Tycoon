local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local Player = Players.LocalPlayer

local TutorialRemote = Net:RemoteEvent("Initiate_Tutorial")

local TutorialController = {}

function CreateBeam(Part1, Part2)
    local Beam = Instance.new("Beam")
    local Attachment1 = Instance.new("Attachment")
    local Attachment2 = Instance.new("Attachment")
    Beam.TextureMode = Enum.TextureMode.Wrap
    Beam.TextureSpeed = 2
    Beam.Width0 = 5
    Beam.Texture = "rbxassetid://70350474"

    Beam.Parent = workspace
    Attachment1.Parent = Part1
    Attachment2.Parent = Part2
    Beam.Attachment0 = Attachment2
    Beam.Attachment1 = Attachment1

    return Beam, Attachment1, Attachment2
end

function TutorialController.OnStart()
    TutorialRemote.OnClientEvent:Connect(TutorialController.StartTutorial)
end

function TutorialController.StartTutorial()
    wait(3)
    if not Player.Team then return end
    if not Player.Character then return end 

    local function Stage1()
        local Buttons = CollectionService:GetTagged(`{Player.Team.Name}_Buttons`)
        for _, Button in Buttons do
            if Button:GetAttribute("Stage") == 1 then
                CreateBeam(Player.Character.HumanoidRootPart, Button)
                break
            end
        end
        
        -- while true do
        --     wait(.1)



        -- end


        return true
    end

    Stage1()
end

return TutorialController