-- =========================================================
-- NC HUB | Loot Evo
-- PlaceId: 96033388567901
-- =========================================================

local Luna = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/NcMay67/Luna-Interface-Suite/master/source.lua"
))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Config = ReplicatedStorage:FindFirstChild("Config")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local StartedAt = os.time()

local Window = Luna:CreateWindow({
    Name = "NC HUB",
    Subtitle = "Loot Evo · +500M_Team",
    LoadingEnabled = true,
    LoadingTitle = "NC HUB",
    LoadingSubtitle = "Cargando Loot Evo",
    KeySystem = false
})

local Tabs = {
    Estado = Window:CreateTab({
        Name = "Estado",
        Icon = "analytics",
        ImageSource = "Material",
        ShowTitle = true
    }),
    Combate = Window:CreateTab({
        Name = "Combate",
        Icon = "military_tech",
        ImageSource = "Material",
        ShowTitle = true
    }),
    Progreso = Window:CreateTab({
        Name = "Progreso",
        Icon = "trending_up",
        ImageSource = "Material",
        ShowTitle = true
    }),
    Habilidades = Window:CreateTab({
        Name = "Habilidades",
        Icon = "bolt",
        ImageSource = "Material",
        ShowTitle = true
    }),
    Viaje = Window:CreateTab({
        Name = "Viaje",
        Icon = "map",
        ImageSource = "Material",
        ShowTitle = true
    }),
    Coleccion = Window:CreateTab({
        Name = "Colección",
        Icon = "pets",
        ImageSource = "Material",
        ShowTitle = true
    }),
    Sistema = Window:CreateTab({
        Name = "Sistema",
        Icon = "settings",
        ImageSource = "Material",
        ShowTitle = true
    })
}

Window:CreateHomeTab({
    Icon = 1,
    SupportedExecutors = {
        "Delta",
        "Delta Android",
        "Delta Executor"
    },
    DiscordInvite = "noinvitelink"
})

local function notify(Title, Content, Icon)
    Luna:Notification({
        Title = Title,
        Content = Content,
        Icon = Icon or "info",
        ImageSource = "Material"
    })
end

local function getRemote(Name)
    return Remotes and Remotes:FindFirstChild(Name)
end

local function requestRemote(Name, ...)
    local Remote = getRemote(Name)

    if not Remote then
        return false, "No existe ReplicatedStorage.Remotes." .. Name
    end

    local Arguments = table.pack(...)
    local Success, Result = pcall(function()
        if Remote:IsA("RemoteFunction") then
            return Remote:InvokeServer(table.unpack(Arguments, 1, Arguments.n))
        elseif Remote:IsA("RemoteEvent") then
            Remote:FireServer(table.unpack(Arguments, 1, Arguments.n))
            return true
        end

        error(Name .. " no es RemoteEvent ni RemoteFunction (" .. Remote.ClassName .. ")")
    end)

    if not Success then
        return false, tostring(Result)
    end

    return true, Result
end

local function findConfig(Name)
    if not Config then
        return nil
    end

    return Config:FindFirstChild(Name, true)
end

local function getConfig(Name)
    local Module = findConfig(Name)

    if not Module or not Module:IsA("ModuleScript") then
        return {}
    end

    local Success, Data = pcall(require, Module)
    if Success and type(Data) == "table" then
        return Data
    end

    return {}
end

local function trim(Value)
    return tostring(Value or ""):match("^%s*(.-)%s*$")
end

local function formatTime(Seconds)
    local Hours = math.floor(Seconds / 3600)
    local Minutes = math.floor((Seconds % 3600) / 60)
    local RemainingSeconds = Seconds % 60

    return string.format("%dh %dm %ds", Hours, Minutes, RemainingSeconds)
end

local function makeOptions(Data, Prefix)
    local Options = {}
    local Lookup = {}

    for _, Entry in pairs(Data) do
        if type(Entry) == "table" then
            local Id = Entry.ID or Entry.Id or Entry.id or Entry.Name
            local Name = Entry.Name or Entry.DisplayName or Id

            if Id ~= nil and Name ~= nil then
                local Label = string.format("%s%s", Prefix or "", trim(Name))

                if Lookup[Label] then
                    Label = Label .. " [" .. trim(Id) .. "]"
                end

                Lookup[Label] = Id
                table.insert(Options, Label)
            end
        end
    end

    table.sort(Options, function(A, B)
        return string.lower(A) < string.lower(B)
    end)

    if #Options == 0 then
        table.insert(Options, "Sin datos disponibles")
    end

    return Options, Lookup
end

local function selectedId(Lookup, Value)
    return Lookup[Value] or Value
end

local function summarizeTable(Data)
    if type(Data) ~= "table" then
        return tostring(Data)
    end

    local Rows = {}
    local Count = 0

    for Key, Value in pairs(Data) do
        Count = Count + 1
        if Count > 12 then
            table.insert(Rows, "…")
            break
        end

        table.insert(Rows, tostring(Key) .. ": " .. (type(Value) == "table" and "{...}" or tostring(Value)))
    end

    table.sort(Rows)
    return table.concat(Rows, "\n")
end

local function getMobContainer()
    local Candidates = {
        "Mobs", "Mob", "Enemies", "Monsters", "NPCs", "Dinos", "Dinosaurs", "Bosses"
    }

    for _, Name in ipairs(Candidates) do
        local Found = Workspace:FindFirstChild(Name, true)
        if Found then
            return Found
        end
    end

    return nil
end

local MobConfig = getConfig("MobConfig")
local BossDropConfig = getConfig("BossDropConfig")
local SkillConfig = getConfig("SkillConfig")
local TeleportConfig = getConfig("TeleportConfig")
local EggConfig = getConfig("EggConfig")
local TrainAreaConfig = getConfig("TrainAreaConfig")
local RebirthConfig = getConfig("RebirthConfig")
local PetConfig = getConfig("PetConfig")
local WeaponConfig = getConfig("WeaponConfig")
local GemConfig = getConfig("GemConfig")

local MobOptions, MobLookup = makeOptions(MobConfig)
local SkillOptions, SkillLookup = makeOptions(SkillConfig)
local TeleportOptions, TeleportLookup = makeOptions(TeleportConfig)
local EggOptions, EggLookup = makeOptions(EggConfig)
local TrainOptions, TrainLookup = makeOptions(TrainAreaConfig, "Zona ")
local RebirthOptions, RebirthLookup = makeOptions(RebirthConfig, "Rebirth ")

local SelectedMob = MobOptions[1]
local SelectedSkill = SkillOptions[1]
local SelectedTeleport = TeleportOptions[1]
local SelectedEgg = EggOptions[1]
local SelectedTrain = TrainOptions[1]
local SelectedRebirth = RebirthOptions[1]

local AutoAttackEnabled = false
local AutoTrainEnabled = false
local CombatDelay = 0.35

-- =========================================================
-- ESTADO
-- =========================================================

Tabs.Estado:CreateSection("ESTADO DEL JUGADOR")

local SessionStatus = Tabs.Estado:CreateLabel({
    Text = "Sesión: 0h 0m 0s"
})

local RemoteStatus = Tabs.Estado:CreateLabel({
    Text = Remotes and "Remotes: conectados" or "Remotes: no encontrados"
})

local DataStatus = Tabs.Estado:CreateParagraph({
    Title = "Datos del jugador",
    Text = "Pulsa Actualizar para consultar GetPlayerDataSnapshot."
})

Tabs.Estado:CreateButton({
    Name = "Actualizar datos del jugador",
    Description = "Consulta GetPlayerDataSnapshot sin modificar tu progreso",
    Callback = function()
        local Success, Data = requestRemote("GetPlayerDataSnapshot")

        if Success then
            DataStatus:Set({
                Title = "Datos del jugador",
                Text = summarizeTable(Data)
            })
            notify("Estado actualizado", "Se recibió la instantánea del jugador.", "check_circle")
        else
            DataStatus:Set({
                Title = "Datos del jugador",
                Text = "No se pudo consultar: " .. tostring(Data)
            })
            notify("Estado", "GetPlayerDataSnapshot no respondió: " .. tostring(Data), "warning")
        end
    end
})

Tabs.Estado:CreateParagraph({
    Title = "Mapa confirmado",
    Text = string.format(
        "Mobs: %d · Habilidades: %d · Destinos: %d · Huevos: %d · Entrenamientos: %d",
        #MobOptions, #SkillOptions, #TeleportOptions, #EggOptions, #TrainOptions
    )
})

-- =========================================================
-- COMBATE
-- =========================================================

Tabs.Combate:CreateSection("MOBS Y JEFES")

local CombatStatus = Tabs.Combate:CreateLabel({
    Text = "Estado: listo"
})

Tabs.Combate:CreateDropdown({
    Name = "Objetivo",
    Description = "Listado dinámico desde MobConfig",
    Options = MobOptions,
    CurrentOption = {SelectedMob},
    MultipleOptions = false,
    Flag = "LootEvo_Mob",
    Callback = function(Option)
        SelectedMob = Option
    end
})

Tabs.Combate:CreateSlider({
    Name = "Intervalo de ataque",
    Range = {0.15, 2},
    Increment = 0.05,
    CurrentValue = CombatDelay,
    Flag = "LootEvo_CombatDelay",
    Callback = function(Value)
        CombatDelay = Value
    end
})

Tabs.Combate:CreateButton({
    Name = "Atacar objetivo una vez",
    Description = "Envía el ID seleccionado mediante AttackMob",
    Callback = function()
        local Id = selectedId(MobLookup, SelectedMob)
        local Success, Result = requestRemote("AttackMob", Id)

        if Success then
            CombatStatus:Set("Última acción: AttackMob → " .. tostring(Id))
        else
            CombatStatus:Set("AttackMob rechazado: " .. tostring(Result))
            notify("Combate", tostring(Result), "warning")
        end
    end
})

Tabs.Combate:CreateToggle({
    Name = "Auto-Atacar objetivo",
    Description = "Repite AttackMob con el objetivo seleccionado",
    CurrentValue = false,
    Flag = "LootEvo_AutoAttack",
    Callback = function(State)
        AutoAttackEnabled = State == true
        CombatStatus:Set(AutoAttackEnabled and "Estado: auto-ataque activo" or "Estado: auto-ataque detenido")
    end
})

Tabs.Combate:CreateSection("EVENTO DE DINOSAURIOS")

Tabs.Combate:CreateButton({
    Name = "Acción de dinosaurio",
    Description = "Envía el objetivo seleccionado a DinoActionEvent",
    Callback = function()
        local Id = selectedId(MobLookup, SelectedMob)
        local Success, Result = requestRemote("DinoActionEvent", Id)

        if Success then
            CombatStatus:Set("DinoActionEvent → " .. tostring(Id))
        else
            CombatStatus:Set("DinoActionEvent rechazado: " .. tostring(Result))
            notify("Evento dinosaurio", tostring(Result), "warning")
        end
    end
})

Tabs.Combate:CreateParagraph({
    Title = "Drops de jefe",
    Text = string.format(
        "Configuración localizada: %d entradas de botín de jefe. La barra visual del jefe usa PlayerGui.HUD.Top.BoosHP/BossHP.",
        #BossDropConfig
    )
})

-- =========================================================
-- PROGRESO
-- =========================================================

Tabs.Progreso:CreateSection("ENTRENAMIENTO")

local ProgressStatus = Tabs.Progreso:CreateLabel({
    Text = "Estado: sin entrenamiento automático"
})

Tabs.Progreso:CreateDropdown({
    Name = "Zona de entrenamiento",
    Description = "Zonas cargadas desde TrainAreaConfig",
    Options = TrainOptions,
    CurrentOption = {SelectedTrain},
    MultipleOptions = false,
    Flag = "LootEvo_TrainArea",
    Callback = function(Option)
        SelectedTrain = Option
    end
})

Tabs.Progreso:CreateToggle({
    Name = "Auto-Entrenar",
    Description = "Solicita el estado de auto-entrenamiento del juego",
    CurrentValue = false,
    Flag = "LootEvo_AutoTrain",
    Callback = function(State)
        AutoTrainEnabled = State == true
        local Id = selectedId(TrainLookup, SelectedTrain)
        local Success, Result = requestRemote("AutoTrainRequest", Id, AutoTrainEnabled)

        if Success then
            ProgressStatus:Set(AutoTrainEnabled and "Auto-entrenamiento solicitado: " .. tostring(Id) or "Auto-entrenamiento detenido")
        else
            ProgressStatus:Set("AutoTrainRequest rechazado: " .. tostring(Result))
            notify("Entrenamiento", tostring(Result), "warning")
        end
    end
})

Tabs.Progreso:CreateSection("RENACIMIENTO")

Tabs.Progreso:CreateDropdown({
    Name = "Nivel de renacimiento",
    Description = "Listado disponible desde RebirthConfig",
    Options = RebirthOptions,
    CurrentOption = {SelectedRebirth},
    MultipleOptions = false,
    Flag = "LootEvo_Rebirth",
    Callback = function(Option)
        SelectedRebirth = Option
    end
})

Tabs.Progreso:CreateButton({
    Name = "Solicitar renacimiento",
    Description = "Envía el ID seleccionado mediante RebirthRequest",
    Callback = function()
        local Id = selectedId(RebirthLookup, SelectedRebirth)
        local Success, Result = requestRemote("RebirthRequest", Id)

        if Success then
            ProgressStatus:Set("RebirthRequest enviado: " .. tostring(Id))
        else
            ProgressStatus:Set("RebirthRequest rechazado: " .. tostring(Result))
            notify("Renacimiento", tostring(Result), "warning")
        end
    end
})

Tabs.Progreso:CreateParagraph({
    Title = "Autoclick nativo",
    Text = "Loot Evo ya incluye autoclick gratuito. NC HUB no lo duplica; este módulo se centra en combate, progreso, habilidades, viaje y colección."
})

-- =========================================================
-- HABILIDADES
-- =========================================================

Tabs.Habilidades:CreateSection("HABILIDADES")

local SkillStatus = Tabs.Habilidades:CreateLabel({
    Text = "Estado: selecciona una habilidad"
})

Tabs.Habilidades:CreateDropdown({
    Name = "Habilidad",
    Description = "Catálogo cargado desde SkillConfig",
    Options = SkillOptions,
    CurrentOption = {SelectedSkill},
    MultipleOptions = false,
    Flag = "LootEvo_Skill",
    Callback = function(Option)
        SelectedSkill = Option
    end
})

Tabs.Habilidades:CreateButton({
    Name = "Usar habilidad",
    Description = "Envía el ID seleccionado mediante UseSkillRequest",
    Callback = function()
        local Id = selectedId(SkillLookup, SelectedSkill)
        local Success, Result = requestRemote("UseSkillRequest", Id)

        if Success then
            SkillStatus:Set("UseSkillRequest enviado: " .. tostring(Id))
        else
            SkillStatus:Set("UseSkillRequest rechazado: " .. tostring(Result))
            notify("Habilidad", tostring(Result), "warning")
        end
    end
})

Tabs.Habilidades:CreateButton({
    Name = "Consultar estado de habilidades",
    Description = "Consulta GetSkillState sin modificar ninguna carga",
    Callback = function()
        local Success, Result = requestRemote("GetSkillState")

        if Success then
            SkillStatus:Set("Estado: " .. summarizeTable(Result))
        else
            SkillStatus:Set("GetSkillState rechazado: " .. tostring(Result))
            notify("Habilidades", tostring(Result), "warning")
        end
    end
})

Tabs.Habilidades:CreateParagraph({
    Title = "Configuración detectada",
    Text = string.format("Se localizaron %d habilidades. También están disponibles SkillLoadoutRequest y SkillStateUpdated.", #SkillOptions)
})

-- =========================================================
-- VIAJE
-- =========================================================

Tabs.Viaje:CreateSection("TELETRANSPORTE")

local TravelStatus = Tabs.Viaje:CreateLabel({
    Text = "Estado: selecciona un destino"
})

Tabs.Viaje:CreateDropdown({
    Name = "Destino",
    Description = "Catálogo cargado desde TeleportConfig",
    Options = TeleportOptions,
    CurrentOption = {SelectedTeleport},
    MultipleOptions = false,
    Flag = "LootEvo_Teleport",
    Callback = function(Option)
        SelectedTeleport = Option
    end
})

Tabs.Viaje:CreateButton({
    Name = "Solicitar teletransporte",
    Description = "Envía el ID seleccionado mediante TeleportRequest",
    Callback = function()
        local Id = selectedId(TeleportLookup, SelectedTeleport)
        local Success, Result = requestRemote("TeleportRequest", Id)

        if Success then
            TravelStatus:Set("TeleportRequest enviado: " .. tostring(Id))
        else
            TravelStatus:Set("TeleportRequest rechazado: " .. tostring(Result))
            notify("Teletransporte", tostring(Result), "warning")
        end
    end
})

Tabs.Viaje:CreateParagraph({
    Title = "Estado de viaje",
    Text = "El juego también expone DungeonTeleportLoading, TeleportCompleted y CharacterTeleportSync para su flujo normal de viaje."
})

-- =========================================================
-- COLECCIÓN
-- =========================================================

Tabs.Coleccion:CreateSection("HUEVOS Y MASCOTAS")

local CollectionStatus = Tabs.Coleccion:CreateLabel({
    Text = "Estado: selecciona un huevo"
})

Tabs.Coleccion:CreateDropdown({
    Name = "Huevo",
    Description = "Catálogo cargado desde EggConfig",
    Options = EggOptions,
    CurrentOption = {SelectedEgg},
    MultipleOptions = false,
    Flag = "LootEvo_Egg",
    Callback = function(Option)
        SelectedEgg = Option
    end
})

Tabs.Coleccion:CreateButton({
    Name = "Comprar huevo",
    Description = "Envía el ID seleccionado mediante BuyEggEvent",
    Callback = function()
        local Id = selectedId(EggLookup, SelectedEgg)
        local Success, Result = requestRemote("BuyEggEvent", Id)

        if Success then
            CollectionStatus:Set("BuyEggEvent enviado: " .. tostring(Id))
        else
            CollectionStatus:Set("BuyEggEvent rechazado: " .. tostring(Result))
            notify("Huevo", tostring(Result), "warning")
        end
    end
})

Tabs.Coleccion:CreateButton({
    Name = "Consultar índice de mascotas",
    Description = "Consulta GetPetIndex sin modificar tu inventario",
    Callback = function()
        local Success, Result = requestRemote("GetPetIndex")

        if Success then
            CollectionStatus:Set("Índice: " .. summarizeTable(Result))
        else
            CollectionStatus:Set("GetPetIndex rechazado: " .. tostring(Result))
            notify("Mascotas", tostring(Result), "warning")
        end
    end
})

Tabs.Coleccion:CreateParagraph({
    Title = "Catálogos detectados",
    Text = string.format(
        "Mascotas: %d · Armas: %d · Gemas: %d · Huevos: %d",
        #PetConfig, #WeaponConfig, #GemConfig, #EggOptions
    )
})

-- =========================================================
-- SISTEMA
-- =========================================================

Tabs.Sistema:CreateSection("DIAGNÓSTICO")

local DiagnosticsStatus = Tabs.Sistema:CreateLabel({
    Text = "Mobs en mapa: buscando..."
})

Tabs.Sistema:CreateButton({
    Name = "Revisar mapa de mobs",
    Description = "Busca el contenedor de mobs/bosses en Workspace",
    Callback = function()
        local Container = getMobContainer()

        if Container then
            DiagnosticsStatus:Set("Contenedor: " .. Container:GetFullName() .. " · Objetos: " .. #Container:GetChildren())
            notify("Diagnóstico", "Contenedor de mobs localizado.", "check_circle")
        else
            DiagnosticsStatus:Set("No se localizó un contenedor estándar de mobs en Workspace")
            notify("Diagnóstico", "No se encontró Mobs/Mob/Enemies/Monsters/Dinos/Bosses.", "warning")
        end
    end
})

Tabs.Sistema:CreateButton({
    Name = "Abrir Dark Dex",
    Description = "Explorador de instancias",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end
})

Tabs.Sistema:CreateButton({
    Name = "Abrir SimpleSpy",
    Description = "Monitor de remotes",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))()
    end
})

Tabs.Sistema:CreateButton({
    Name = "Cerrar NC HUB",
    Description = "Cierra por completo la interfaz",
    Callback = function()
        Luna:Destroy()
    end
})

Tabs.Sistema:CreateSection("PERFILES Y TEMA")
Tabs.Sistema:BuildConfigSection()
Tabs.Sistema:BuildThemeSection()

-- =========================================================
-- CICLOS
-- =========================================================

task.spawn(function()
    while task.wait(CombatDelay) do
        if AutoAttackEnabled then
            local Id = selectedId(MobLookup, SelectedMob)
            local Success, Result = requestRemote("AttackMob", Id)

            if not Success then
                AutoAttackEnabled = false
                CombatStatus:Set("Auto-ataque detenido: " .. tostring(Result))
                notify("Combate", "AttackMob fue rechazado; se detuvo el ciclo.", "warning")
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        SessionStatus:Set("Sesión: " .. formatTime(os.time() - StartedAt))
    end
end)

notify("NC HUB", "Loot Evo cargado", "check_circle")
