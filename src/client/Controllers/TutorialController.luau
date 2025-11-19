local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local janitor = Janitor.new()
local Net = require(ReplicatedStorage.Packages.Net)
local Player = Players.LocalPlayer
local Tycoons = Workspace:WaitForChild("Tycoons")
local TutorialRemote = Net:RemoteEvent("Initiate_Tutorial")
local TutorialCompletion = Net:RemoteEvent("Completed_Tutorial")

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

    return {Beam, Attachment1, Attachment2}
end

function TutorialController.OnStart()
    TutorialRemote.OnClientEvent:Connect(TutorialController.StartTutorial)
end

function TutorialController.StartTutorial()
    task.wait(3)
    if not Player.Team then return end
    if not Player.Character then return end 

    local function Stage1()
        local Buttons = CollectionService:GetTagged(`{Player.Team.Name}_Buttons`)
        local THEbutton : BasePart? = nil
        local BeamStuff
        for _, Button in Buttons do
            if Button:GetAttribute("Stage") == 1 then
                BeamStuff = CreateBeam(Player.Character.HumanoidRootPart, Button)
                THEbutton = Button
                break
            end
        end
        
        while true do
            wait(1)
            if not THEbutton then break end
            if THEbutton.Transparency == 1 then for _,x in BeamStuff do x:Destroy() end; break end
        end
        return true
    end

    local function Stage2()
        local PlayersTeamFolder = Tycoons:FindFirstChild(Player.Team.Name)
        local DropperWall = PlayersTeamFolder.Scriptable__.DropperWalls.PrimaryPart
        if not DropperWall then return end

        local beamStuff
        local selectedDroppable
        local TycoonDroppables = PlayersTeamFolder:FindFirstChild("TycoonDroppables")
        for _, part : Model in TycoonDroppables:GetChildren() do
            beamStuff = CreateBeam(Player.Character.HumanoidRootPart, part.PrimaryPart)
            selectedDroppable = part
            break
        end
        local running = true
        janitor:Add(selectedDroppable.PrimaryPart.Touched:Connect(function(hit)
            if hit.parent:FindFirstChild("Humanoid") then
                running = false
            end
        end))
        while running do
            wait(1)
        end
        for _, item in beamStuff do
            item:Destroy()
        end
    end

    local function Stage3()
        local PlayerTycoon = Tycoons:FindFirstChild(Player.Team.Name)
        if not PlayerTycoon then return end 
        local Root = Player.Character:FindFirstChild("HumanoidRootPart")
        if not Root then return end

        local sellZone : BasePart = PlayerTycoon.Scriptable__:FindFirstChild("SellZone")
        if not sellZone then return end

        local running = true
        janitor:Add(sellZone.Touched:Connect(function(hit)
            if hit.Parent:FindFirstChild("Humanoid") then
                running = false
            end
        end))

        local beamStuff = CreateBeam(Root, sellZone)
        while running do
            wait(1)
        end
        for _, item in beamStuff do
            item:Destroy()
        end

    end
    Stage1()
    Stage2()
    Stage3()

    TutorialCompletion:FireServer()
end

return TutorialController