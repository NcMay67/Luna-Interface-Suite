-- =========================================================
-- NC HUB | Factory Tycoon
-- Módulo Luna UI — PlaceId: 15197136141
-- =========================================================

local Luna = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/NcMay67/Luna-Interface-Suite/master/source.lua"
))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local StartedAt = os.time()

local Window = Luna:CreateWindow({
    Name = "NC HUB",
    Subtitle = "Factory Tycoon · By hidjcjgg",
    LoadingEnabled = true,
    LoadingTitle = "NC HUB",
    LoadingSubtitle = "Cargando Factory Tycoon",
    KeySystem = false
})

local Tabs = {
    Inicio = Window:CreateTab({
        Name = "Inicio",
        Icon = "home",
        ImageSource = "Material",
        ShowTitle = true
    }),
    Automatizacion = Window:CreateTab({
        Name = "Automatización",
        Icon = "settings",
        ImageSource = "Material",
        ShowTitle = true
    }),
    Jugador = Window:CreateTab({
        Name = "Jugador",
        Icon = "accessibility_new",
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

local function getDataFolder()
    return LocalPlayer:FindFirstChild("DataFolder")
end

local function getNumber(Folder, Name)
    if not Folder then
        return 0
    end

    local Value = Folder:FindFirstChild(Name)
    if Value and (Value:IsA("NumberValue") or Value:IsA("IntValue")) then
        return Value.Value
    end

    return 0
end

local function getTycoon()
    local Owned = LocalPlayer:FindFirstChild("TycoonOwned")
    if Owned and Owned.Value and Owned.Value:IsA("Instance") then
        return Owned.Value
    end

    return nil
end

local function getEvents()
    return ReplicatedStorage:FindFirstChild("Events")
end

local function getHumanoid()
    local Character = LocalPlayer.Character
    return Character and Character:FindFirstChildOfClass("Humanoid")
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

local function formatTime(Seconds)
    local Hours = math.floor(Seconds / 3600)
    local Minutes = math.floor((Seconds % 3600) / 60)
    local RemainingSeconds = Seconds % 60

    return string.format("%dh %dm %ds", Hours, Minutes, RemainingSeconds)
end

local function hasRobuxRequirement(Button)
    return Button:FindFirstChild("GamepassID")
        or Button:FindFirstChild("GamePassID")
        or Button:FindFirstChild("ProductID")
        or Button:FindFirstChild("DevProductID")
        or Button:FindFirstChild("DeveloperProductID")
end

local function safeRun(Name, Callback)
    local Success, ErrorMessage = pcall(Callback)
    if not Success then
        warn("[NC HUB Factory | " .. Name .. "] " .. tostring(ErrorMessage))
    end
end

-- =========================================================
-- INICIO
-- =========================================================

Tabs.Inicio:CreateSection("ESTADO DE LA FÁBRICA")

local MoneyStatus = Tabs.Inicio:CreateLabel({
    Text = "Efectivo: $0"
})

local GemsStatus = Tabs.Inicio:CreateLabel({
    Text = "Gemas: 0"
})

local FactoryStatus = Tabs.Inicio:CreateLabel({
    Text = "Fábrica: Buscando..."
})

local SessionStatus = Tabs.Inicio:CreateLabel({
    Text = "Sesión: 0h 0m 0s"
})

Tabs.Inicio:CreateParagraph({
    Title = "Información",
    Text = "Los valores se leen desde DataFolder. Las automatizaciones solo actúan sobre la fábrica asignada a tu jugador."
})

-- =========================================================
-- AUTOMATIZACIÓN
-- =========================================================

Tabs.Automatizacion:CreateSection("AUTO-FARM")

local AutomationStatus = Tabs.Automatizacion:CreateLabel({
    Text = "Estado: ninguna automatización activa"
})

local AutoCollectEnabled = false
local AutoBuyEnabled = false
local AutoRebirthEnabled = false

local function updateAutomationStatus()
    local Active = {}

    if AutoCollectEnabled then
        table.insert(Active, "Cobrar")
    end

    if AutoBuyEnabled then
        table.insert(Active, "Comprar")
    end

    if AutoRebirthEnabled then
        table.insert(Active, "Rebirth")
    end

    if #Active == 0 then
        AutomationStatus:Set("Estado: ninguna automatización activa")
    else
        AutomationStatus:Set("Activas: " .. table.concat(Active, " · "))
    end
end

Tabs.Automatizacion:CreateToggle({
    Name = "Auto-Cobrar dinero",
    Description = "Recoge el dinero de tu fábrica automáticamente",
    CurrentValue = false,
    Flag = "Factory_AutoCollect",
    Callback = function(State)
        AutoCollectEnabled = State == true
        updateAutomationStatus()
    end
})

Tabs.Automatizacion:CreateToggle({
    Name = "Auto-Comprar mejoras",
    Description = "Compra una mejora normal disponible por ciclo",
    CurrentValue = false,
    Flag = "Factory_AutoBuy",
    Callback = function(State)
        AutoBuyEnabled = State == true
        updateAutomationStatus()
    end
})

Tabs.Automatizacion:CreateParagraph({
    Title = "Compra protegida",
    Text = "Auto-Comprar ignora botones con GamepassID, ProductID y DevProductID. Solo intenta compras normales con el dinero disponible."
})

Tabs.Automatizacion:CreateSection("X5 BOOST")

local BoostStatus = Tabs.Automatizacion:CreateLabel({
    Text = "Estado: listo para activar"
})

Tabs.Automatizacion:CreateButton({
    Name = "Activar X5 Boost",
    Description = "Intenta activar el valor local Money5xBoost",
    Callback = function()
        local Data = getDataFolder()
        local Boost = Data and Data:FindFirstChild("Money5xBoost")

        if Boost and (Boost:IsA("NumberValue") or Boost:IsA("IntValue")) then
            Boost.Value = os.time() + 999999
            BoostStatus:Set("Estado: Boost x5 activado")
            notify("X5 Boost", "Boost de dinero activado localmente.", "check_circle")
        else
            BoostStatus:Set("Estado: Money5xBoost no fue encontrado")
            notify("X5 Boost", "No se encontró Money5xBoost en DataFolder.", "warning")
        end
    end
})

Tabs.Automatizacion:CreateParagraph({
    Title = "Boost recuperado",
    Text = "Usa el valor local Money5xBoost recuperado de tu código original."
})

Tabs.Automatizacion:CreateSection("REBIRTH")

local RebirthStatus = Tabs.Automatizacion:CreateLabel({
    Text = "Estado: desactivado"
})

Tabs.Automatizacion:CreateToggle({
    Name = "Auto-Rebirth",
    Description = "Comprueba el rebirth cada 2 segundos",
    CurrentValue = false,
    Flag = "Factory_AutoRebirth",
    Callback = function(State)
        AutoRebirthEnabled = State == true

        if AutoRebirthEnabled then
            RebirthStatus:Set("Estado: comprobando requisitos cada 2 segundos")
        else
            RebirthStatus:Set("Estado: desactivado")
        end

        updateAutomationStatus()
    end
})

-- =========================================================
-- JUGADOR
-- =========================================================

Tabs.Jugador:CreateSection("VELOCIDAD Y SALTO")

local WalkSpeed = 16
local JumpPower = 50

Tabs.Jugador:CreateSlider({
    Name = "Velocidad",
    Range = {16, 120},
    Increment = 1,
    CurrentValue = 16,
    Flag = "Factory_WalkSpeed",
    Callback = function(Value)
        WalkSpeed = Value

        local Humanoid = getHumanoid()
        if Humanoid then
            Humanoid.WalkSpeed = WalkSpeed
        end
    end
})

Tabs.Jugador:CreateSlider({
    Name = "Salto",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = 50,
    Flag = "Factory_JumpPower",
    Callback = function(Value)
        JumpPower = Value

        local Humanoid = getHumanoid()
        if Humanoid then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = JumpPower
        end
    end
})

Tabs.Jugador:CreateParagraph({
    Title = "Persistencia",
    Text = "La velocidad y el salto seleccionados se vuelven a aplicar cuando tu personaje reaparece."
})

-- =========================================================
-- SISTEMA
-- =========================================================

Tabs.Sistema:CreateSection("HERRAMIENTAS")

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
-- CICLOS DEL MÓDULO
-- =========================================================

task.spawn(function()
    while task.wait(0.75) do
        if AutoCollectEnabled then
            safeRun("Auto-Cobrar", function()
                local Tycoon = getTycoon()
                local Events = getEvents()
                if not Tycoon or not Events then
                    return
                end

                local Build = Tycoon:FindFirstChild("Build")
                local CollectPart = Build and Build:FindFirstChild("Collect")
                local CollectRemote = Events:FindFirstChild("CollectMoney")

                if CollectPart and CollectRemote and CollectRemote:IsA("RemoteEvent") then
                    CollectRemote:FireServer(CollectPart)
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.8) do
        if AutoBuyEnabled then
            safeRun("Auto-Comprar", function()
                local Tycoon = getTycoon()
                local Data = getDataFolder()
                local Events = getEvents()
                if not Tycoon or not Data or not Events then
                    return
                end

                local Buttons = Tycoon:FindFirstChild("Buttons")
                local BuyRemote = Events:FindFirstChild("ButtonUsed")
                local Money = getNumber(Data, "Money")
                if not Buttons or not BuyRemote or not BuyRemote:IsA("RemoteEvent") then
                    return
                end

                for _, Button in ipairs(Buttons:GetChildren()) do
                    local Price = Button:FindFirstChild("Price")
                    local Visible = Button:FindFirstChild("IsButtonVisible")

                    if Price and Visible and Visible.Value == true
                        and not hasRobuxRequirement(Button)
                        and Money >= Price.Value then
                        BuyRemote:FireServer(Button.Name)
                        break
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if AutoRebirthEnabled then
            safeRun("Auto-Rebirth", function()
                local Tycoon = getTycoon()
                local Events = getEvents()
                local RebirthRemote = Events and Events:FindFirstChild("RequestRebirth")

                if Tycoon and RebirthRemote and RebirthRemote:IsA("RemoteEvent") then
                    RebirthRemote:FireServer(653, 653, Tycoon)
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        safeRun("Dashboard", function()
            local Data = getDataFolder()
            local Money = getNumber(Data, "Money")
            local Gems = getNumber(Data, "Gems")
            local Tycoon = getTycoon()

            MoneyStatus:Set("Efectivo: $" .. formatNumber(Money))
            GemsStatus:Set("Gemas: " .. formatNumber(Gems))
            FactoryStatus:Set("Fábrica: " .. (Tycoon and "Asignada" or "Esperando parcela"))
            SessionStatus:Set("Sesión: " .. formatTime(os.time() - StartedAt))
        end)
    end
end)

task.spawn(function()
    while task.wait(1) do
        local Humanoid = getHumanoid()
        if Humanoid then
            Humanoid.WalkSpeed = WalkSpeed
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = JumpPower
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.8)

    local Humanoid = getHumanoid()
    if Humanoid then
        Humanoid.WalkSpeed = WalkSpeed
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = JumpPower
    end
end)

notify("NC HUB", "Factory Tycoon cargado", "check_circle")
