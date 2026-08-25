-- NC HUB | Loot Evo
-- Stage farm + teleport + rebirth

local Luna = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/NcMay67/Luna-Interface-Suite/master/source.lua"
))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Window = Luna:CreateWindow({
    Name = "NC HUB",
    Subtitle = "Loot Evo",
    LoadingEnabled = true,
    LoadingTitle = "NC HUB",
    LoadingSubtitle = "Stage Farm",
    KeySystem = false
})

local FarmTab = Window:CreateTab({
    Name = "Farm",
    Icon = "military_tech",
    ImageSource = "Material",
    ShowTitle = true
})

local ProgressTab = Window:CreateTab({
    Name = "Progreso",
    Icon = "trending_up",
    ImageSource = "Material",
    ShowTitle = true
})

local SystemTab = Window:CreateTab({
    Name = "Sistema",
    Icon = "settings",
    ImageSource = "Material",
    ShowTitle = true
})

local function notify(Title, Content, Icon)
    Luna:Notification({
        Title = Title,
        Content = Content,
        Icon = Icon or "warning",
        ImageSource = "Material"
    })
end

local function callRemote(Name, ...)
    local Remote = Remotes:FindFirstChild(Name)
    if not Remote then
        return false, "Remote no encontrado: " .. Name
    end

    local Args = table.pack(...)
    return pcall(function()
        if Remote:IsA("RemoteFunction") then
            return Remote:InvokeServer(table.unpack(Args, 1, Args.n))
        end

        if Remote:IsA("RemoteEvent") then
            Remote:FireServer(table.unpack(Args, 1, Args.n))
            return true
        end

        error(Name .. " no es un remote válido")
    end)
end

local function formatNumber(Value)
    Value = tonumber(Value) or 0

    if Value >= 1000000000 then
        return string.format("%.1fB", Value / 1000000000)
    elseif Value >= 1000000 then
        return string.format("%.1fM", Value / 1000000)
    elseif Value >= 1000 then
        return string.format("%.1fK", Value / 1000)
    end

    return tostring(math.floor(Value))
end

local StageConfig = require(Config:WaitForChild("StageConfig"))
local TeleportConfig = require(Config:WaitForChild("TeleportConfig"))

local Checkpoints = {}
for _, Data in ipairs(TeleportConfig) do
    Checkpoints[Data.ID] = Data
end

local Options = {}
local Stages = {}

for _, Data in ipairs(StageConfig) do
    local Number = tonumber(tostring(Data.ID):match("%d+")) or 0
    local CheckpointId = Number > 1 and ("CheckPoint" .. (Number - 1)) or nil
    local Checkpoint = CheckpointId and Checkpoints[CheckpointId] or nil
    local Requirement = Checkpoint and (formatNumber(Checkpoint.NeedVictoryPoints) .. " trofeos") or "Inicio"
    local Label = string.format("Etapa %d · %s", Number, Requirement)

    Stages[Label] = {
        StageId = Data.ID,
        CheckpointId = CheckpointId,
        TargetId = Data.SpawnMonster and Data.SpawnMonster[1] or nil,
        Number = Number
    }

    table.insert(Options, Label)
end

table.sort(Options, function(A, B)
    return Stages[A].Number < Stages[B].Number
end)

local SelectedStage = Options[1]
local AutoFarm = false
local FarmDelay = 0.35

FarmTab:CreateSection("STAGE FARM")

FarmTab:CreateDropdown({
    Name = "Etapa",
    Options = Options,
    CurrentOption = {SelectedStage},
    MultipleOptions = false,
    Flag = "LootEvo_Stage",
    Callback = function(Value)
        SelectedStage = Value
    end
})

FarmTab:CreateSlider({
    Name = "Velocidad",
    Range = {0.15, 1},
    Increment = 0.05,
    CurrentValue = FarmDelay,
    Flag = "LootEvo_FarmDelay",
    Callback = function(Value)
        FarmDelay = Value
    end
})

FarmTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "LootEvo_AutoFarm",
    Callback = function(Value)
        AutoFarm = Value == true
    end
})

FarmTab:CreateButton({
    Name = "Atacar una vez",
    Callback = function()
        local Data = Stages[SelectedStage]
        local Success, ErrorMessage = callRemote("AttackMob", Data.TargetId)

        if not Success then
            notify("Farm", tostring(ErrorMessage))
        end
    end
})

ProgressTab:CreateSection("ETAPAS")

ProgressTab:CreateButton({
    Name = "Ir a etapa",
    Description = "El juego validará tus trofeos antes de viajar",
    Callback = function()
        local Data = Stages[SelectedStage]

        if not Data.CheckpointId then
            notify("Teleport", "La Etapa 1 es el inicio.", "info")
            return
        end

        local Success, ErrorMessage = callRemote("TeleportRequest", Data.CheckpointId)

        if not Success then
            notify("Teleport", tostring(ErrorMessage))
        end
    end
})

ProgressTab:CreateSection("REBIRTH")

ProgressTab:CreateButton({
    Name = "Hacer Rebirth",
    Description = "Solo funciona al cumplir el nivel requerido",
    Callback = function()
        local Success, ErrorMessage = callRemote("RebirthRequest")

        if not Success then
            notify("Rebirth", tostring(ErrorMessage))
        end
    end
})

SystemTab:CreateButton({
    Name = "Cerrar NC HUB",
    Callback = function()
        Luna:Destroy()
    end
})

task.spawn(function()
    while task.wait(FarmDelay) do
        if AutoFarm then
            local Data = Stages[SelectedStage]
            local Success, ErrorMessage = callRemote("AttackMob", Data.TargetId)

            if not Success then
                AutoFarm = false
                notify("Auto Farm detenido", tostring(ErrorMessage))
            end
        end
    end
end)

notify("NC HUB", "Loot Evo cargado", "check_circle")
