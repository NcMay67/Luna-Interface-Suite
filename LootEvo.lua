-- NC HUB | Loot Evo
-- PlaceId: 96033388567901

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
    LoadingSubtitle = "Loot Evo",
    KeySystem = false
})

local CombatTab = Window:CreateTab({
    Name = "Combate",
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

local TravelTab = Window:CreateTab({
    Name = "Viaje",
    Icon = "map",
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
        Icon = Icon or "info",
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

local function makeOptions(ConfigName)
    local Module = Config:FindFirstChild(ConfigName, true)
    local Options = {}
    local Lookup = {}

    if Module and Module:IsA("ModuleScript") then
        local Success, Data = pcall(require, Module)

        if Success and type(Data) == "table" then
            for _, Entry in pairs(Data) do
                if type(Entry) == "table" then
                    local Id = Entry.ID or Entry.Id or Entry.id or Entry.Name
                    local Name = Entry.Name or Id

                    if Id and Name then
                        local Label = tostring(Name)
                        Lookup[Label] = Id
                        table.insert(Options, Label)
                    end
                end
            end
        end
    end

    table.sort(Options)

    if #Options == 0 then
        Options = {"Sin datos"}
    end

    return Options, Lookup
end

local Mobs, MobIds = makeOptions("MobConfig")
local Destinations, DestinationIds = makeOptions("TeleportConfig")

local SelectedMob = Mobs[1]
local SelectedDestination = Destinations[1]
local AutoAttack = false
local AttackDelay = 0.35

-- COMBATE

CombatTab:CreateSection("COMBATE")

CombatTab:CreateDropdown({
    Name = "Objetivo",
    Options = Mobs,
    CurrentOption = {SelectedMob},
    MultipleOptions = false,
    Flag = "LootEvo_Target",
    Callback = function(Value)
        SelectedMob = Value
    end
})

CombatTab:CreateSlider({
    Name = "Velocidad",
    Range = {0.15, 1},
    Increment = 0.05,
    CurrentValue = AttackDelay,
    Flag = "LootEvo_AttackDelay",
    Callback = function(Value)
        AttackDelay = Value
    end
})

CombatTab:CreateToggle({
    Name = "Auto Atacar",
    CurrentValue = false,
    Flag = "LootEvo_AutoAttack",
    Callback = function(Value)
        AutoAttack = Value == true
    end
})

CombatTab:CreateButton({
    Name = "Atacar una vez",
    Callback = function()
        local Success, ErrorMessage = callRemote("AttackMob", MobIds[SelectedMob] or SelectedMob)
        if not Success then
            notify("Combate", tostring(ErrorMessage), "warning")
        end
    end
})

CombatTab:CreateButton({
    Name = "Evento Dinosaurio",
    Callback = function()
        local Success, ErrorMessage = callRemote("DinoActionEvent", MobIds[SelectedMob] or SelectedMob)
        if not Success then
            notify("Dinosaurio", tostring(ErrorMessage), "warning")
        end
    end
})

-- PROGRESO

ProgressTab:CreateSection("REBIRTH")

ProgressTab:CreateButton({
    Name = "Hacer Rebirth",
    Description = "Solo se completa si el juego confirma que cumples el requisito",
    Callback = function()
        local Success, ErrorMessage = callRemote("RebirthRequest")
        if not Success then
            notify("Rebirth", tostring(ErrorMessage), "warning")
        end
    end
})

-- VIAJE

TravelTab:CreateSection("TELEPORT")

TravelTab:CreateDropdown({
    Name = "Destino",
    Options = Destinations,
    CurrentOption = {SelectedDestination},
    MultipleOptions = false,
    Flag = "LootEvo_Destination",
    Callback = function(Value)
        SelectedDestination = Value
    end
})

TravelTab:CreateButton({
    Name = "Teletransportar",
    Callback = function()
        local Success, ErrorMessage = callRemote("TeleportRequest", DestinationIds[SelectedDestination] or SelectedDestination)
        if not Success then
            notify("Teleport", tostring(ErrorMessage), "warning")
        end
    end
})

-- SISTEMA

SystemTab:CreateSection("SISTEMA")

SystemTab:CreateButton({
    Name = "Cerrar NC HUB",
    Callback = function()
        Luna:Destroy()
    end
})

SystemTab:BuildThemeSection()

task.spawn(function()
    while task.wait(AttackDelay) do
        if AutoAttack then
            local Success, ErrorMessage = callRemote("AttackMob", MobIds[SelectedMob] or SelectedMob)

            if not Success then
                AutoAttack = false
                notify("Combate", tostring(ErrorMessage), "warning")
            end
        end
    end
end)

notify("NC HUB", "Loot Evo cargado", "check_circle")
