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

local Speed = 16
local Jump = 50
local InfiniteJump = false
local Noclip = false
local Fly = false
local FlySpeed = 60
local AntiAFK = false
local ESP = false

-- JUGADOR

PlayerTab:CreateSection("MOVIMIENTO")

PlayerTab:CreateSlider({
    Name = "Velocidad",
    Range = {16, 120},
    Increment = 1,
    CurrentValue = Speed,
    Flag = "NC_UniversalSpeed",
    Callback = function(Value)
        Speed = Value
        getHumanoid().WalkSpeed = Value
    end
})

PlayerTab:CreateSlider({
    Name = "Salto",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = Jump,
    Flag = "NC_UniversalJump",
    Callback = function(Value)
        Jump = Value
        local Humanoid = getHumanoid()
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = Value
    end
})

PlayerTab:CreateToggle({
    Name = "Salto infinito",
    CurrentValue = false,
    Flag = "NC_UniversalInfiniteJump",
    Callback = function(Value)
        InfiniteJump = Value == true
    end
})

UserInputService.JumpRequest:Connect(function()
    if InfiniteJump then
        getHumanoid():ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local OriginalCollision = {}

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NC_UniversalNoclip",
    Callback = function(Value)
        Noclip = Value == true
    end
})

RunService.Stepped:Connect(function()
    if Noclip then
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
end)

PlayerTab:CreateSection("FLY")

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

    local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        Humanoid.AutoRotate = true
        Humanoid.PlatformStand = false
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
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
    FlyVelocity.Parent = Root

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    FlyGyro.P = 35000
    FlyGyro.D = 900
    FlyGyro.Parent = Root

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Fly or not Root.Parent then
            return
        end

        local Camera = workspace.CurrentCamera
        if not Camera then
            return
        end

        local Move = PlayerControls and PlayerControls:GetMoveVector() or Humanoid.MoveDirection
        local Direction = Camera.CFrame.RightVector * Move.X + Camera.CFrame.LookVector * -Move.Z

        if Direction.Magnitude > 0.05 then
            Direction = Direction.Unit * FlySpeed
        else
            Direction = Vector3.zero
        end

        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        FlyVelocity.Velocity = Direction
        FlyGyro.CFrame = Camera.CFrame
    end)
end

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "NC_UniversalFly",
    Callback = function(Value)
        if Value then
            startFly()
        else
            stopFly()
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Velocidad Fly",
    Range = {20, 180},
    Increment = 1,
    CurrentValue = FlySpeed,
    Flag = "NC_UniversalFlySpeed",
    Callback = function(Value)
        FlySpeed = Value
    end
})

-- VISUAL

VisualTab:CreateSection("ESP")

local function removeESP(Player)
    local Character = Player.Character
    local Highlight = Character and Character:FindFirstChild("NC_ESP")

    if Highlight then
        Highlight:Destroy()
    end
end

local function applyESP(Player)
    if Player == LocalPlayer or not ESP or not Player.Character then
        return
    end

    local Highlight = Player.Character:FindFirstChild("NC_ESP")
    if not Highlight then
        Highlight = Instance.new("Highlight")
        Highlight.Name = "NC_ESP"
        Highlight.FillColor = Color3.fromRGB(174, 113, 255)
        Highlight.FillTransparency = 0.55
        Highlight.OutlineColor = Color3.fromRGB(152, 235, 255)
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.Parent = Player.Character
    end
end

local function prepareESP(Player)
    if Player == LocalPlayer then
        return
    end

    Player.CharacterAdded:Connect(function()
        task.wait(0.3)
        applyESP(Player)
    end)
end

for _, Player in ipairs(Players:GetPlayers()) do
    prepareESP(Player)
end

Players.PlayerAdded:Connect(prepareESP)
Players.PlayerRemoving:Connect(removeESP)

VisualTab:CreateToggle({
    Name = "ESP Jugadores",
    CurrentValue = false,
    Flag = "NC_UniversalESP",
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
})

-- SISTEMA

SystemTab:CreateSection("SISTEMA")

SystemTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "NC_UniversalAntiAFK",
    Callback = function(Value)
        AntiAFK = Value == true
    end
})

LocalPlayer.Idled:Connect(function()
    if AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

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
    Name = "Rejoin",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

SystemTab:CreateButton({
    Name = "Cerrar NC HUB",
    Callback = function()
        stopFly()
        Luna:Destroy()
    end
})

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.7)

    local Humanoid = getHumanoid()
    Humanoid.WalkSpeed = Speed
    Humanoid.UseJumpPower = true
    Humanoid.JumpPower = Jump

    if Fly then
        startFly()
    end
end)

notify("NC HUB", "Universal cargado", "check_circle")
