-- NC HUB | Universal Luna Test
-- Uses a Luna-derived source that retains its BSD-3-Clause notice in source.lua and LICENSE.

local Luna = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/NcMay67/Luna-Interface-Suite/refs/heads/master/source.lua"
))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local StartedAt = os.time()

local Window = Luna:CreateWindow({
    Name = "NC HUB",
    Subtitle = "By hidjcjgg",
    LoadingEnabled = true,
    LoadingTitle = "NC HUB",
    LoadingSubtitle = "Preparando módulo universal",
    KeySystem = false
})

local Tabs = {
    Jugador = Window:CreateTab({
        Name = "Jugador",
        Icon = "accessibility_new",
        ImageSource = "Material",
        ShowTitle = true
    }),
    Visuales = Window:CreateTab({
        Name = "Visuales",
        Icon = "visibility",
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

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    local Character = getCharacter()
    return Character:FindFirstChildOfClass("Humanoid")
        or Character:WaitForChild("Humanoid")
end

local function getRoot()
    local Character = getCharacter()
    return Character:FindFirstChild("HumanoidRootPart")
        or Character:WaitForChild("HumanoidRootPart")
end

local function notify(Title, Content, Icon)
    Luna:Notification({
        Title = Title,
        Icon = Icon or "info",
        ImageSource = "Material",
        Content = Content
    })
end

-- =========================================================
-- INICIO
-- =========================================================
-- =========================================================
-- INICIO ESPECIAL DE LUNA
-- Perfil, Server, Executor y Friends.
-- =========================================================
Window:CreateHomeTab({
    Icon = 1,
    SupportedExecutors = {
        "Delta",
        "Delta Android",
        "Delta Executor"
    },
    DiscordInvite = "noinvitelink"
})

-- =========================================================
-- JUGADOR
-- =========================================================
Tabs.Jugador:CreateSection("VELOCIDAD Y SALTO")

local SpeedValue = 16
local JumpValue = 50

Tabs.Jugador:CreateSlider({
    Name = "Velocidad",
    Range = {16, 120},
    Increment = 1,
    CurrentValue = 16,
    Flag = "NC_Luna_Speed",
    Callback = function(Value)
        SpeedValue = Value
        getHumanoid().WalkSpeed = SpeedValue
    end
})

Tabs.Jugador:CreateSlider({
    Name = "Salto",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = 50,
    Flag = "NC_Luna_Jump",
    Callback = function(Value)
        JumpValue = Value
        local Humanoid = getHumanoid()
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = JumpValue
    end
})

local InfiniteJump = false
local Noclip = false

Tabs.Jugador:CreateToggle({
    Name = "Salto infinito",
    Description = "Permite saltar mientras estás en el aire",
    CurrentValue = false,
    Flag = "NC_Luna_InfiniteJump",
    Callback = function(State)
        InfiniteJump = State
    end
})

Tabs.Jugador:CreateToggle({
    Name = "Noclip",
    Description = "Restaura las colisiones al apagarlo",
    CurrentValue = false,
    Flag = "NC_Luna_Noclip",
    Callback = function(State)
        Noclip = State
    end
})

UserInputService.JumpRequest:Connect(function()
    if InfiniteJump then
        getHumanoid():ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local OriginalCollision = {}

local function restoreCollision()
    for Part, OriginalState in pairs(OriginalCollision) do
        if Part and Part.Parent then
            Part.CanCollide = OriginalState
        end
    end
    table.clear(OriginalCollision)
end

RunService.Stepped:Connect(function()
    if Noclip then
        local Character = LocalPlayer.Character
        if Character then
            for _, Object in ipairs(Character:GetDescendants()) do
                if Object:IsA("BasePart") then
                    if OriginalCollision[Object] == nil then
                        OriginalCollision[Object] = Object.CanCollide
                    end
                    Object.CanCollide = false
                end
            end
        end
    elseif next(OriginalCollision) then
        restoreCollision()
    end
end)

-- =========================================================
-- FLY CLÁSICO MÓVIL
-- =========================================================
Tabs.Jugador:CreateSection("FLY")

local FlyEnabled = false
local FlySpeed = 60
local FlyVelocity
local FlyGyro
local FlyConnection
local FlyControls
local LiftUntil = 0

local function getFlyControls()
    if FlyControls then
        return FlyControls
    end

    pcall(function()
        local PlayerModule = LocalPlayer:WaitForChild("PlayerScripts")
            :WaitForChild("PlayerModule")
        FlyControls = require(PlayerModule):GetControls()
    end)

    return FlyControls
end

local function stopFly()
    FlyEnabled = false

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

local function startFly()
    stopFly()
    FlyEnabled = true

    local Humanoid = getHumanoid()
    local Root = getRoot()
    local Controls = getFlyControls()

    Humanoid.AutoRotate = false
    Humanoid.PlatformStand = true

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.Name = "NC_Luna_FlyVelocity"
    FlyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    FlyVelocity.P = 18000
    FlyVelocity.Velocity = Vector3.new(0, 0, 0)
    FlyVelocity.Parent = Root

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.Name = "NC_Luna_FlyGyro"
    FlyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    FlyGyro.P = 35000
    FlyGyro.D = 900
    FlyGyro.CFrame = Root.CFrame
    FlyGyro.Parent = Root

    LiftUntil = os.clock() + 0.18

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not FlyEnabled or not Root.Parent or not Humanoid.Parent then
            return
        end

        local Camera = workspace.CurrentCamera
        if not Camera then
            return
        end

        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

        local MoveVector = Vector3.new(0, 0, 0)
        if Controls then
            MoveVector = Controls:GetMoveVector()
        else
            local MoveDirection = Humanoid.MoveDirection
            MoveVector = Vector3.new(MoveDirection.X, 0, -MoveDirection.Z)
        end

        local CameraFrame = Camera.CFrame
        local Direction = CameraFrame.RightVector * MoveVector.X
            + CameraFrame.LookVector * -MoveVector.Z

        if Direction.Magnitude > 0.05 then
            Direction = Direction.Unit * FlySpeed
        else
            Direction = Vector3.new(0, 0, 0)
        end

        if os.clock() < LiftUntil then
            Direction = Direction + Vector3.new(0, math.max(35, FlySpeed * 0.70), 0)
        end

        FlyVelocity.Velocity = Direction
        FlyGyro.CFrame = CameraFrame
    end)
end

Tabs.Jugador:CreateToggle({
    Name = "Activar Fly",
    Description = "Mira arriba y avanza para subir; mira abajo y avanza para bajar",
    CurrentValue = false,
    Flag = "NC_Luna_Fly",
    Callback = function(State)
        if State then
            startFly()
        else
            stopFly()
        end
    end
})

Tabs.Jugador:CreateSlider({
    Name = "Velocidad de vuelo",
    Range = {20, 180},
    Increment = 1,
    CurrentValue = 60,
    Flag = "NC_Luna_FlySpeed",
    Callback = function(Value)
        FlySpeed = Value
    end
})

-- =========================================================
-- VISUALES
-- =========================================================
Tabs.Visuales:CreateSection("ESP")

local ESPEnabled = false

local function removeESP(Player)
    local Character = Player.Character
    if Character then
        local Highlight = Character:FindFirstChild("NC_Luna_ESP")
        if Highlight then
            Highlight:Destroy()
        end
    end
end

local function applyESP(Player)
    if Player == LocalPlayer or not ESPEnabled then
        return
    end

    local Character = Player.Character
    if not Character then
        return
    end

    local Highlight = Character:FindFirstChild("NC_Luna_ESP")
    if not Highlight then
        Highlight = Instance.new("Highlight")
        Highlight.Name = "NC_Luna_ESP"
        Highlight.FillColor = Color3.fromRGB(174, 113, 255)
        Highlight.FillTransparency = 0.55
        Highlight.OutlineColor = Color3.fromRGB(152, 235, 255)
        Highlight.OutlineTransparency = 0
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.Parent = Character
    end

    Highlight.Enabled = true
end

local function preparePlayerESP(Player)
    if Player == LocalPlayer then
        return
    end

    Player.CharacterAdded:Connect(function()
        task.wait(0.35)
        if ESPEnabled then
            applyESP(Player)
        end
    end)
end

for _, Player in ipairs(Players:GetPlayers()) do
    preparePlayerESP(Player)
end

Players.PlayerAdded:Connect(preparePlayerESP)
Players.PlayerRemoving:Connect(removeESP)

Tabs.Visuales:CreateToggle({
    Name = "ESP de jugadores",
    Description = "Incluye jugadores que entren después",
    CurrentValue = false,
    Flag = "NC_Luna_ESP",
    Callback = function(State)
        ESPEnabled = State

        for _, Player in ipairs(Players:GetPlayers()) do
            if State then
                applyESP(Player)
            else
                removeESP(Player)
            end
        end
    end
})

-- =========================================================
-- SISTEMA
-- =========================================================
Tabs.Sistema:CreateSection("SISTEMA")

local AntiAFK = false

Tabs.Sistema:CreateToggle({
    Name = "Anti-AFK",
    Description = "Evita la inactividad",
    CurrentValue = false,
    Flag = "NC_Luna_AntiAFK",
    Callback = function(State)
        AntiAFK = State
    end
})

LocalPlayer.Idled:Connect(function()
    if AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

Tabs.Sistema:CreateButton({
    Name = "Abrir Dark Dex",
    Description = "Explorador de instancias",
    Callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"
        ))()
    end
})

Tabs.Sistema:CreateButton({
    Name = "Abrir SimpleSpy",
    Description = "Monitor de remotes",
    Callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"
        ))()
    end
})

Tabs.Sistema:CreateSection("PERFILES Y TEMA")
Tabs.Sistema:BuildConfigSection()
Tabs.Sistema:BuildThemeSection()

LocalPlayer.CharacterAdded:Connect(function(Character)
    task.wait(0.8)

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        Humanoid.WalkSpeed = SpeedValue
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = JumpValue
    end

    if FlyEnabled then
        startFly()
    end
end)

notify("NC HUB", "Universal Luna cargado", "check_circle")
