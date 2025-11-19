local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ClientAudiosFolder = Workspace:WaitForChild("ClientAudios")
local AudiosDB = require(ReplicatedStorage.Shared.Databases.AudiosDB)

function CreateAudio(Name, ID) : Sound
    local Sound = Instance.new("Sound")
    Sound.Name = Name
    Sound.SoundId = ID
    Sound.Parent = ClientAudiosFolder
    Sound:Stop()

    return Sound
end


local ClientAudioBridge = {
    AudioCache = {} :: {[string] : Sound},
    Muted = false
}

function ClientAudioBridge.OnStart()

    ClientAudioBridge.BackgroundMusic()

end

function ClientAudioBridge:PlayAudio(Name)
    if not ClientAudioBridge.AudioCache[Name] then
        if not AudiosDB.ClientAudios[Name] then warn("Audio doesn't exist"); return end 

        local audio = CreateAudio(Name, AudiosDB.ClientAudios[Name])
        ClientAudioBridge.AudioCache[Name] = audio
    end
    ClientAudioBridge.AudioCache[Name]:Play()
end

function ClientAudioBridge.BackgroundMusic()
    
    local function StartPlaylist()
        while not ClientAudioBridge.Muted do
            for Name, ID in AudiosDB.BackgroundMusic do
                
                if not ClientAudioBridge.AudioCache[Name] then
                    local audio = CreateAudio(Name, ID)
                    ClientAudioBridge.AudioCache[Name] = audio
                end
                local audio = ClientAudioBridge.AudioCache[Name]

                audio:Play()
                repeat task.wait(1) until audio.Playing == false             
            end
        end
    end
    task.spawn(StartPlaylist)
end


return ClientAudioBridge