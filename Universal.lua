-- NC HUB | Universal

local Luna = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/NcMay67/Luna-Interface-Suite/master/source.lua"
))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

local Connections = {}
local IsDestroyed = false

-- Estado global del módulo

-- Gestión del ciclo de vida

local function trackConnection(Connection)
    table.insert(Connections, Connection)
    return Connection
end

local function disconnectAll()
    for _, Connection in ipairs(Connections) do
        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end

    table.clear(Connections)
end

local Window = Luna:CreateWindow({
    Name = "NC HUB",
    Subtitle = "Universal",
    LoadingEnabled = true,
    LoadingTitle = "NC HUB",
    LoadingSubtitle = "Universal",
    KeySystem = false
})

local PlayerTab = Window:CreateTab({
    Name = "Jugador",
    Icon = "accessibility_new",
    ImageSource = "Material",
    ShowTitle = true
})

local VisualTab = Window:CreateTab({
    Name = "Visual",
    Icon = "visibility",
    ImageSource = "Material",
    ShowTitle = true
})

local SystemTab = Window:CreateTab({
    Name = "Sistema",
    Icon = "settings",
    ImageSource = "Material",
    ShowTitle = true
})

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

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    return getCharacter():FindFirstChildOfClass("Humanoid")
        or getCharacter():WaitForChild("Humanoid")
end

local function getRoot()
    return getCharacter():FindFirstChild("HumanoidRootPart")
        or getCharacter():WaitForChild("HumanoidRootPart")
end

local Speed = 24
local Jump = 50
local InfiniteJump = false
local Noclip = false
local Fly = false
local FlySpeed = 60
local AntiAFK = false
local ESP = false
local ESPShowName = true
local ESPShowDistance = true
local ESPShowHealth = true


-- JUGADOR
-- Movimiento, salto, noclip y vuelo

PlayerTab:CreateSection("MOVIMIENTO")

local SpeedSlider = PlayerTab:CreateSlider({
    Name = "Velocidad",
    Range = {16, 120},
    Increment = 1,
    CurrentValue = Speed,
    Callback = function(Value)
        Speed = Value
        getHumanoid().WalkSpeed = Value
    end
}, "NC_UniversalSpeed")

local JumpSlider = PlayerTab:CreateSlider({
    Name = "Salto",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = Jump,
    Callback = function(Value)
        Jump = Value

        local Humanoid = getHumanoid()
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = Value
    end
}, "NC_UniversalJump")

PlayerTab:CreateToggle({
    Name = "Salto infinito",
    CurrentValue = false,
    Callback = function(Value)
        InfiniteJump = Value == true
    end
}, "NC_UniversalInfiniteJump")

trackConnection(UserInputService.JumpRequest:Connect(function()
    if not IsDestroyed and InfiniteJump then
        getHumanoid():ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

local OriginalCollision = {}

PlayerTab:CreateToggle({
    Name = "No colisión",
    CurrentValue = false,
    Callback = function(Value)
        Noclip = Value == true
    end
}, "NC_UniversalNoclip")

trackConnection(RunService.Stepped:Connect(function()
    if not IsDestroyed and Noclip then
        for _, Object in ipairs(getCharacter():GetDescendants()) do
            if Object:IsA("BasePart") then
                if OriginalCollision[Object] == nil then
                    OriginalCollision[Object] = Object.CanCollide
                end
                Object.CanCollide = false
            end
        end
    elseif next(OriginalCollision) then
        for Part, State in pairs(OriginalCollision) do
            if Part and Part.Parent then
                Part.CanCollide = State
            end
        end
        table.clear(OriginalCollision)
    end
end))

PlayerTab:CreateSection("Vuelo")

local FlyVelocity
local FlyGyro
local FlyConnection
local Controls

local function getControls()
    if Controls then
        return Controls
    end

    pcall(function()
        Controls = require(LocalPlayer:WaitForChild("PlayerScripts")
            :WaitForChild("PlayerModule")):GetControls()
    end)

    return Controls
end

local function stopFly()
    Fly = false

    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    if FlyVelocity then
        FlyVelocity:Destroy()
        FlyVelocity = nil
    end

    if FlyGyro then
        FlyGyro:Destroy()
        FlyGyro = nil
    end

    local Humanoid = LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

    if Humanoid then
        Humanoid.AutoRotate = true
        Humanoid.PlatformStand = false
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

local function restoreCharacter()
    Noclip = false
    InfiniteJump = false
    ESP = false
    AntiAFK = false

    -- Eliminar directamente todos los objetos del ESP
    for _, Player in ipairs(Players:GetPlayers()) do
        local Character = Player.Character

        if Character then
            for _, Object in ipairs(Character:GetDescendants()) do
                if Object.Name == "NC_ESP"
                    or Object.Name == "NC_ESP_Info" then
                    Object:Destroy()
                end
            end
        end
    end

    stopFly()


    for Part, OriginalState in pairs(OriginalCollision) do
        if Part and Part.Parent then
            Part.CanCollide = OriginalState
        end
    end

    table.clear(OriginalCollision)

    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

    if Humanoid then
        Humanoid.WalkSpeed = 16
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = 50
        Humanoid.AutoRotate = true
        Humanoid.PlatformStand = false
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    
    -- Sincronizar visualmente los controles de Luna UI
    local SpeedOption = Luna.Options["NC_UniversalSpeed"]

    if SpeedOption then
        if SpeedOption.Set then
            SpeedOption:Set({
                CurrentValue = 16
            })
        elseif SpeedOption.UpdateValue then
            SpeedOption:UpdateValue(16)
        end
    end

    local JumpOption = Luna.Options["NC_UniversalJump"]

    if JumpOption then
        if JumpOption.Set then
            JumpOption:Set({
                CurrentValue = 50
            })
        elseif JumpOption.UpdateValue then
            JumpOption:UpdateValue(50)
        end
    end

    local FlySpeedOption = Luna.Options["NC_UniversalFlySpeed"]
    if FlySpeedOption and FlySpeedOption.UpdateValue then
        FlySpeedOption:UpdateValue(60)
    end

    local InfiniteJumpOption = Luna.Options["NC_UniversalInfiniteJump"]
    if InfiniteJumpOption and InfiniteJumpOption.UpdateState then
        InfiniteJumpOption:UpdateState(false)
    end

    local NoclipOption = Luna.Options["NC_UniversalNoclip"]
    if NoclipOption and NoclipOption.UpdateState then
        NoclipOption:UpdateState(false)
    end

    local FlyOption = Luna.Options["NC_UniversalFly"]
    if FlyOption and FlyOption.UpdateState then
        FlyOption:UpdateState(false)
    end

    local ESPOption = Luna.Options["NC_UniversalESP"]
    if ESPOption and ESPOption.UpdateState then
        ESPOption:UpdateState(false)
    end

    local ESPNameOption = Luna.Options["NC_UniversalESPShowName"]
    if ESPNameOption and ESPNameOption.UpdateState then
        ESPNameOption:UpdateState(false)
    end

    local ESPDistanceOption = Luna.Options["NC_UniversalESPShowDistance"]
    if ESPDistanceOption and ESPDistanceOption.UpdateState then
        ESPDistanceOption:UpdateState(false)
    end

    local ESPHealthOption = Luna.Options["NC_UniversalESPShowHealth"]
    if ESPHealthOption and ESPHealthOption.UpdateState then
        ESPHealthOption:UpdateState(false)
    end

    local AntiAFKOption = Luna.Options["NC_UniversalAntiAFK"]
    if AntiAFKOption and AntiAFKOption.UpdateState then
        AntiAFKOption:UpdateState(false)
    end

    notify(
        "NC HUB",
        "El personaje fue restaurado.",
        "restore"
    )
end

local function startFly()
    stopFly()
    Fly = true

    local Humanoid = getHumanoid()
    local Root = getRoot()
    local PlayerControls = getControls()

    Humanoid.AutoRotate = false
    Humanoid.PlatformStand = true

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    FlyVelocity.P = 18000
    FlyVelocity.Velocity = Vector3.new(0, 0, 0)
    FlyVelocity.Parent = Root

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    FlyGyro.P = 35000
    FlyGyro.D = 900
    FlyGyro.Parent = Root

    FlyConnection = RunService.RenderStepped:Connect(function()
        if IsDestroyed then
            return
        end

        if not Fly or not Root.Parent then
            return
        end

        local Camera = workspace.CurrentCamera

        if not Camera then
            return
        end

        local Move = PlayerControls
            and PlayerControls:GetMoveVector()
            or Humanoid.MoveDirection

        local Direction =
            Camera.CFrame.RightVector * Move.X
            + Camera.CFrame.LookVector * -Move.Z

        if Direction.Magnitude > 0.05 then
            Direction = Direction.Unit * FlySpeed
        else
            Direction = Vector3.new(0, 0, 0)
        end

        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

        FlyVelocity.Velocity = Direction
        FlyGyro.CFrame = Camera.CFrame
    end)
end

PlayerTab:CreateToggle({
    Name = "Volar",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            startFly()
        else
            stopFly()
        end
    end
}, "NC_UniversalFly")

local FlySpeedSlider = PlayerTab:CreateSlider({
    Name = "Velocidad Vuelo",
    Range = {20, 180},
    Increment = 1,
    CurrentValue = FlySpeed,
    Callback = function(Value)
        FlySpeed = Value
    end
}, "NC_UniversalFlySpeed")

-- VISUAL
-- ESP, etiquetas y actualización visual

VisualTab:CreateSection("ESP")

local function removeESP(Player)
    local Character = Player.Character

    if not Character then
        return
    end

    for _, Object in ipairs(Character:GetDescendants()) do
        if Object.Name == "NC_ESP"
            or Object.Name == "NC_ESP_Info" then
            Object:Destroy()
        end
    end
end


local function applyESP(Player)
    if Player == LocalPlayer or not ESP or not Player.Character then
        return
    end

    local Character = Player.Character
    local Head = Character:FindFirstChild("Head")
        or Character:FindFirstChild("HumanoidRootPart")

    if not Head then
        return
    end

    local Highlight = Character:FindFirstChild("NC_ESP")

    if not Highlight then
        Highlight = Instance.new("Highlight")
        Highlight.Name = "NC_ESP"
        Highlight.FillColor = Color3.fromRGB(174, 113, 255)
        Highlight.FillTransparency = 0.55
        Highlight.OutlineColor = Color3.fromRGB(152, 235, 255)
        Highlight.OutlineTransparency = 0
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.Parent = Character
    end

    local ESPInfo = Head:FindFirstChild("NC_ESP_Info")

    if not ESPInfo then
        ESPInfo = Instance.new("BillboardGui")
        ESPInfo.Name = "NC_ESP_Info"
        ESPInfo.Adornee = Head
        ESPInfo.AlwaysOnTop = true
        ESPInfo.LightInfluence = 0
        ESPInfo.MaxDistance = 1000
        ESPInfo.Size = UDim2.fromOffset(190, 42)
        ESPInfo.StudsOffset = Vector3.new(0, 3, 0)
        ESPInfo.Parent = Head

        local Label = Instance.new("TextLabel")
        Label.Name = "Info"
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.fromScale(1, 1)
        Label.Font = Enum.Font.GothamSemibold
        Label.TextSize = 13
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        Label.TextStrokeTransparency = 0.25
        Label.TextWrapped = true
        Label.TextYAlignment = Enum.TextYAlignment.Center
        Label.Parent = ESPInfo
    end

    local Label = ESPInfo:FindFirstChild("Info")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local LocalCharacter = LocalPlayer.Character
    local LocalRoot = LocalCharacter
        and LocalCharacter:FindFirstChild("HumanoidRootPart")
    local PlayerRoot = Character:FindFirstChild("HumanoidRootPart")

    local Distance = 0

    if LocalRoot and PlayerRoot then
        Distance = math.floor((LocalRoot.Position - PlayerRoot.Position).Magnitude)
    end

    local HealthText = "HP: ?"

    if Humanoid then
        HealthText = string.format(
            "HP: %d/%d",
            math.floor(Humanoid.Health),
            math.floor(Humanoid.MaxHealth)
        )

        local HealthPercent = 0

        if Humanoid.MaxHealth > 0 then
            HealthPercent = Humanoid.Health / Humanoid.MaxHealth
        end

        if HealthPercent > 0.6 then
            Label.TextColor3 = Color3.fromRGB(120, 255, 140)
        elseif HealthPercent > 0.3 then
            Label.TextColor3 = Color3.fromRGB(255, 220, 100)
        else
            Label.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end

    local ESPText = {}

    if ESPShowName then
        table.insert(ESPText, Player.DisplayName)
    end

    local Details = {}

    if ESPShowDistance then
        table.insert(Details, tostring(Distance) .. " studs")
    end

    if ESPShowHealth then
        table.insert(Details, HealthText)
    end

    if #Details > 0 then
        table.insert(ESPText, table.concat(Details, " | "))
    end

    Label.Text = table.concat(ESPText, "\n")
end

local ESPUpdateTimer = 0

trackConnection(RunService.Heartbeat:Connect(function(DeltaTime)
    if IsDestroyed or not ESP then
        return
    end

    ESPUpdateTimer = ESPUpdateTimer + DeltaTime

    -- Actualiza el texto cinco veces por segundo
    if ESPUpdateTimer < 0.2 then
        return
    end

    ESPUpdateTimer = 0

    for _, Player in ipairs(Players:GetPlayers()) do
        applyESP(Player)
    end
end))

local function prepareESP(Player)
    if Player == LocalPlayer then
        return
    end

    trackConnection(Player.CharacterAdded:Connect(function()
        task.wait(0.3)
        applyESP(Player)
    end))
end

for _, Player in ipairs(Players:GetPlayers()) do
    prepareESP(Player)
end

trackConnection(Players.PlayerAdded:Connect(prepareESP))
trackConnection(Players.PlayerRemoving:Connect(removeESP))

VisualTab:CreateToggle({
    Name = "ESP Jugadores",
    CurrentValue = false,
    Callback = function(Value)
        ESP = Value == true

        for _, Player in ipairs(Players:GetPlayers()) do
            if ESP then
                applyESP(Player)
            else
                removeESP(Player)
            end
        end
    end
}, "NC_UniversalESP")

VisualTab:CreateToggle({
    Name = "ESP: nombres",
    Description = "Muestra el nombre de cada jugador.",
    CurrentValue = true,
    Callback = function(Value)
        ESPShowName = Value == true

        if ESP then
            for _, Player in ipairs(Players:GetPlayers()) do
                applyESP(Player)
            end
        end
    end
}, "NC_UniversalESPShowName")

VisualTab:CreateToggle({
    Name = "ESP: distancia",
    Description = "Muestra la distancia hasta cada jugador.",
    CurrentValue = true,
    Callback = function(Value)
        ESPShowDistance = Value == true

        if ESP then
            for _, Player in ipairs(Players:GetPlayers()) do
                applyESP(Player)
            end
        end
    end
}, "NC_UniversalESPShowDistance")

VisualTab:CreateToggle({
    Name = "ESP: vida",
    Description = "Muestra la vida actual y máxima.",
    CurrentValue = true,
    Callback = function(Value)
        ESPShowHealth = Value == true

        if ESP then
            for _, Player in ipairs(Players:GetPlayers()) do
                applyESP(Player)
            end
        end
    end
}, "NC_UniversalESPShowHealth")


-- SISTEMA
-- Anti-AFK, herramientas, perfiles y cierre

SystemTab:CreateSection("SISTEMA")

SystemTab:CreateButton({
    Name = "Restaurar personaje",
    Description = "Desactiva vuelo, noclip, salto infinito y restaura los valores normales.",
    Callback = function()
        restoreCharacter()
    end
})

SystemTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Callback = function(Value)
        AntiAFK = Value == true
    end
}, "NC_UniversalAntiAFK")

trackConnection(LocalPlayer.Idled:Connect(function()
    if not IsDestroyed and AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end))

SystemTab:CreateButton({
    Name = "Abrir Dark Dex",
    Callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"
        ))()
    end
})

SystemTab:CreateButton({
    Name = "Abrir SimpleSpy",
    Callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"
        ))()
    end
})

SystemTab:CreateButton({
    Name = "Reconectar",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

SystemTab:CreateSection("PERFILES")

SystemTab:BuildConfigSection()


SystemTab:CreateButton({
    Name = "Cerrar NC HUB",
    Description = "Desactiva las funciones y cierra completamente la interfaz.",
    Callback = function()
        if IsDestroyed then
            return
        end

        IsDestroyed = true

        restoreCharacter()
        disconnectAll()

        for _, Player in ipairs(Players:GetPlayers()) do
            removeESP(Player)
        end

        Luna:Destroy()
    end
})


trackConnection(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.7)

    local Humanoid = getHumanoid()
    Humanoid.WalkSpeed = Speed
    Humanoid.UseJumpPower = true
    Humanoid.JumpPower = Jump

    if Fly then
        startFly()
    end
end))

notify("NC HUB", "Universal cargado", "check_circle")
