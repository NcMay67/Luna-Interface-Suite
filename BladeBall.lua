local CONFIG = {

    Version = 'v0.1.4',

    Name = 'MayOs',

    Game = 'Blade Ball',

    -- Interfaz: Luna Interface Suite
    UI_URL = 'https://raw.githubusercontent.com/NcMay67/Luna-Interface-Suite/refs/heads/master/source.lua',

}



--// [ ENVIRONMENT ] ---------------------------------------------------------

if typeof(getgenv) ~= 'function' then

    getgenv = function()

        return _G

    end

end



local ENV = getgenv()



if type(ENV.Ethereal_Version) == 'string' and ENV.Ethereal_Version ~= '' then

    CONFIG.Version = ENV.Ethereal_Version

end

ENV.Product_Version = CONFIG.Version



--// [ UI ] ------------------------------------------------------------------
-- La interfaz es Luna. Más abajo, el menú sigue usando la API "Create_*"
-- (Window:Create_Tab, Tab.Create_Toggle, ...); este adaptador la traduce a
-- Luna para que el menú y el motor no necesiten cambios.

local Got_UI, Luna = pcall(function()

    return loadstring(game:HttpGet(CONFIG.UI_URL))()

end)

if not Got_UI or type(Luna) ~= 'table' then

    error('[MayOs] no se pudo cargar Luna desde ' .. CONFIG.UI_URL .. ' — ' .. tostring(Luna), 0)

end



local Luna_Window = Luna:CreateWindow({

    Name = CONFIG.Name,

    Subtitle = CONFIG.Game .. '  |  ' .. CONFIG.Version,

    LogoID = '6031097225',

    LoadingEnabled = true,

    LoadingTitle = CONFIG.Name,

    LoadingSubtitle = 'Cargando ' .. CONFIG.Game .. '...',

    ConfigSettings = { ConfigFolder = 'MayOs_BladeBall' },

})

if not Luna_Window then

    error('[MayOs] Luna no pudo crear la ventana', 0)

end



-- Iconos Material por pestaña
local Tab_Icons = {

    Principal = 'gavel',

    Jugador = 'home',

    Visual = 'visibility',

    Varios = 'card_giftcard',

    ['Interfaz'] = 'settings',

    Pro = 'assessment',

}

local Notify_Icons = {

    Info = 'info',

    Success = 'check_circle',

    Warning = 'warning',

    Error = 'error',

}



local function Strip_Tags(Text)

    Text = tostring(Text or '')

    Text = Text:gsub('<br%s*/?>', '\n')

    Text = Text:gsub('<[^>]+>', '')

    return Text

end

local function Trim(Text)

    return (tostring(Text or ''):gsub('^%s+', ''):gsub('%s+$', ''))

end

local function Clamp_Number(Value, Min, Max)

    Value = tonumber(Value) or Min

    if Value < Min then

        return Min

    end

    if Value > Max then

        return Max

    end

    return Value

end

local function First_Option(Value)

    if type(Value) == 'table' then

        return Value[1]

    end

    return Value

end



local OPT = {
    ["Camera"] = "Cámara",
    ["Left"] = "Izquierda",
    ["Right"] = "Derecha",
    ["Up"] = "Arriba",
    ["Down"] = "Abajo",
    ["Straight"] = "Recto",
    ["Random"] = "Aleatorio",
    ["Super Curve Random"] = "Súper curva aleatoria",
    ["Normal"] = "Normal",
    ["Nearest"] = "Más cercano",
    ["Farest"] = "Más lejano",
    ["Mouse"] = "Ratón",
    ["Double Click"] = "Doble clic",
    ["Light"] = "Ligero",
    ["Fast"] = "Rápido",
    ["Turbo"] = "Turbo",
    ["Notification"] = "Notificación",
    ["Kick"] = "Desconectarme",
    ["Auto"] = "Auto",
    ["Custom"] = "Personalizado",
    ["Solid"] = "Sólido",
    ["Rainbow"] = "Arcoíris",
    ["PC"] = "PC",
    ["Mobile"] = "Móvil",
    ["Tablet"] = "Tableta",
    ["Console"] = "Consola",
    ["VR"] = "VR",
    ["Default"] = "Por defecto",
    ["Rectangle"] = "Rectángulo",
    ["Square"] = "Cuadrado",
    ["Circle"] = "Círculo",
    ["Name Only"] = "Solo nombre",
    ["Icon Only"] = "Solo icono",
}
local OPT_REV = {}
for Key, Label in pairs(OPT) do
    OPT_REV[Label] = Key
end

local function Make_Tab(Name, Icon)

    local Tab = Luna_Window:CreateTab({

        Name = Name,

        Icon = (Icon and Icon ~= '') and Icon or Tab_Icons[Name] or 'home',

        ImageSource = 'Material',

        ShowTitle = true,

    })

    local Host = Tab -- apartado actual (cada Create_Title abre uno nuevo)

    local Pending_Divider = false

    local Proxy = {}



    local function Flush_Divider()

        if Pending_Divider then

            Pending_Divider = false

            pcall(function()

                if type(Host.CreateDivider) == 'function' then

                    Host:CreateDivider()

                elseif type(Tab.CreateDivider) == 'function' then

                    Tab:CreateDivider()

                end

            end)

        end

    end



    -- Crea un control en el apartado actual (o en la pestaña si el apartado no lo soporta).
    -- Ethereal dispara el callback una vez al crear con el valor inicial para sincronizar
    -- Cfg; si Luna no lo hace, se dispara aquí.
    local function Create(Method, Settings, Flag, Callback, Initial, Fire_Initial, Normalize)

        Flush_Divider()

        local Fired = false

        Settings.Callback = function(...)

            Fired = true

            if type(Callback) ~= 'function' then

                return

            end

            local Value = ...

            if Normalize then

                Value = Normalize(Value)

            end

            local Ok, Err = pcall(Callback, Value)

            if not Ok then

                warn('[MayOs] callback error (' .. tostring(Settings.Name) .. '): ' .. tostring(Err))

            end

        end



        local Target = Host

        if type(Target[Method]) ~= 'function' then

            Target = Tab

        end

        local Ok, Control = pcall(function()

            return Target[Method](Target, Settings, Flag)

        end)

        if not Ok then

            warn('[MayOs] could not create ' .. tostring(Settings.Name) .. ': ' .. tostring(Control))

            Control = nil

        end



        if Fire_Initial and not Fired and type(Callback) == 'function' then

            local Ok2, Err2 = pcall(Callback, Initial)

            if not Ok2 then

                warn('[MayOs] callback error (' .. tostring(Settings.Name) .. '): ' .. tostring(Err2))

            end

        end

        return Control

    end



    local function Labelled(Name_, Badge)

        Name_ = tostring(Name_ or '')

        if Badge and Badge ~= '' then

            Name_ = Name_ .. '  [' .. tostring(Badge) .. ']'

        end

        return Name_

    end



    function Proxy.Create_Title(Opts)

        Pending_Divider = false

        local Ok, Section = pcall(function()

            return Tab:CreateSection(tostring(Opts.name or ''))

        end)

        Host = (Ok and Section) or Tab

    end



    function Proxy.Create_Divider()

        Pending_Divider = true

    end



    function Proxy.Create_Paragraph(Opts)

        Flush_Divider()

        local Text = Strip_Tags(Opts.content)

        if Text == '' then

            Text = ' '

        end

        pcall(function()

            local Target = Host

            if type(Target.CreateParagraph) ~= 'function' then

                Target = Tab

            end

            Target:CreateParagraph({ Title = Labelled(Opts.title, Opts.badge), Text = Text })

        end)

    end



    function Proxy.Create_Toggle(Opts)

        local Initial = Opts.enabled == true

        return Create('CreateToggle', {

            Name = Labelled(Opts.name, Opts.badge),

            Description = Opts.info,

            CurrentValue = Initial,

        }, Opts.flag, Opts.callback, Initial, true)

    end



    function Proxy.Create_Slider(Opts)

        local Min = Opts.min or 0

        local Max = Opts.max or 100

        local Initial = Clamp_Number(Opts.default, Min, Max)

        local Name_ = Labelled(Opts.name, Opts.badge)

        local Suffix = Trim(Opts.suffix)

        if Suffix ~= '' then

            Name_ = Name_ .. ' (' .. Suffix .. ')'

        end

        return Create('CreateSlider', {

            Name = Name_,

            Description = Opts.info,

            Range = { Min, Max },

            Increment = Opts.step or 1,

            CurrentValue = Initial,

        }, Opts.flag, Opts.callback, Initial, true)

    end



    function Proxy.Create_Dropdown(Opts)

        local Raw = Opts.options or {}

        local Options = {}

        for Index, Value in ipairs(Raw) do

            Options[Index] = OPT[Value] or Value

        end

        local Initial = First_Option(Opts.default)

        if Initial == nil then

            Initial = Raw[1]

        end

        return Create('CreateDropdown', {

            Name = Labelled(Opts.name, Opts.badge),

            Description = Opts.info,

            Options = Options,

            CurrentOption = { OPT[Initial] or Initial },

            MultipleOptions = false,

        }, Opts.flag, Opts.callback, Initial, true, function(Value)

            Value = First_Option(Value)

            return OPT_REV[Value] or Value

        end)

    end



    function Proxy.Create_Button(Opts)

        return Create('CreateButton', {

            Name = Labelled(Opts.name, Opts.badge),

            Description = Opts.info,

        }, nil, Opts.callback, nil, false)

    end



    function Proxy.Create_Textbox(Opts)

        local Initial = tostring(Opts.default or '')

        return Create('CreateInput', {

            Name = Labelled(Opts.name, Opts.badge),

            Description = Opts.info,

            PlaceholderText = Opts.placeholder or '',

            CurrentValue = Initial,

            MaxCharacters = Opts.max_length,

            Numeric = false,

            Enter = false,

        }, Opts.flag, Opts.callback, Initial, true)

    end



    function Proxy.Create_Color_Picker(Opts)

        local Initial = Opts.default or Color3.fromRGB(255, 255, 255)

        return Create('CreateColorPicker', {

            Name = Labelled(Opts.name, Opts.badge),

            Color = Initial,

        }, Opts.flag, Opts.callback, Initial, true)

    end



    return Proxy

end



-- Borra archivos de configuración guardados por Luna (carpeta ConfigFolder).
local function Delete_Saved_Configs(Only_This_Place)
    local Count = 0
    if type(isfolder) ~= 'function' or type(listfiles) ~= 'function' or type(delfile) ~= 'function' then
        return 0
    end
    local Roots = { 'MayOs_BladeBall', 'Luna/MayOs_BladeBall', 'Luna/configs/MayOs_BladeBall', 'Luna/Configs/MayOs_BladeBall' }
    local function Walk(Folder)
        local Ok, Files = pcall(listfiles, Folder)
        if not Ok then
            return
        end
        for _, File in ipairs(Files) do
            if type(isfolder) == 'function' and isfolder(File) then
                Walk(File)
            elseif not Only_This_Place or string.find(File, tostring(game.PlaceId), 1, true) then
                if pcall(delfile, File) then
                    Count = Count + 1
                end
            end
        end
    end
    for _, Root in ipairs(Roots) do
        if isfolder(Root) then
            Walk(Root)
        end
    end
    return Count
end


local Library = {

    Luna = Luna,

    Notify = function(Opts)

        Opts = type(Opts) == 'table' and Opts or {}

        pcall(function()

            Luna:Notification({

                Title = tostring(Opts.Title or CONFIG.Name),

                Icon = Notify_Icons[Opts.Kind or 'Info'] or 'info',

                ImageSource = 'Material',

                Content = tostring(Opts.Description or ''),

                Duration = tonumber(Opts.Duration),

            })

        end)

    end,

}

local Notify = Library.Notify

local Window = {

    Luna = Luna_Window,

    Create_Tab = function(_, Name, Icon)

        return Make_Tab(tostring(Name), Icon)

    end,

}



--// [ MENU ] ---------------------------------------------------------------

local Create_Menu = (function()

--[[

    MayOs — menú

    ─────────────────────────────────────────────────────────────────────────

    Builds the Ethereal window for the auto-parry engine and owns the single

    shared config table the engine reads every frame.



    Every control is bound to one Cfg field, so moving a slider or picking a

    dropdown entry takes effect on the next parry / frame with no restart.

    Ethereal's own config autosave already persists the flag values, and the

    control callbacks fire once on creation with the restored value, which

    keeps Cfg in sync on load.



    Usage (inside the built bundle):

        local App = Create_Menu({ Library = Library, Window = Window })

        -- App.Cfg, App.Log

]]



return function(Env)

    local Library = Env.Library

    local Window = Env.Window



    --// [ CONFIG ] — shared with the engine --------------------------------

    -- Every control below writes exactly one field here; the engine reads Cfg

    -- live on the next frame, so no control needs a restart.

    local Cfg = {

        -- Auto Parry

        AutoParry = true,

        Accuracy = 80,

        Cooldown = 5,

        CurveMode = 'Camera',

        TargetMode = 'Normal',

        CooldownProtection = true,

        apearly = true,



        -- ability detection

        DetectInfinity      = false,

        DetectDeathSlash    = false,

        DetectTimeHole      = false,

        DetectSlashesOfFury = false,

        DetectTornado       = false,

        AutoAbility         = false,



        -- staff detection

        StaffDetection  = false,

        StaffActionMode = 'Notification',

        StaffGroupId    = 12836673,

        StaffMinRank    = 10,

        StaffScanPulse  = 0,



        -- triggerbot / pre-click

        Triggerbot     = false,

        PreClick       = false,

        PreClickRange  = 30,

        PreClickSpeed  = 1,



        -- win options

        CustomWin      = false,

        WinMessage     = 'MayOs',

        KillMessage    = 'MayOs',

        CustomWinstreak = false,

        Winstreak      = '1',



        -- avatar options

        Headless  = false,

        Korblox   = false,



        --  player options

        FOVEnabled = false,

        FOV        = 70,



        

        ImmortalEnabled   = false,

        ImmortalV1        = false,

        ImmortalV2        = true,

        ImmortalMode      = 'Auto',

        ImmortalAngle     = 145,

        ImmortalRadius    = 10,

        ImmortalHeightMin = -8,

        ImmortalHeightMax = 35,



        

        SkinChanger = false,

        SkinName    = '',



        

        SlashColor      = false,

        SlashColorMode  = 'Solid',

        SlashColorValue = Color3.fromRGB(255, 0, 0),





        ManualSpam      = false,

        ManualSpamKey   = Enum.KeyCode.P,

        ManualSpamStyle = 'Default',   -- 'Default' | 'Rectangle' | 'Square' | 'Circle'

        SpamSpeedMode   = 'Normal',    -- 'Light'|'Normal'|'Fast'|'Turbo'

        AutoSpam        = false,

        CPS             = 60,

        SpamThreshold   = 1,



        

        DeviceTarget           = 'PC',

        DeviceSpoofPulse       = 0,

        DeviceSpoofRejoinPulse = 0,



        espability = false,

        ESPStyle          = 'Default',  -- 'Default' | 'Name Only' | 'Icon Only'

        BallStatus        = false,

        TriggerParryGap   = 3,    -- units, 1=0.01s — min gap before trigger-parry fires again

        AutoCooldownMode          = false,

        Reward_Claim_Daily_Rewards    = false,

        Reward_Claim_Playtime_Rewards = false,



        -- performance

        AntiLag         = false,

        NoRender        = false,

        __AntiLagPulse  = 0,

        __NoRenderPulse = 0,



        -- player movement (from normal.txt)

        SpeedEnabled     = false,

        SpeedValue       = 32,

        JumpEnabled      = false,

        JumpValue        = 100,

        FlyEnabled       = false,

        FlySpeed         = 50,

        AutoJumpEnabled  = false,

        NoclipEnabled    = false,

        FreecamEnabled   = false,

        FreecamSpeed     = 50,

        AntiAFKEnabled   = false,

        AntiAFKInterval  = 28,



        -- manual spam floating switch builder (injected by engine)

        __BuildFloatingSwitch = nil,

    }

    



    --// [ NOTIFICATIONS ] --------------------------------------------------

    -- Engine events are routed here. Identical text is rate limited so a

    -- failing network path on every frame cannot flood the screen.

    local Recent = {}

    local Recent_Count = 0

    local function Log(Kind, Title, Message, Duration)

        local Key = tostring(Kind) .. '|' .. tostring(Title) .. '|' .. tostring(Message)

        local Now = os.clock()

        if Recent[Key] and (Now - Recent[Key]) < 4 then

            return

        end

        if Recent[Key] == nil then

            Recent_Count = Recent_Count + 1

        end

        Recent[Key] = Now

        if Recent_Count > 200 then

            Recent = {}

            Recent_Count = 0

            Recent[Key] = Now

            Recent_Count = 1

        end



        pcall(function()

            Library.Notify({

                Title = tostring(Title or 'MayOs'),

                Description = tostring(Message or ''),

                Kind = Kind or 'Info',

                Duration = Duration or 5,

            })

        end)

    end



    --// [ MAIN SECTION ] ---------------------------------------------------

    -- The menu is four top-level tabs: Main, Player, Visual and Misc.

    -- Ethereal's tab bar is flat (one horizontal, left-aligned strip) and tabs

    -- have no left/right placement, so the "tabs" inside each section are

    -- rendered as titled column sections instead: Auto Parry on the left,

    -- AutoSpam and Detection on the right.

    local Main = Window:Create_Tab('Principal', '')



    --// [ MAIN > AUTO PARRY ] ----------------------------------------------

    Main.Create_Title({ name = 'Auto Parry' })

    

    Main.Create_Toggle({

        name = 'Auto Parry',

        info = 'Activa o pone en reposo el motor de auto parry.',

        flag = 'Ethereal_AP_Enabled',

        enabled = Cfg.AutoParry,

        callback = function(Value)

            Cfg.AutoParry = Value

        end,

    })



    Main.Create_Divider({})



    Main.Create_Slider({

        name = 'Precisión',

        info = 'Ventana de reacción usada para temporizar el parry.',

        flag = 'Ethereal_AP_Accuracy',

        min = 1,

        max = 100,

        step = 1,

        default = Cfg.Accuracy,

        suffix = '%',

        callback = function(Value)

            Cfg.Accuracy = Value

        end,

    })



    Main.Create_Slider({

        name = 'Enfriamiento',

        flag = 'Ethereal_AP_Cooldown',

        min = 1,

        max = 10,

        step = 0.1,

        default = math.floor((Cfg.Cooldown or 0.5) * 100 + 0.5),

        suffix = '',

        callback = function(Value)

            -- 1 unit = 0.01s  (100 = 1.00s)

            Cfg.Cooldown = Value * 0.01

        end,

    })



    Main.Create_Toggle({

        name = 'Protección de enfriamiento',

        info = 'Reinicia automáticamente el bloqueo si sigue bloqueado.',

        flag = 'Ethereal_AP_Cooldown_Protection',

        enabled = Cfg.CooldownProtection,

        callback = function(Value)

            Cfg.CooldownProtection = Value

        end,

    })

    

    Main.Create_Toggle({

        name = 'Anticipado',

        info = 'sin parry anticipado',

        flag = 'Ethereal_AP_Early_Parry',

        enabled = Cfg.apearly,

        callback = function(Value)

            Cfg.apearly = Value

        end,

    })



    Main.Create_Divider({})



    Main.Create_Dropdown({

        name = 'Modo de curva',

        flag = 'Ethereal_AP_Curve_Mode',

        options = {

            'Camera',

            'Left',

            'Right',

            'Up',

            'Down',

            'Straight',

            'Random',

            'Super Curve Random',

            'Normal',

        },

        default = Cfg.CurveMode,

        callback = function(Value)

            Cfg.CurveMode = Value

        end,

    })



    Main.Create_Dropdown({

        name = 'Modo de objetivo',

        flag = 'Ethereal_AP_Target_Mode',

        options = {

            'Normal',

            'Nearest',

            'Farest',

            'Mouse',

            'Double Click',

        },

        default = Cfg.TargetMode,

        callback = function(Value)

            Cfg.TargetMode = Value

        end,

    })



    Main.Create_Divider({})



    Main.Create_Title({ name = 'Auto habilidad' })

    



    Main.Create_Toggle({

        name = 'Auto habilidad',

        info = 'Usa tu habilidad equipada en lugar de un parry desperdiciado.',

        flag = 'Ethereal_Auto_Ability',

        enabled = Cfg.AutoAbility,

        callback = function(Value) Cfg.AutoAbility = Value end,

    })



    Main.Create_Divider({})



    Main.Create_Title({ name = 'Triggerbot' })

    Main.Create_Paragraph({

        title = 'Triggerbot',

        content = 'Lanza un parry en el instante en que una bola te apunta, saltándose la ventana de reacción normal.',

        badge = 'Popular',

    })



    Main.Create_Toggle({

        name = 'Triggerbot',

        info = 'Parry instantáneo cuando una bola te apunta.',

        flag = 'Ethereal_Triggerbot',

        enabled = Cfg.Triggerbot,

        callback = function(Value) Cfg.Triggerbot = Value end,

    })



    Main.Create_Divider({})



    Main.Create_Title({ name = 'Pre-clic' })

    Main.Create_Paragraph({

        title = 'Pre-clic',

        content = 'Lanza un parry cuando el servidor informa de una eliminación cercana.',

        badge = 'Info',

    })



    Main.Create_Toggle({

        name = 'Pre-clic',

        info = 'Parry cuando un jugador cercano es eliminado.',

        flag = 'Ethereal_PreClick',

        enabled = Cfg.PreClick,

        callback = function(Value) Cfg.PreClick = Value end,

    })



    Main.Create_Slider({

        name = 'Alcance del pre-clic',

        info = 'Solo hace pre-clic en eliminaciones dentro de este radio.',

        flag = 'Ethereal_PreClick_Range',

        min = 5,

        max = 100,

        step = 1,

        default = Cfg.PreClickRange,

        suffix = ' studs',

        callback = function(Value) Cfg.PreClickRange = Value end,

    })



    Main.Create_Slider({

        name = 'Velocidad mínima del pre-clic',

        info = 'Solo hace pre-clic cuando la bola más rápida alcanza al menos esta velocidad.',

        flag = 'Ethereal_PreClick_Speed',

        min = 1,

        max = 200,

        step = 1,

        default = Cfg.PreClickSpeed,

        callback = function(Value) Cfg.PreClickSpeed = Value end,

    })



    --// [ MAIN > AUTOSPAM ] (right column) ---------------------------------

    --// SPAM — right column

    Main.Create_Title({ name = 'Spam', section = 'right' })



    Main.Create_Toggle({

        name = 'Spam manual',

        info = 'Interruptor flotante (tecla V): lanza el remoto sin importar el alcance ni las condiciones.',

        flag = 'Ethereal_Manual_Spam',

        enabled = Cfg.ManualSpam,

        section = 'right',

        callback = function(Value)

            Cfg.ManualSpam = Value

            local CG = game:GetService('CoreGui')

            local sg = CG:FindFirstChild('StellarFloatingToggle')

            if sg then

                sg.Enabled = Value

            elseif Value and typeof(Cfg.__BuildFloatingSwitch) == 'function' then

                Cfg.__BuildFloatingSwitch()

            end

        end,

    })



    

    Main.Create_Dropdown({

        name = 'Velocidad de spam',

        flag = 'Ethereal_Spam_Speed_Mode',

        section = 'right',

        options = { 'Light', 'Normal', 'Fast', 'Turbo' },

        default = Cfg.SpamSpeedMode or 'Normal',

        callback = function(Value)

            Cfg.SpamSpeedMode = Value

            local map = { Light = 60, Normal = 100, Fast = 250, Turbo = 430 }

            Cfg.CPS = map[Value] or 60

        end,

    })



    Main.Create_Toggle({

        name = 'Auto spam',

        info = 'Hace spam cuando estás cerca de un rival y haciendo parry activamente.',

        flag = 'Ethereal_Auto_Spam',

        enabled = Cfg.AutoSpam,

        section = 'right',

        callback = function(Value) Cfg.AutoSpam = Value end,

    })



    Main.Create_Slider({

        name = 'CPS',

        flag = 'Ethereal_Spam_CPS',

        min = 1,

        max = 200,

        step = 1,

        default = Cfg.CPS,

        section = 'right',

        callback = function(Value)

            Cfg.CPS = Value

            -- Snap SpamSpeedMode label to closest preset

            if Value <= 60 then Cfg.SpamSpeedMode = 'Light'

            elseif Value <= 100 then Cfg.SpamSpeedMode = 'Normal'

            elseif Value <= 250 then Cfg.SpamSpeedMode = 'Fast'

            else Cfg.SpamSpeedMode = 'Turbo' end

        end,

    })



    Main.Create_Slider({

        name = 'Umbral de spam',

        flag = 'Ethereal_Spam_Threshold',

        min = 0.5,

        max = 5,

        step = 0.1,

        default = Cfg.SpamThreshold,

        section = 'right',

        callback = function(Value) Cfg.SpamThreshold = Value end,

    })



    --// [ MAIN > DETECTION ] (right column) --------------------------------

    Main.Create_Divider({ section = 'right' })



    Main.Create_Title({ name = 'Detección', section = 'right' })

    Main.Create_Paragraph({

        title = 'Detección de habilidades',

        content = 'Mientras una habilidad de abajo esté activa, el auto parry ignora la bola. Slashes of Fury sigue haciendo parry si se usa. Solo funcionan con <b>Auto Parry</b> activado.',

        badge = 'Nuevo',

        section = 'right',

    })



    Main.Create_Toggle({

        name = 'Detección de Infinity',

        info = 'Ignora la bola mientras Infinity Ball esté activa.',

        flag = 'Ethereal_Detect_Infinity',

        enabled = Cfg.DetectInfinity,

        section = 'right',

        callback = function(Value) Cfg.DetectInfinity = Value end,

    })



    Main.Create_Toggle({

        name = 'Detección de Death Slash',

        info = 'Ignora la bola mientras Death Ball esté activa.',

        flag = 'Ethereal_Detect_DeathSlash',

        enabled = Cfg.DetectDeathSlash,

        section = 'right',

        callback = function(Value) Cfg.DetectDeathSlash = Value end,

    })



    Main.Create_Toggle({

        name = 'Detección de Time Hole',

        info = 'Ignora la bola mientras TimeHoleActivate esté activo.',

        flag = 'Ethereal_Detect_TimeHole',

        enabled = Cfg.DetectTimeHole,

        section = 'right',

        callback = function(Value) Cfg.DetectTimeHole = Value end,

    })



    Main.Create_Toggle({

        name = 'Detección de Slashes of Fury',

        info = 'Sigue FuryCatch y hace parry en ráfaga a la habilidad.',

        flag = 'Ethereal_Detect_SlashesOfFury',

        enabled = Cfg.DetectSlashesOfFury,

        section = 'right',

        callback = function(Value) Cfg.DetectSlashesOfFury = Value end,

    })



    Main.Create_Toggle({

        name = 'Detección de Tornado',

        info = 'Ignora una bola mientras AeroDynamic Slash / Tornado esté activo.',

        flag = 'Ethereal_Detect_Tornado',

        enabled = Cfg.DetectTornado,

        section = 'right',

        callback = function(Value) Cfg.DetectTornado = Value end,

    })



    --// [ MAIN > STAFF DETECTION ] (right column) -------------------------

    

    Main.Create_Divider({ section = 'right' })



    Main.Create_Title({ name = 'Detección de staff', section = 'right' })

    Main.Create_Paragraph({

        title = 'Vigilancia de moderación',

        content = 'Comprueba el rango de cada jugador en el grupo del staff y te avisa cuando hay un moderador del grupo en la sesión. <b>Desconectarme</b> te saca de la partida al instante en lugar de avisarte.',

        badge = 'Nuevo',

        section = 'right',

    })



    Main.Create_Toggle({

        name = 'Detección de staff',

        info = 'Vigila la sesión en busca de miembros del staff.',

        flag = 'Ethereal_Staff_Detection',

        enabled = Cfg.StaffDetection,

        section = 'right',

        callback = function(Value) Cfg.StaffDetection = Value end,

    })



    Main.Create_Dropdown({

        name = 'Acción ante staff',

        info = 'Qué hacer cuando se encuentra a un miembro del staff.',

        flag = 'Ethereal_Staff_Action_Mode',

        options = { 'Notification', 'Kick' },

        default = Cfg.StaffActionMode,

        section = 'right',

        callback = function(Value) Cfg.StaffActionMode = Value end,

    })



    Main.Create_Button({

        name = 'Escanear servidor actual',

        info = 'Revisa el rango de staff de todos los que están en el servidor.',

        flag = 'Ethereal_Staff_Scan',

        section = 'right',

        callback = function()

            Cfg.StaffScanPulse = (Cfg.StaffScanPulse or 0) + 1

        end,

    })



    --// [ PLAYER SECTION ] -------------------------------------------------

    -- The local avatar and its camera live here: Immortality V1/V2 + Field of

    -- View on the left, Headless/Korblox on the right. Sword cosmetics moved

    -- to their own Visual tab.

    local Player = Window:Create_Tab('Jugador', '')



    --// [ PLAYER > IMMORTALITY ] ------------------------------------------

    Player.Create_Title({ name = 'Inmortalidad' })

    Player.Create_Paragraph({

        title = 'Desincronización V1 + V2',

        content = '<b>Arriesgado</b>: no es un modo dios real. <b>V2</b> mueve tu raíz en órbita con un flujo de envíos de físicas; <b>V1</b> lanza un triángulo Virex. Cualquiera puede desincronizarte y sacarte del mapa: úsalo bajo tu responsabilidad.',

        badge = 'Riesgo',

    })



    Player.Create_Toggle({

        name = 'Inmortal',

        info = 'Activa el módulo de inmortalidad. Arriesgado.',

        badge = 'Riesgo',

        flag = 'Ethereal_Immortal',

        enabled = Cfg.ImmortalEnabled,

        callback = function(Value) Cfg.ImmortalEnabled = Value end,

    })



    Player.Create_Toggle({

        name = 'V2 — Desincronización orbital',

        info = 'Desincronización orbital con parpadeo de altura mín./máx.',

        flag = 'Ethereal_Immortal_V2',

        enabled = Cfg.ImmortalV2,

        callback = function(Value) Cfg.ImmortalV2 = Value end,

    })



    Player.Create_Toggle({

        name = 'V1 — Triángulo',

        info = 'Desincronización por lanzamiento de triángulo (tiene prioridad sobre V2).',

        flag = 'Ethereal_Immortal_V1',

        enabled = Cfg.ImmortalV1,

        callback = function(Value) Cfg.ImmortalV1 = Value end,

    })



    Player.Create_Dropdown({

        name = 'Modo de inmortalidad',

        info = 'Auto bloquea el ángulo de órbita; Personalizado usa el slider de abajo.',

        flag = 'Ethereal_Immortal_Mode',

        options = { 'Auto', 'Custom' },

        default = Cfg.ImmortalMode,

        callback = function(Value) Cfg.ImmortalMode = Value end,

    })



    Player.Create_Slider({

        name = 'Ángulo personalizado',

        info = 'Velocidad angular de la órbita en modo Personalizado.',

        flag = 'Ethereal_Immortal_Angle',

        min = 0,

        max = 360,

        step = 1,

        default = Cfg.ImmortalAngle,

        callback = function(Value) Cfg.ImmortalAngle = Value end,

    })



    Player.Create_Slider({

        name = 'Radio de órbita',

        info = 'Radio de la órbita, en studs.',

        flag = 'Ethereal_Immortal_Radius',

        min = 1,

        max = 100,

        step = 1,

        default = Cfg.ImmortalRadius,

        callback = function(Value) Cfg.ImmortalRadius = Value end,

    })



    Player.Create_Slider({

        name = 'Altura mínima',

        info = 'Extremo inferior de altura, en studs.',

        flag = 'Ethereal_Immortal_Height_Min',

        min = -50,

        max = 0,

        step = 1,

        default = Cfg.ImmortalHeightMin,

        callback = function(Value) Cfg.ImmortalHeightMin = Value end,

    })



    Player.Create_Slider({

        name = 'Altura máxima',

        info = 'Extremo superior de altura, en studs.',

        flag = 'Ethereal_Immortal_Height_Max',

        min = 0,

        max = 270,

        step = 1,

        default = Cfg.ImmortalHeightMax,

        callback = function(Value) Cfg.ImmortalHeightMax = Value end,

    })



    Player.Create_Divider({})



    --// [ PLAYER > FIELD OF VIEW ] ----------------------------------------

    Player.Create_Title({ name = 'Campo de visión' })

    Player.Create_Paragraph({

        title = 'Cámara',

        content = 'Sustituye el FieldOfView de la cámara mientras <b>FOV activado</b> esté encendido. El valor original se restaura al desactivarlo.',

        badge = 'Info',

    })



    Player.Create_Toggle({

        name = 'FOV activado',

        info = 'Sustituye el FieldOfView de la cámara.',

        flag = 'Ethereal_FOV_Enabled',

        enabled = Cfg.FOVEnabled,

        callback = function(Value) Cfg.FOVEnabled = Value end,

    })



    Player.Create_Slider({

        name = 'FOV',

        info = 'FieldOfView de la cámara mientras esté activado.',

        flag = 'Ethereal_FOV',

        min = 30,

        max = 120,

        step = 1,

        default = Cfg.FOV,

        callback = function(Value) Cfg.FOV = Value end,

    })



    Player.Create_Divider({})



    --// [ PLAYER > MOVEMENT — LEFT ] Walk Speed / Jump / Fly + Auto Jump

    Player.Create_Title({ name = 'Movimiento' })



    Player.Create_Toggle({

        name = 'Velocidad al caminar',

        info = 'Sustituye el WalkSpeed del Humanoid.',

        flag = 'Ethereal_Speed_Enabled',

        enabled = Cfg.SpeedEnabled,

        callback = function(Value) Cfg.SpeedEnabled = Value end,

    })



    Player.Create_Slider({

        name = 'Valor de velocidad',

        flag = 'Ethereal_Speed_Value',

        min = 1,

        max = 250,

        step = 1,

        default = Cfg.SpeedValue,

        callback = function(Value) Cfg.SpeedValue = Value end,

    })



    Player.Create_Divider({})



    Player.Create_Toggle({

        name = 'Potencia de salto',

        info = 'Sustituye el JumpPower del Humanoid.',

        flag = 'Ethereal_Jump_Enabled',

        enabled = Cfg.JumpEnabled,

        callback = function(Value) Cfg.JumpEnabled = Value end,

    })



    Player.Create_Slider({

        name = 'Valor de salto',

        flag = 'Ethereal_Jump_Value',

        min = 1,

        max = 500,

        step = 1,

        default = Cfg.JumpValue,

        callback = function(Value) Cfg.JumpValue = Value end,

    })



    Player.Create_Divider({})



    Player.Create_Toggle({

        name = 'Volar',

        info = 'Vuelo con BodyVelocity. Espacio = subir, Ctrl izq. = bajar.',

        flag = 'Ethereal_Fly_Enabled',

        enabled = Cfg.FlyEnabled,

        callback = function(Value) Cfg.FlyEnabled = Value end,

    })



    Player.Create_Slider({

        name = 'Velocidad de vuelo',

        flag = 'Ethereal_Fly_Speed',

        min = 5,

        max = 300,

        step = 5,

        default = Cfg.FlySpeed,

        callback = function(Value) Cfg.FlySpeed = Value end,

    })



    Player.Create_Divider({})



    Player.Create_Toggle({

        name = 'Auto salto',

        info = 'Dispara status.jump en cada tick de Heartbeat.',

        flag = 'Ethereal_Auto_Jump',

        enabled = Cfg.AutoJumpEnabled,

        callback = function(Value) Cfg.AutoJumpEnabled = Value end,

    })



    --// [ PLAYER > MOVEMENT — RIGHT ] Noclip / Freecam / Anti-AFK

    Player.Create_Title({ name = 'Movimiento adicional', section = 'right' })



    Player.Create_Toggle({

        name = 'Noclip',

        info = 'Desactiva CanCollide en todas las partes del personaje.',

        flag = 'Ethereal_Noclip',

        section = 'right',

        enabled = Cfg.NoclipEnabled,

        callback = function(Value) Cfg.NoclipEnabled = Value end,

    })



    Player.Create_Divider({ section = 'right' })



    Player.Create_Toggle({

        name = 'Cámara libre',

        info = 'Cámara scriptable. WASD + ratón, E/Q = subir/bajar.',

        flag = 'Ethereal_Freecam',

        section = 'right',

        enabled = Cfg.FreecamEnabled,

        callback = function(Value) Cfg.FreecamEnabled = Value end,

    })



    Player.Create_Slider({

        name = 'Velocidad de cámara libre',

        flag = 'Ethereal_Freecam_Speed',

        section = 'right',

        min = 5,

        max = 300,

        step = 5,

        default = Cfg.FreecamSpeed,

        callback = function(Value) Cfg.FreecamSpeed = Value end,

    })



    Player.Create_Divider({ section = 'right' })



    Player.Create_Toggle({

        name = 'Anti-AFK',

        info = 'Salta periódicamente para evitar la expulsión por inactividad.',

        flag = 'Ethereal_Anti_AFK',

        section = 'right',

        enabled = Cfg.AntiAFKEnabled,

        callback = function(Value) Cfg.AntiAFKEnabled = Value end,

    })



    Player.Create_Slider({

        name = 'Intervalo AFK',

        flag = 'Ethereal_Anti_AFK_Interval',

        section = 'right',

        min = 5,

        max = 120,

        step = 1,

        default = Cfg.AntiAFKInterval,

        suffix = ' s',

        callback = function(Value) Cfg.AntiAFKInterval = Value end,

    })



    Player.Create_Divider({ section = 'right' })



    --// [ PLAYER > COSMETICS ] (right column, continues) -----------------

    Player.Create_Title({ name = 'Avatar', section = 'right' })

    Player.Create_Paragraph({

        title = 'Avatar local',

        content = 'Solo en tu cliente. <b>Sin cabeza</b> oculta la cabeza; <b>Korblox</b> cambia la malla de la pierna derecha. Ambos se reaplican tras cada reaparición.',

        badge = 'Nuevo',

        section = 'right',

    })



    Player.Create_Toggle({

        name = 'Sin cabeza',

        info = 'Oculta tu cabeza localmente.',

        flag = 'Ethereal_Headless',

        enabled = Cfg.Headless,

        section = 'right',

        callback = function(Value) Cfg.Headless = Value end,

    })



    Player.Create_Toggle({

        name = 'Korblox',

        info = 'Aplica la pierna derecha Korblox.',

        flag = 'Ethereal_Korblox',

        enabled = Cfg.Korblox,

        section = 'right',

        callback = function(Value) Cfg.Korblox = Value end,

    })



    Player.Create_Divider({ section = 'right' })



    --// [ VISUAL SECTION ] ------------------------------------------------

    -- Cosmetic, client-side overrides only: the sword skin changer in the

    -- left column and the sword-slash colour picker in the right.

    local Visual = Window:Create_Tab('Visual', '')



    --// [ VISUAL > SKIN CHANGER ] -----------------------------------------

    Visual.Create_Title({ name = 'Cambiador de skins' })

    Visual.Create_Paragraph({

        title = 'Cosméticos de espada',

        content = 'Te equipa la espada indicada y reescribe sus efectos de tajo en los remotos de parry. <b>El nombre debe coincidir exactamente</b> con una espada del juego. Las skins de Backsword requieren llevar una Backsword equipada.',

        badge = 'Popular',

    })



    Visual.Create_Toggle({

        name = 'Cambiador de skins',

        info = 'Sustituye el modelo, la animación y los efectos de tu espada equipada.',

        flag = 'Ethereal_Skin_Changer',

        enabled = Cfg.SkinChanger,

        callback = function(Value) Cfg.SkinChanger = Value end,

    })



    Visual.Create_Textbox({

        name = 'Nombre de la skin',

        info = 'Nombre de la espada (distingue mayúsculas).',

        flag = 'Ethereal_Skin_Name',

        default = Cfg.SkinName,

        placeholder = 'Escribe el nombre de la skin...',

        max_length = 60,

        callback = function(Value) Cfg.SkinName = Value end,

    })



    --// [ VISUAL > SWORD SLASH COLOR ] (right column) ---------------------

    Visual.Create_Title({ name = 'Color del tajo de espada', section = 'right' })

    Visual.Create_Paragraph({

        title = 'Tajo coloreable',

        content = 'Recolorea tus propios efectos de tajo <b>ParryFX</b>. <b>Sólido</b> usa el selector de color; <b>Arcoíris</b> y <b>Aleatorio</b> cambian continuamente.',

        badge = 'Nuevo',

        section = 'right',

    })



    Visual.Create_Toggle({

        name = 'Tajo de espada coloreable',

        info = 'Recolorea tus efectos de tajo ParryFX.',

        flag = 'Ethereal_Slash_Color',

        enabled = Cfg.SlashColor,

        section = 'right',

        callback = function(Value) Cfg.SlashColor = Value end,

    })



    Visual.Create_Dropdown({

        name = 'Modo de color del tajo',

        flag = 'Ethereal_Slash_Mode',

        options = { 'Solid', 'Rainbow', 'Random' },

        default = Cfg.SlashColorMode,

        section = 'right',

        callback = function(Value) Cfg.SlashColorMode = Value end,

    })



    Visual.Create_Color_Picker({

        name = 'Color del tajo',

        flag = 'Ethereal_Slash_Value',

        default = Cfg.SlashColorValue,

        section = 'right',

        callback = function(Value) Cfg.SlashColorValue = Value end,

    })

    

    Visual.Create_Toggle({

        name = 'Desbloquear todo el inventario',

        info = 'Desbloquea todas las espadas, explosiones, emotes y remates.',

        flag = 'Ethereal_Unlock_All',

        enabled = false,

        callback = function(Value)

            if _G._UnlockAllHook then

                -- already loaded — toggle directly

                pcall(_G._UnlockAllHook.Toggle, Value)

                return

            end



            if not Value then return end  -- user turned OFF before script loaded — nothing to do



            -- load async so the UI thread doesn't freeze

            task.spawn(function()

                local ok, err = pcall(function()

                    loadstring(game:HttpGet(

                        "https://raw.githubusercontent.com/foreverspacexc-blip/Illusion/refs/heads/main/unlock_all.txt"

                    ))()

                end)

                if not ok then

                    Log('Error', 'Desbloquear todo', 'Error al cargar: ' .. tostring(err))

                    return

                end

                -- poll up to 3s for the hook to register

                local deadline = os.clock() + 3

                while os.clock() < deadline do

                    if _G._UnlockAllHook then

                        pcall(_G._UnlockAllHook.Toggle, Value)

                        return

                    end

                    task.wait(0.05)

                end

                Log('Warning', 'Desbloquear todo', 'El hook no se registró tras la carga.')

            end)

        end,

    })

    

    Visual.Create_Toggle({

        name = 'ESP de habilidades',

        info = 'Muestra en pantalla las habilidades activas de los enemigos.',

        flag = 'Ethereal_ESP_Ability',

        enabled = Cfg.espability,

        callback = function(Value)

            Cfg.espability = Value

            

            if typeof(SetESPAbility) == "function" then

                pcall(SetESPAbility)

            end

        end,

    })



    --// [ MISC SECTION ] ---------------------------------------------------

    

    local Misc = Window:Create_Tab('Varios', '')



    -- Performance

    Misc.Create_Title({ name = 'Rendimiento' })

    Misc.Create_Paragraph({

        title = 'Anti-lag + Sin renderizado',

        content = '<b>Anti-lag</b> baja la calidad de iluminación, desactiva atmósfera/nubes/post-FX y suprime las sombras: más FPS sin eliminar geometría. <b>Sin renderizado</b> oculta partículas, calcomanías, haces y GUIs del mundo fuera de los modelos de jugadores. Ambos se restauran al desactivarlos.',

        badge = 'Nuevo',

    })

    Misc.Create_Toggle({

        name = 'Anti-lag',

        info = 'Calidad nivel 1; desactiva GlobalShadows, Atmosphere, Clouds, Bloom, Blur, DOF y SunRays.',

        flag = 'Ethereal_Anti_Lag',

        enabled = Cfg.AntiLag,

        callback = function(Value)

            Cfg.AntiLag = Value

            Cfg.__AntiLagPulse = (Cfg.__AntiLagPulse or 0) + 1

        end,

    })

    Misc.Create_Toggle({

        name = 'Sin renderizado',

        info = 'Suprime partículas, calcomanías, haces, estelas y GUIs del mundo para reducir el coste de renderizado.',

        flag = 'Ethereal_No_Render',

        enabled = Cfg.NoRender,

        callback = function(Value)

            Cfg.NoRender = Value

            Cfg.__NoRenderPulse = (Cfg.__NoRenderPulse or 0) + 1

        end,

    })

    Misc.Create_Divider({})



    Misc.Create_Title({ name = 'Suplantador de dispositivo' })

    Misc.Create_Paragraph({

        title = 'Suplantación',

        content = 'Elige el dispositivo que quieres simular y aplica. El suplantador se guarda en tu carpeta de autoejecución, se ejecuta al instante y puede reentrar para que se aplique en la siguiente sesión.',

        badge = 'Popular',

    })



    Misc.Create_Dropdown({

        name = 'Dispositivo',

        info = 'Perfil de dispositivo que informa el cliente.',

        flag = 'Ethereal_Device_Target',

        options = { 'PC', 'Mobile', 'Tablet', 'Console', 'VR' },

        default = Cfg.DeviceTarget,

        callback = function(Value) Cfg.DeviceTarget = Value end,

    })



    Misc.Create_Button({

        name = 'Aplicar suplantador de dispositivo',

        info = 'Ejecuta ahora el suplantador de dispositivo elegido.',

        flag = 'Ethereal_Device_Spoof',

        callback = function()

            Cfg.DeviceSpoofPulse = (Cfg.DeviceSpoofPulse or 0) + 1

        end,

    })



    Misc.Create_Button({

        name = 'Aplicar + reentrar',

        info = 'Suplanta y reentra en el servidor actual.',

        flag = 'Ethereal_Device_Spoof_Rejoin',

        callback = function()

            Cfg.DeviceSpoofRejoinPulse = (Cfg.DeviceSpoofRejoinPulse or 0) + 1

        end,

    })



    Misc.Create_Title({ name = 'Victoria personalizada', section = 'right' })

    Misc.Create_Paragraph({

        title = 'Mensajes personalizados',

        content = 'Sustituye el texto de ganador / eliminado del anunciador y el contador de racha de victorias. Los valores se aplican en cuanto cambia la etiqueta.',

        badge = 'Nuevo',

        section = 'right',

    })



    Misc.Create_Toggle({

        name = 'Mensaje de victoria personalizado',

        info = 'Reemplaza el texto de ganador / eliminado del anunciador.',

        flag = 'Ethereal_Custom_Win',

        enabled = Cfg.CustomWin,

        section = 'right',

        callback = function(Value) Cfg.CustomWin = Value end,

    })



    Misc.Create_Textbox({

        name = 'Mensaje de victoria',

        info = 'Se muestra en la etiqueta de ganador.',

        flag = 'Ethereal_Win_Message',

        default = Cfg.WinMessage,

        placeholder = 'MayOs',

        max_length = 60,

        section = 'right',

        callback = function(Value) Cfg.WinMessage = Value end,

    })



    Misc.Create_Textbox({

        name = 'Mensaje de eliminación',

        info = 'Se muestra en la etiqueta de eliminado.',

        flag = 'Ethereal_Kill_Message',

        default = Cfg.KillMessage,

        placeholder = 'MayOs',

        max_length = 60,

        section = 'right',

        callback = function(Value) Cfg.KillMessage = Value end,

    })



    Misc.Create_Divider({ section = 'right' })



    Misc.Create_Toggle({

        name = 'Racha de victorias personalizada',

        info = 'Fuerza el contador de racha de victorias del juego.',

        flag = 'Ethereal_Custom_Winstreak',

        enabled = Cfg.CustomWinstreak,

        section = 'right',

        callback = function(Value) Cfg.CustomWinstreak = Value end,

    })



    Misc.Create_Textbox({

        name = 'Racha de victorias',

        info = 'Valor mostrado en WinStreakDisplay.',

        flag = 'Ethereal_Winstreak',

        default = Cfg.Winstreak,

        placeholder = '1',

        max_length = 8,

        section = 'right',

        callback = function(Value) Cfg.Winstreak = Value end,

    })



    --// [ GUI TAB ] -------------------------------------------------------

    local Gui = Window:Create_Tab('Interfaz', '')



    --// [ GUI > MANUAL SPAM STYLE ] left column

    Gui.Create_Title({ name = 'Estilo del spam manual' })

    Gui.Create_Paragraph({

        title = 'Aspecto del interruptor flotante',

        content = '<b>Por defecto</b>: tarjeta SPAM original. <b>Rectángulo</b>: píldora ancha y plana, cian. <b>Cuadrado</b>: insignia cuadrada, morada. <b>Círculo</b>: insignia circular, naranja.',

        badge = 'Nuevo',

    })



    Gui.Create_Dropdown({

        name = 'Estilo de spam',

        flag = 'Ethereal_Spam_Style',

        options = { 'Default', 'Rectangle', 'Square', 'Circle' },

        default = Cfg.ManualSpamStyle,

        callback = function(Value)

            Cfg.ManualSpamStyle = Value

            local CG = game:GetService('CoreGui')

            local sg = CG:FindFirstChild('StellarFloatingToggle')

            if sg then sg:Destroy() end

            if Cfg.ManualSpam and typeof(Cfg.__BuildFloatingSwitch) == 'function' then

                Cfg.__BuildFloatingSwitch()

            end

        end,

    })



    --// [ GUI > ESP STYLE ] right column

    Gui.Create_Title({ name = 'Estilo del ESP de habilidades', section = 'right' })

    Gui.Create_Paragraph({

        title = 'Diseño del cartel',

        content = '<b>Por defecto</b>: icono + nombre + enfriamiento.\n<b>Solo nombre</b>: solo nombre + texto de enfriamiento.\n<b>Solo icono</b>: solo el icono de la habilidad.',

        badge = 'Nuevo',

        section = 'right',

    })



    Gui.Create_Dropdown({

        name = 'Estilo de ESP',

        flag = 'Ethereal_ESP_Style',

        section = 'right',

        options = { 'Default', 'Name Only', 'Icon Only' },

        default = Cfg.ESPStyle,

        callback = function(Value)

            Cfg.ESPStyle = Value

            if typeof(SetESPAbility) == 'function' then

                pcall(SetESPAbility)

            end

        end,

    })



    --// [ GUI > REWARDS ]

    Gui.Create_Divider({})

    Gui.Create_Title({ name = 'Auto recompensas' })

    Gui.Create_Paragraph({

        title = 'Reclamo automático de recompensas',

        content = 'Reclama automáticamente las recompensas disponibles en cada intervalo. Incluye inicio de sesión diario y recompensas de tiempo de juego y misiones. No incluye recompensas de eventos.',

        badge = 'Nuevo',

    })



    Gui.Create_Toggle({

        name = 'Auto reclamar diaria',

        info = 'Reclama la recompensa diaria de inicio de sesión cuando esté disponible.',

        flag = 'Ethereal_Reward_Daily',

        enabled = Cfg.Reward_Claim_Daily_Rewards,

        callback = function(Value)

            Cfg.Reward_Claim_Daily_Rewards = Value

            if typeof(Cfg.__RewardToggle) == 'function' then

                Cfg.__RewardToggle()

            end

        end,

    })



    Gui.Create_Toggle({

        name = 'Auto reclamar tiempo de juego',

        info = 'Reclama las recompensas de tiempo de juego cuando acaba el temporizador.',

        flag = 'Ethereal_Reward_Playtime',

        enabled = Cfg.Reward_Claim_Playtime_Rewards,

        callback = function(Value)

            Cfg.Reward_Claim_Playtime_Rewards = Value

            if typeof(Cfg.__RewardToggle) == 'function' then

                Cfg.__RewardToggle()

            end

        end,

    })



    Gui.Create_Toggle({

        name = 'Auto reclamar misiones',

        info = 'Reclama las misiones diarias completadas.',

        flag = 'Ethereal_Reward_Quests',

        enabled = Cfg.Reward_Claim_Quest_Rewards or false,

        callback = function(Value)

            Cfg.Reward_Claim_Quest_Rewards = Value

            if typeof(Cfg.__RewardToggle) == 'function' then

                Cfg.__RewardToggle()

            end

        end,

    })



    --// [ GUI > SAVE / UTILITY ]

    Gui.Create_Divider({})

    Gui.Create_Title({ name = 'Gestión de guardado' })



    Gui.Create_Button({

        name = 'Borrar guardado (esta versión)',

        info = 'Borra solo la configuración guardada del PlaceId actual.',

        flag = 'Ethereal_Delete_Save_This',

        callback = function()

            local Count = Delete_Saved_Configs(true)

            Log('Success', 'Guardado', 'Archivos de configuración borrados: ' .. tostring(Count), 3)

        end,

    })



    Gui.Create_Button({

        name = 'Borrar guardado (todas las versiones)',

        info = 'Borra todas las configuraciones guardadas de MayOs.',

        flag = 'Ethereal_Delete_Save_All',

        callback = function()

            local Count = Delete_Saved_Configs(false)

            Log('Success', 'Guardado', 'Archivos de configuración borrados: ' .. tostring(Count), 3)

        end,

    })



    Gui.Create_Divider({})

    Gui.Create_Title({ name = 'Sesión', section = 'right' })



    Gui.Create_Button({

        name = 'Reentrar',

        info = 'Reentra en el mismo servidor (conserva el PlaceId).',

        flag = 'Ethereal_Rejoin',

        section = 'right',

        callback = function()

            Log('Info', 'Reentrar', 'Reentrando...', 2)

            task.delay(0.5, function()

                pcall(function()

                    local TeleportService = game:GetService('TeleportService')

                    TeleportService:Teleport(game.PlaceId, game:GetService('Players').LocalPlayer)

                end)

            end)

        end,

    })



    Gui.Create_Button({

        name = 'Cambiar de servidor',

        info = 'Te lleva a otro servidor al azar.',

        flag = 'Ethereal_Server_Hop',

        section = 'right',

        badge = 'Nuevo',

        callback = function()

            Log('Info', 'Cambiar de servidor', 'Buscando un servidor nuevo...', 2)

            task.spawn(function()

                pcall(function()

                    local TeleportService = game:GetService('TeleportService')

                    local HttpService     = game:GetService('HttpService')

                    local PlaceId         = game.PlaceId

                    local LP_             = game:GetService('Players').LocalPlayer

                    -- ดึงรายการ server จาก Roblox API

                    local url = 'https://games.roblox.com/v1/games/' .. tostring(PlaceId) .. '/servers/Public?sortOrder=Asc&limit=100'

                    local ok, res = pcall(function() return game:HttpGet(url) end)

                    if not ok or not res then

                        -- fallback: teleport ไป PlaceId เดิมใน server ใหม่

                        TeleportService:Teleport(PlaceId, LP_)

                        return

                    end

                    local data = HttpService:JSONDecode(res)

                    local servers = data and data.data

                    if not servers or #servers == 0 then

                        TeleportService:Teleport(PlaceId, LP_)

                        return

                    end

                    -- กรอง server ที่ไม่ใช่ server ปัจจุบัน

                    local current = game.JobId

                    local candidates = {}

                    for _, s in ipairs(servers) do

                        if s.id and s.id ~= current and s.playing < s.maxPlayers then

                            table.insert(candidates, s.id)

                        end

                    end

                    if #candidates == 0 then

                        TeleportService:Teleport(PlaceId, LP_)

                        return

                    end

                    local picked = candidates[math.random(1, #candidates)]

                    TeleportService:TeleportToPlaceInstance(PlaceId, picked, LP_)

                end)

            end)

        end,

    })



    --// [ GUI > BALL STATUS ] — billboard เหนือบอล

    Gui.Create_Divider({})

    Gui.Create_Title({ name = 'Estado de la bola' })

    Gui.Create_Paragraph({

        title = 'Cartel de la bola',

        content = 'Muestra un BillboardGui sobre la bola con objetivo, velocidad, origen y distancia en tiempo real.',

        badge = 'Nuevo',

    })



    Gui.Create_Toggle({

        name = 'Cartel de estado de la bola',

        info = 'Muestra siempre la información de la bola flotando sobre ella.',

        flag = 'Ethereal_Ball_Status',

        enabled = Cfg.BallStatus,

        callback = function(Value) Cfg.BallStatus = Value end,

    })



    --// [ PRO TAB ] -------------------------------------------------------

    local Pro = Window:Create_Tab('Pro', '')



    Pro.Create_Title({ name = 'Trigger y tiempos' })

    Pro.Create_Paragraph({

        title = 'Intervalo del parry por trigger',

        content = 'Intervalo mínimo entre disparos del parry por trigger. 1 unidad = 0,01 s. Menor = más agresivo; mayor = más seguro contra el doble parry. Sustituye el mínimo fijo de 0,03 s.',

        badge = 'Pro',

    })



    Pro.Create_Slider({

        name = 'Intervalo del parry por trigger',

        flag = 'Ethereal_Pro_Trigger_Gap',

        min = 1,

        max = 10,

        step = 1,

        default = Cfg.TriggerParryGap,

        callback = function(Value)

            Cfg.TriggerParryGap = Value

        end,

    })



    Pro.Create_Divider({})

    Pro.Create_Title({ name = 'Auto enfriamiento', section = 'right' })

    Pro.Create_Paragraph({

        title = 'Fin de enfriamiento inteligente',

        content = 'Si está activado, el script comprueba cada fotograma y desbloquea el parry en cuanto termina el enfriamiento del servidor: la ventana más rápida posible sin disparar dos veces. Requiere la Protección de enfriamiento activada.',

        badge = 'Pro',

        section = 'right',

    })



    Pro.Create_Toggle({

        name = 'Auto enfriamiento',

        info = 'Termina el bloqueo de enfriamiento lo antes posible sin riesgo de doble parry.',

        flag = 'Ethereal_Pro_Auto_Cooldown',

        section = 'right',

        enabled = Cfg.AutoCooldownMode,

        callback = function(Value)

            Cfg.AutoCooldownMode = Value

        end,

    })



    Pro.Create_Divider({ section = 'right' })

    Pro.Create_Title({ name = 'Información de depuración', section = 'right' })

    Pro.Create_Paragraph({

        title = 'Valores en vivo de BallState',

        content = 'Todos los campos de BallState (targetMe, speed, dist, isTraining) se pueden leer desde la consola con getgenv().MayOsBallState.',

        section = 'right',

    })



    return { Cfg = Cfg, Log = Log }

end

end)()



--// [ ENGINE ] -------------------------------------------------------------

local Create_AP = (function()



return function(Env)

    local Cfg = Env.Cfg

    local Log = Env.Log



    local cloneref = cloneref or function(x) return x end





    local RS          = cloneref(game:GetService("ReplicatedStorage"))

    local Players     = cloneref(game:GetService("Players"))

    local RunService  = cloneref(game:GetService("RunService"))

    local UIS         = cloneref(game:GetService("UserInputService"))

    local Stats       = cloneref(game:GetService("Stats"))

    local CollectionService = cloneref(game:GetService("CollectionService"))

    local LP          = Players.LocalPlayer



    --=================================================================

    -- UTILS

    --=================================================================

    local function GetPing()

        local ok, v = pcall(function()

            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()

        end)

        return ok and v or LP:GetNetworkPing() * 1000

    end



    local function GetChar() return LP.Character end

    local function GetHRP(c) return c and c.PrimaryPart or (c and c:FindFirstChild("HumanoidRootPart")) end

    local function GetHum(c) return c and c:FindFirstChildOfClass("Humanoid") end



    local parryLocked    = {}

    local lockTime       = {}

    local lastHitTick    = {}

    local lastParryTime  = 0

    local activeParryTasks = {}

    local SpamParries    = {}

    local SpamParryTime  = 0

    local flyteBBState   = { AutoParryAt = 0 }



    --=================================================================

    -- BALLSTATE — ตัวแปรกลาง single source of truth

    -- อ่านได้จากทุก system ไม่ต้องตรวจ attribute ซ้ำ

    --=================================================================

    local BallState = {

        haveBall   = false,   -- มีบอลใน Balls/TrainingBalls

        targetMe   = false,   -- บอล target เราอยู่

        targetName = '',      -- ชื่อ target ปัจจุบัน

        ball       = nil,     -- reference บอลที่ target เรา (หรือใกล้สุด)

        speed      = 0,

        dist       = 0,

        isTraining = false,   -- กำลังใช้ TrainingBalls แทน Balls

    }



    --=================================================================

    -- PARRYLOCK GATE — single write, all systems stop immediately

    -- ระบบไหนเรียก Unlock_Parry(ball) ก่อน ระบบอื่นหยุดทันที

    -- ป้องกัน double-fire และ race condition

    --=================================================================

    local _lockSeq = {}  -- [ball] = sequence number ณ ตอนที่ lock



    local function Lock_Parry(ball, now)

        parryLocked[ball] = true

        lockTime[ball]    = now or os.clock()

        _lockSeq[ball]    = (_lockSeq[ball] or 0) + 1

        -- ยกเลิก task unlock เก่า

        if activeParryTasks[ball] then

            task.cancel(activeParryTasks[ball])

            activeParryTasks[ball] = nil

        end

        return _lockSeq[ball]

    end



    local function Unlock_Parry(ball, seq)

        -- ถ้า seq ไม่ตรง = มี lock ใหม่มาแทนแล้ว ไม่ unlock

        if seq ~= nil and _lockSeq[ball] ~= seq then return end

        parryLocked[ball] = false

        lockTime[ball]    = 0

        if lastHitTick then lastHitTick[ball] = 0 end

        if activeParryTasks and activeParryTasks[ball] then

            task.cancel(activeParryTasks[ball])

            activeParryTasks[ball] = nil

        end

    end



    --  rolling parry history. Every parry sent (auto-parry, triggerbot,

    -- pre-click, manual spam or AutoSpam) is counted for 0.5 s and then

    -- decays. AutoSpam requires more than one recent parry, so it reinforces

    -- active parrying instead of flooding the server while idle.

    local Parry_History = { Count = 0, Times = {} }

    local function Record_Parry()

        if Parry_History.Count <= 7 then

            Parry_History.Count = Parry_History.Count + 1

            table.insert(Parry_History.Times, os.clock() + 0.5)

        end

    end



    local function Expire_Parry_History()

        local Now = os.clock()

        for Index = #Parry_History.Times, 1, -1 do

            if Now >= Parry_History.Times[Index] then

                table.remove(Parry_History.Times, Index)

                if Parry_History.Count > 0 then

                    Parry_History.Count = Parry_History.Count - 1

                end

            end

        end

    end



    --=================================================================

    -- BYPASS — Byte createParrySender + Oxy PRY fallback

    --=================================================================

    local sendParry       = nil

    local _reverted       = {}

    local _tokenize       = nil

    local _firstSignal    = nil

    local _bypassReady    = false



    -- Method A: Byte direct capture (hookfunction)

    pcall(function()

        local parryFunction = require(RS.Controllers["SwordsController \12"].PRY)

        local encoder = debug.getupvalue(parryFunction, 4)

        local hash    = debug.getupvalue(parryFunction, 8)

        local playerData = require(RS.Packages.Replion).Client:WaitReplion("Data")

        local serverInfo  = require(RS.ServerInfo)

        local universeIds = require(RS.Shared.UniverseIds)

        local durations = {1.5, 1.25, 1, 0.75, 0.625}

        local signal = require(RS.Packages.Signal).new()

        signal:Connect(parryFunction)



        local capturedRemote, capturedKey, capturedTimeKey = nil, nil, nil

        local timeHash = {}



        local noobParry = not serverInfo.isDungeonsMatchServer()

            and game.PlaceId ~= universeIds.RankedMatches.PlaceId

            and game.PlaceId ~= universeIds.RankedMatchesNoAbility.PlaceId

            and not serverInfo.isMedalServer()

            and not serverInfo.isClanWarServer()

            and not serverInfo.isTournamentMatchServer()

            and require(RS.Common.Utils).FFlag.GetInstantFFlag("NoobParryEnabled", true)



        local function capture(event, eventHash, eventKey, proof, duration, direction, targets, aim, flag)

            if eventHash == hash and type(eventKey) == "string" and type(proof) == "string"

                and type(duration) == "number" and typeof(direction) == "CFrame"

                and type(targets) == "table" and type(aim) == "table" and type(flag) == "boolean" then

                capturedRemote, capturedKey = event, eventKey

                _bypassReady = true

            end

        end



        local fireServer

        fireServer = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(event, ...)

            if not capturedRemote and not checkcaller() then

                capture(event, ...)

            end

            return fireServer(event, ...)

        end))



        sendParry = function(direction, targets, aim)

            local kills = playerData:Get("TotalStats.Kills") or 0

            local duration = durations[(playerData:Get("timesParried") or 0) + 1] or 0.5

            if noobParry then

                duration = kills < 20 and duration * kills / 20 or duration

            end

            if not capturedKey then

                signal:Fire(duration, direction, targets, aim, false)

                return true

            end

            capturedTimeKey = capturedTimeKey or encoder(capturedKey, "TIME")

            local stamp = tostring(math.floor(workspace:GetServerTimeNow() * 100))

            table.clear(timeHash)

            for i = 1, #stamp do

                timeHash[i] = string.char(bit32.bxor(

                    (string.byte(stamp, i) + i) % 256,

                    string.byte(capturedTimeKey, (i - 1) % #capturedTimeKey + 1)

                ))

            end

            fireServer(capturedRemote, hash, capturedKey, table.concat(timeHash), duration, direction, targets, aim, false)

            return true

        end

        Log('Success', 'Bypass', 'Captura de bytes activa: los parries se envían directamente.')

    end)



    -- Method B: Oxy PRY fallback

    if not sendParry then

        pcall(function()

            for _, fn in pairs(getgc(true)) do

                if type(fn) ~= "function" then continue end

                if not debug.info(fn, "s"):find("PRY", 1, true) then continue end

                for _, v in pairs(debug.getupvalues(fn)) do

                    if type(v) == "function" then

                        local tkFn = v

                        _tokenize = function(uid)

                            local time = tostring(math.floor(workspace:GetServerTimeNow() * 100))

                            local key  = tkFn(uid, "TIME")

                            local out  = table.create(#time)

                            for i = 1, #time do

                                out[i] = string.char(bit32.bxor(

                                    (string.byte(time, i) + i) % 256,

                                    string.byte(key, (i-1) % #key + 1)

                                ))

                            end

                            return table.concat(out)

                        end

                        break

                    end

                end

                if _tokenize then break end

            end



            local eCapture = { captured = {}, hooked = {}, originals = {} }

            eCapture.valid = function(a)

                return #a == 8 and type(a[2]) == "string" and type(a[3]) == "string"

                    and type(a[4]) == "number" and typeof(a[5]) == "CFrame"

                    and type(a[6]) == "table" and type(a[7]) == "table" and type(a[8]) == "boolean"

            end

            eCapture.unhook = function()

                for mt, orig in pairs(eCapture.originals) do

                    pcall(function() setreadonly(mt, false); mt.__index = orig; setreadonly(mt, true) end)

                end

            end

            eCapture.hook = function(remote)

                if next(eCapture.captured) ~= nil then return end

                local mt = getrawmetatable(remote)

                if eCapture.hooked[mt] then return end

                eCapture.hooked[mt] = true

                setreadonly(mt, false)

                local index = mt.__index

                eCapture.originals[mt] = index

                mt.__index = function(self, key)

                    if (key == "FireServer" and self:IsA("RemoteEvent")) or

                       (key == "InvokeServer" and self:IsA("RemoteFunction")) then

                        return function(_, ...)

                            local args = { ... }

                            if eCapture.valid(args) then

                                eCapture.captured[self] = args

                                _reverted = eCapture.captured

                                eCapture.unhook()

                                _bypassReady = true

                            end

                            return index(self, key)(_, unpack(args))

                        end

                    end

                    return index(self, key)

                end

                setreadonly(mt, true)

            end

            for _, v in pairs(RS:GetDescendants()) do

                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then eCapture.hook(v) end

            end

            task.spawn(function()

                local pkg = RS:FindFirstChild("Packages")

                local ctrl = RS:FindFirstChild("Controllers")

                if not pkg or not ctrl then return end

                local sc = ctrl:FindFirstChild("SwordsController \12")

                if not sc then return end

                pcall(function()

                    local Signal = require(pkg:WaitForChild("Signal", 10))

                    local PRY    = require(sc.PRY)

                    _firstSignal = Signal.new()

                    _firstSignal:Connect(PRY)

                    task.wait(0.5)

                    if next(eCapture.captured) == nil then

                        _firstSignal:Fire(0.5, CFrame.new(), {}, {0, 0}, false)

                    end

                end)

            end)

            Log('Success', 'Bypass', 'Alternativa Oxy activa: ruta de señal PRY capturada.')

        end)

    end



    --=================================================================

    -- FORCE TARGET / DOUBLE CLICK 

    --=================================================================

    local ForceTargetPlayer = nil

    local LastClickTime     = 0



    local function ForceTarget()

        local alive = workspace:FindFirstChild("Alive")

        local char  = GetChar()

        local hrp   = GetHRP(char)

        if not alive or not hrp then return nil end



        -- Double Click: aim at double-clicked player

        if Cfg.TargetMode == "Double Click" and ForceTargetPlayer then

            local tc = alive:FindFirstChild(ForceTargetPlayer)

            if tc and tc ~= char then return tc end

        end



        -- Nearest: closest enemy

        if Cfg.TargetMode == "Nearest" then

            local best, bestD = nil, math.huge

            for _, c2 in ipairs(alive:GetChildren()) do

                if c2 ~= char and c2.PrimaryPart then

                    local d = (hrp.Position - c2.PrimaryPart.Position).Magnitude

                    if d < bestD then bestD = d; best = c2 end

                end

            end

            return best

        end



        -- Farest: furthest enemy — aim curve at the player farthest away

        if Cfg.TargetMode == "Farest" then

            local best, worstD = nil, -1

            for _, c2 in ipairs(alive:GetChildren()) do

                if c2 ~= char and c2.PrimaryPart then

                    local d = (hrp.Position - c2.PrimaryPart.Position).Magnitude

                    if d > worstD then worstD = d; best = c2 end

                end

            end

            return best

        end



        -- Mouse: aim toward wherever the mouse is pointing in world-space

        -- Returns a synthetic "target" struct with a PrimaryPart at mouse hit position

        -- CalcCurveDir reads target.PrimaryPart.Position so we fake it with a CFrame-based part

        if Cfg.TargetMode == "Mouse" then

            local cam = workspace.CurrentCamera

            local mouse = game:GetService("Players").LocalPlayer:GetMouse()

            if cam and mouse then

                local unitRay = cam:ScreenPointToRay(mouse.X, mouse.Y)

                local raycastParams = RaycastParams.new()

                raycastParams.FilterType = Enum.RaycastFilterType.Exclude

                -- exclude local character so ray doesn't hit self

                local myChar = GetChar()

                if myChar then

                    raycastParams.FilterDescendantsInstances = {myChar}

                end

                local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 2000, raycastParams)

                local hitPos = result and result.Position or (unitRay.Origin + unitRay.Direction * 500)

                -- Return a fake target table that CalcCurveDir can read

                return { PrimaryPart = { Position = hitPos } }

            end

            return nil

        end



        return nil

    end



    -- Curve direction calculation

    local function CalcCurveDir(ball, target)

        local camera = workspace.CurrentCamera

        local char = game.Players.LocalPlayer.Character

        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        local currentMode = Cfg.CurveMode or "Camera"

        local lookV = camera.CFrame.LookVector

        local upV = camera.CFrame.UpVector

        local rightV = camera.CFrame.RightVector

        

        if currentMode == "Camera" then

            return lookV

        elseif currentMode == "Left" then

            return (-rightV * 150000 + (lookV * 0.001)).Unit

        elseif currentMode == "Right" then

            return (rightV * 150000 + (lookV * 0.001)).Unit

        elseif currentMode == "Up" then

            return (upV * 85000 + (lookV * 0.001)).Unit

        elseif currentMode == "Down" then

            return (-upV * 85000 + (lookV * 0.001)).Unit

        elseif currentMode == "Straight" then

            if hrp then

                return (hrp.CFrame.LookVector * 250000).Unit

            end

            return lookV

        elseif currentMode == "Random" then

            local randomSpread = Vector3.new(math.random(-50000, 50000), math.random(-25000, 75000), math.random(-50000, 50000)).Unit

            return (lookV + (randomSpread * 350000)).Unit

        elseif currentMode == "Super Curve Random" then

            local choices = {-rightV * 450000, rightV * 450000, upV * 250000, -upV * 250000}

            local picked = choices[math.random(1, #choices)]

            return (picked + (lookV * 0.001)).Unit



        elseif currentMode == "Normal" then

            --[[

                Normal mode — adaptive logic:



                CONDITION A (long range + fast):

                  คนที่ใกล้สุดอยู่ใน Alive ห่าง > 60 studs จากเรา

                  AND ball speed > 400

                  → 80% Straight

                  → 20% สุ่มระหว่าง: backward, sky, backward+sky

                

                CONDITION B (ไม่ครบ condition A):

                  → 40% Camera

                  → 60% Random

            ]]

            local function GetNearestAliveDistFromUs()

                local aliveF = workspace:FindFirstChild("Alive")

                if not aliveF or not hrp then return math.huge end

                local best = math.huge

                for _, c2 in ipairs(aliveF:GetChildren()) do

                    if c2 ~= char and c2.PrimaryPart then

                        local d = (hrp.Position - c2.PrimaryPart.Position).Magnitude

                        if d < best then best = d end

                    end

                end

                return best

            end



            local nearestDist = GetNearestAliveDistFromUs()

            local ballSpeed   = 0

            if ball then

                local z = ball:FindFirstChildOfClass("LinearVelocity") or ball:FindFirstChild("zoomies")

                if z then

                    ballSpeed = (z.VectorVelocity or z.Velocity or Vector3.zero).Magnitude

                end

            end



            local conditionA = (nearestDist > 60) and (ballSpeed > 400)



            if conditionA then

                -- 80% Straight, 20% สุ่ม

                local r = math.random(1, 100)

                if r <= 80 then

                    -- Straight: ตรงไปข้างหน้าตาม HRP

                    if hrp then

                        return (hrp.CFrame.LookVector * 250000).Unit

                    end

                    return lookV

                else

                    -- 20% สุ่มระหว่าง 3 แบบ

                    local pick = math.random(1, 3)

                    if pick == 1 then

                        -- Backward

                        if hrp then

                            return (-hrp.CFrame.LookVector * 250000).Unit

                        end

                        return (-lookV * 250000).Unit

                    elseif pick == 2 then

                        -- Sky (up)

                        return (upV * 200000 + lookV * 0.001).Unit

                    else

                        -- Backward + Sky

                        if hrp then

                            return ((-hrp.CFrame.LookVector * 150000) + (upV * 150000)).Unit

                        end

                        return ((-lookV * 150000) + (upV * 150000)).Unit

                    end

                end

            else

                -- Condition B: 40% Camera, 60% Random

                local r = math.random(1, 100)

                if r <= 40 then

                    return lookV  -- Camera

                else

                    local randomSpread = Vector3.new(

                        math.random(-50000, 50000),

                        math.random(-25000, 75000),

                        math.random(-50000, 50000)

                    ).Unit

                    return (lookV + (randomSpread * 350000)).Unit

                end

            end

        end

        

        xpcall(function()

            if ball and target and target.PrimaryPart then

                return ((target.PrimaryPart.Position - ball.Position).Unit * 500000).Unit

            end

        end, function(err)

            Log('Error', 'Trayectoria', 'Falló el cálculo de la curva: ' .. tostring(err))

        end)

        

        return lookV

    end



    -- Build snap map

    local function BuildSnap()

        local cam   = workspace.CurrentCamera

        local snap  = {}

        local alive = workspace:FindFirstChild("Alive")

        if alive and cam then

            for _, c2 in ipairs(alive:GetChildren()) do

                local p2 = c2.PrimaryPart or c2:FindFirstChild("HumanoidRootPart")

                if p2 then

                    local sp = cam:WorldToScreenPoint(p2.Position)

                    if sp.Z > 0 then snap[c2.Name] = sp end

                end

            end

        end

        return snap

    end



    --=================================================================

    -- FIRE PARRY

    --=================================================================

    local function FireParry(ball, isSpam)

        local cam = workspace.CurrentCamera

        if not cam then 

            Log('Error', 'Cámara', 'No se encontró CurrentCamera.')

            return 

        end

        local target = ForceTarget()

        local char = GetChar()

        local hrp = GetHRP(char)

        local alive = workspace:FindFirstChild("Alive")

        

        local curveDirectionVector = CalcCurveDir(ball, target)

        local finalCF = CFrame.lookAt(cam.CFrame.Position, cam.CFrame.Position + curveDirectionVector)



        local snap = BuildSnap()

       



    -- ── ปรับตัวอักษรตัวเล็ก-ใหญ่ให้ตรงกับอันเก่า ──

    gamePositionsSnapshot = {}

    if cam and alive then

        local mode = Cfg.TargetMode

        local isNormalOrMouse = (mode == "Normal" or mode == "Mouse")



        if isNormalOrMouse then

            -- โหมด Normal หรือ Mouse: ใส่ทุกคนใน alive ตามปกติ

            for _, character in ipairs(alive:GetChildren()) do

                if character:IsA("Model") and character.PrimaryPart then

                    screenPos, onScreen = cam:WorldToScreenPoint(character.PrimaryPart.Position)

                    gamePositionsSnapshot[character.Name] = screenPos

                end

            end

        else

            -- โหมดอื่นๆ: ใส่ข้อมูลเฉพาะคนที่เรา target เท่านั้น

            local targetChar = ForceTarget()

            if targetChar and targetChar:IsA("Model") and targetChar.PrimaryPart then

                screenPos, onScreen = cam:WorldToScreenPoint(targetChar.PrimaryPart.Position)

                gamePositionsSnapshot[targetChar.Name] = screenPos

            end

        end

    end



        -- Determine aim point: Mouse mode = actual mouse screen pos; everything else = viewport center

        local aimPoint

        if Cfg.TargetMode == "Mouse" then

            local mouse = game:GetService("Players").LocalPlayer:GetMouse()

            aimPoint = {mouse.X, mouse.Y}

        else

            aimPoint = {cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2}

        end



        local packetSent = false



        if sendParry and not packetSent then

            local success, err = pcall(function()

                sendParry(finalCF, gamePositionsSnapshot, aimPoint)

            end)

            if success then

                packetSent = true

            else

                Log('Error', 'Red', 'Falló la ruta sendParry: ' .. tostring(err))

            end

        end



        if _reverted and next(_reverted) ~= nil and not packetSent then

            local successCount = 0

            for remote, args in pairs(_reverted) do

                if type(args) ~= "table" then continue end

                local success, err = pcall(function()

                    local pa = {}

                    pa[1] = args[1]

                    pa[2] = args[2]

                    pa[3] = _tokenize and _tokenize(args[2]) or args[3]

                    pa[4] = isSpam and 0 or 0.5

                    pa[5] = finalCF

                    pa[6] = gamePositionsSnapshot

                    pa[7] = aimPoint

                    pa[8] = false

                    if remote:IsA("RemoteEvent") then

                        remote:FireServer(unpack(pa))

                    else

                        remote:InvokeServer(unpack(pa))

                    end

                end)

                if success then

                    successCount = successCount + 1

                else

                    Log('Error', 'Red', 'Falló la ruta Remote: ' .. tostring(err))

                end

            end

            if successCount > 0 then

                packetSent = true

            end

        end



        if _firstSignal and not packetSent then

            local success, err = pcall(function()

                _firstSignal:Fire(0.5, finalCF, gamePositionsSnapshot, aimPoint, false)

            end)

            if success then

                packetSent = true

            else

                Log('Error', 'Red', 'Falló la ruta Signal: ' .. tostring(err))

            end

        end



        if not packetSent then

            pcall(function()

                if mouse1press then mouse1press(); task.wait(0.03); mouse1release() end

                if mouse1click then mouse1click() end

            end)

        end



        Record_Parry()

    end



    ---------------------------------------------------------------------------------------------------------------------------



    local function GetPing()

        local ok, v = pcall(function()

            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()

        end)

        return ok and v or LP:GetNetworkPing() * 1000

    end



    local function GetChar() return LP.Character end

    local function GetHRP(c) return c and c.PrimaryPart or (c and c:FindFirstChild("HumanoidRootPart")) end

    local function GetHum(c) return c and c:FindFirstChildOfClass("Humanoid") end



    local Real_Ball_Position, Tracked_Ball = nil, nil



    pcall(function()

        local targetFolder = workspace:FindFirstChild("Balls") or workspace:FindFirstChild("TrainingBalls")

        local function setupFolderListener(folder)

            if not folder then return end

            folder.ChildRemoved:Connect(function(child)

                xpcall(function()

                    if child:IsA("BasePart") then

                        parryLocked[child] = nil

                        lockTime[child] = nil

                        lastHitTick[child] = nil

                        if activeParryTasks[child] then

                            task.cancel(activeParryTasks[child])

                            activeParryTasks[child] = nil

                        end

                    end

                end, function() end)

            end)

        end

        setupFolderListener(workspace:FindFirstChild("Balls"))

        setupFolderListener(workspace:FindFirstChild("TrainingBalls"))

        workspace.ChildAdded:Connect(function(child)

            if child.Name == "Balls" or child.Name == "TrainingBalls" then

                setupFolderListener(child)

            end

        end)

    end)



    pcall(function()

        local net = RS.Packages._Index["sleitnick_net@0.1.0"].net

        for _, child in net:GetChildren() do

            if child:IsA("UnreliableRemoteEvent") and child.Name ~= "URE/ReplicateBallPosition" then

                child.OnClientEvent:Connect(function(arg, arg2)

                    if not arg or not arg.Parent then

                        if arg == Tracked_Ball then Tracked_Ball = nil; Real_Ball_Position = nil end

                        return

                    end

                    Tracked_Ball = arg; Real_Ball_Position = arg2

                end)

                break

            end

        end

    end)



    -- ถ้าเราอยู่ใน Alive ใช้ workspace.Balls

    -- ถ้าไม่อยู่ใน Alive ใช้ workspace.TrainingBalls แทน

    local function _GetBallFolder()

        local char  = LP.Character

        local alive = workspace:FindFirstChild("Alive")

        local inAlive = alive and char and char:IsDescendantOf(alive)

        if inAlive then

            return workspace:FindFirstChild("Balls"), false

        end

        local tb = workspace:FindFirstChild("TrainingBalls")

        if tb then return tb, true end

        return workspace:FindFirstChild("Balls"), false

    end



    local function GetBalls()

        local status, err = pcall(function()

            local out = {}

            local targetFolder, isTraining = _GetBallFolder()

            BallState.isTraining = isTraining or false

            if not targetFolder then return out end

            local myChar = LP.Character

            local myHRP = myChar and (myChar.PrimaryPart or myChar:FindFirstChild("HumanoidRootPart"))

            local myPos = myHRP and myHRP.Position

            local myName = LP.Name

            for _, v in ipairs(targetFolder:GetChildren()) do

                if v:IsA("BasePart") then

                    v.CanCollide = false

                    table.insert(out, v)

                end

            end

            if myPos then

                table.sort(out, function(a, b)

                    local aTarget = a:GetAttribute("target") == myName

                    local bTarget = b:GetAttribute("target") == myName

                    if aTarget ~= bTarget then return aTarget end

                    local aDist = (myPos - a.Position).Magnitude

                    local bDist = (myPos - b.Position).Magnitude

                    return aDist < bDist

                end)

            end

            -- อัพเดท BallState

            BallState.haveBall = #out > 0

            if #out > 0 then

                -- หา ball ที่ target เรา

                local targeting = nil

                for _, b in ipairs(out) do

                    if b:GetAttribute("target") == myName then

                        targeting = b; break

                    end

                end

                local refBall = targeting or out[1]

                BallState.ball       = refBall

                BallState.targetMe   = (refBall:GetAttribute("target") == myName)

                BallState.targetName = tostring(refBall:GetAttribute("target") or '')

                if myPos then

                    BallState.dist  = (myPos - refBall.Position).Magnitude

                end

                local z = refBall:FindFirstChildOfClass("LinearVelocity") or refBall:FindFirstChild("zoomies")

                BallState.speed = z and (z.VectorVelocity or z.Velocity or Vector3.zero).Magnitude or 0

            else

                BallState.ball       = nil

                BallState.targetMe   = false

                BallState.targetName = ''

                BallState.dist       = 0

                BallState.speed      = 0

            end

            return out

        end)

        if not status then return {} end

        return err

    end



    local function GetBall()

        local status, err = pcall(function()

            if BallState.ball and BallState.ball.Parent then return BallState.ball end

            local targetFolder = _GetBallFolder()

            if targetFolder then

                for _, b in pairs(targetFolder:GetChildren()) do

                    if b:IsA("BasePart") and (b:GetAttribute("realBall") or b:GetAttribute("target") or b.Name:find("Ball")) then

                        return b

                    end

                end

            end

            return nil

        end)

        if not status then return nil end

        return err

    end



    local function GetBallPos(ball)

        local status, err = pcall(function()

            if not ball or not ball.Parent then return Vector3.zero end

            if ball == Tracked_Ball and Real_Ball_Position then 

                return Real_Ball_Position 

            end

            return ball.Position

        end)

        if not status then return Vector3.zero end

        return err

    end



    local function GetBallVel(ball)

        local status, err = pcall(function()

            if not ball or not ball.Parent then return Vector3.zero end

            local zoomiesInstance = ball:FindFirstChildOfClass("LinearVelocity") or ball:FindFirstChild("zoomies")

            if zoomiesInstance then

                return zoomiesInstance.VectorVelocity or zoomiesInstance.Velocity or Vector3.zero

            end

            return ball.AssemblyLinearVelocity or Vector3.zero

        end)

        if not status then return Vector3.zero end

        return err

    end



    



    local Detection = {

        Infinity      = false,

        DeathSlash    = false,

        TimeHole      = false,

        SlashesOfFury = false,

        TornadoTime   = 0,

    }



    local Avatar_State = {

        Headless = false, HeadlessConn = nil,

        Korblox  = false, KorbloxConn  = nil,

    }



    local Win_State    = { Enabled = false, Connections = {} }

    local Streak_State = {

        Enabled = false, Updating = false, Value = nil,

        Conn = nil, EnabledConn = nil, CharConn = nil,

        OriginalText = nil, OriginalIcon = nil, OriginalEnabled = nil,

    }

    local Spam_State     = { Accumulator = 0 }

    local Trigger_State  = { Parrying = false }

    local Device_State   = { Spoof = 0, Rejoin = 0 }

    local FOV_State      = { Enabled = false }



    --// [ ABILITY DETECTION ] ---------------------------------------------

    local function Watch_Ability_Active(Character)

        if not Character then return end

        pcall(function()

            Character:GetAttributeChangedSignal("AbilityActive"):Connect(function()

                local Active = Character:GetAttribute("AbilityActive")

                Detection.SlashesOfFury = (LP:GetAttribute("CurrentlyEquippedAbility") == "Slashes of Fury") and Active == true

            end)

        end)

        pcall(function()

            Character:GetAttributeChangedSignal("FuryCatch"):Connect(function()

                if Character:GetAttribute("FuryCatch") == nil then return end

                if not (Cfg.DetectSlashesOfFury and Detection.SlashesOfFury) then return end

                task.spawn(function()

                    local Count = 0

                    while Detection.SlashesOfFury and Cfg.DetectSlashesOfFury and Count < 36 do

                        Count = Count + 1

                        local Ball = GetBall()

                        if Ball then pcall(FireParry, Ball, true) end

                        task.wait(0.05)

                    end

                end)

            end)

        end)

    end



    local function Setup_Detections()

        pcall(function()

            RS.Remotes.DeathBall.OnClientEvent:Connect(function(_, Active)

                Detection.DeathSlash = Active or false

            end)

        end)

        pcall(function()

            RS.Remotes.InfinityBall.OnClientEvent:Connect(function(_, Active)

                Detection.Infinity = Active or false

            end)

        end)

        pcall(function()

            LP:GetAttributeChangedSignal("TimeHoleActivate"):Connect(function()

                Detection.TimeHole = LP:GetAttribute("TimeHoleActivate") ~= nil

            end)

        end)

        task.spawn(function()

            local Character = GetChar()

            if Character then Watch_Ability_Active(Character) end

            LP.CharacterAdded:Connect(function(NewCharacter)

                Detection.SlashesOfFury = false

                task.wait(0.1)

                Watch_Ability_Active(NewCharacter)

            end)

        end)

    end



    local function Has_Singularity_Cape()

        local Character = GetChar()

        if not Character or not Character.PrimaryPart then return false end

        return Character.PrimaryPart:FindFirstChild("SingularityCape") ~= nil

    end



    local function Is_Tornado(Ball)

        if not Ball or not Ball.Parent then return false end

        if Ball:FindFirstChild("AeroDynamicSlashVFX") then

            pcall(function() Ball.AeroDynamicSlashVFX:Destroy() end)

            Detection.TornadoTime = os.clock()

        end

        local Runtime = workspace:FindFirstChild("Runtime")

        if Runtime and Runtime:FindFirstChild("Tornado") then

            local Time = Runtime.Tornado:GetAttribute("TornadoTime") or 1

            if (os.clock() - Detection.TornadoTime) < (Time + 0.314159) then

                return true

            end

        end

        return false

    end



    local function Detection_Blocked(Ball)

        if Cfg.DetectInfinity and Detection.Infinity then return true end

        if Cfg.DetectDeathSlash and Detection.DeathSlash then return true end

        if Cfg.DetectTimeHole and Detection.TimeHole then return true end

        if Cfg.DetectTornado and Is_Tornado(Ball) then return true end

        if Cfg.DetectSlashesOfFury and Detection.SlashesOfFury then return true end

        return false

    end



    --// [ AUTO ABILITY ] —  try_auto_ability ----------------------

    local function Try_Auto_Ability()

        if not Cfg.AutoAbility then return false end

        local Success, Result = pcall(function()

            local PlayerGui = LP:FindFirstChild("PlayerGui")

            local Hotbar = PlayerGui and PlayerGui:FindFirstChild("Hotbar")

            local Ability = Hotbar and Hotbar:FindFirstChild("Ability")

            local Gradient = Ability and Ability:FindFirstChild("UIGradient")

            if not Gradient or Gradient.Offset.Y ~= 0.5 then return false end



            local Character = GetChar()

            local Abilities = Character and Character:FindFirstChild("Abilities")

            if not Abilities then return false end



            local Names = {

                "Raging Deflection", "Rapture", "Calming Deflection",

                "Aerodynamic Slash", "Fracture", "Death Slash",

            }

            for _, Name in ipairs(Names) do

                local Entry = Abilities:FindFirstChild(Name)

                if Entry and Entry.Enabled then

                    RS.Remotes.AbilityButtonPress:Fire()

                    if Name == "Death Slash" then

                        task.delay(2.432, function()

                            pcall(function()

                                RS:WaitForChild("Remotes"):WaitForChild("DeathSlashShootActivation"):FireServer(true)

                            end)

                        end)

                    end

                    return true

                end

            end

            return false

        end)

        return Success and Result == true

    end



    --// [ HEADLESS / KORBLOX / FOV ] —  avatar + player_mods ------

    local function Apply_Headless(Character)

        if not Character then return end

        local Head = Character:FindFirstChild("Head")

        if not Head then return end

        Head.Transparency = 1

        local Face = Head:FindFirstChildOfClass("Decal")

        if Face then Face:Destroy() end

    end



    local function Remove_Headless(Character)

        if not Character then return end

        local Head = Character:FindFirstChild("Head")

        if Head then Head.Transparency = 0 end

    end



    local function Apply_Korblox(Character)

        if not Character then return end

        local Leg = Character:FindFirstChild("RightLeg") or Character:FindFirstChild("Right Leg")

        if not Leg then return end

        for _, Child in ipairs(Leg:GetChildren()) do

            if Child:IsA("SpecialMesh") or Child:IsA("Mesh") then Child:Destroy() end

        end

        local Mesh = Instance.new("SpecialMesh")

        Mesh.MeshId = "rbxassetid://101851696"

        Mesh.TextureId = "rbxassetid://115727863"

        Mesh.Scale = Vector3.new(1, 1, 1)

        Mesh.Parent = Leg

    end



    local function Remove_Korblox(Character)

        if not Character then return end

        local Leg = Character:FindFirstChild("RightLeg") or Character:FindFirstChild("Right Leg")

        if not Leg then return end

        for _, Child in ipairs(Leg:GetChildren()) do

            if Child:IsA("SpecialMesh") and Child.MeshId == "rbxassetid://101851696" then

                Child:Destroy()

            end

        end

    end



    local function Sync_Avatar()

        if Avatar_State.Headless ~= Cfg.Headless then

            Avatar_State.Headless = Cfg.Headless

            if Cfg.Headless then

                if Avatar_State.HeadlessConn then Avatar_State.HeadlessConn:Disconnect() end

                Apply_Headless(GetChar())

                Avatar_State.HeadlessConn = LP.CharacterAdded:Connect(function(Character)

                    task.wait(0.1)

                    if Cfg.Headless then Apply_Headless(Character) end

                end)

            else

                if Avatar_State.HeadlessConn then

                    Avatar_State.HeadlessConn:Disconnect()

                    Avatar_State.HeadlessConn = nil

                end

                Remove_Headless(GetChar())

            end

        end

        if Avatar_State.Korblox ~= Cfg.Korblox then

            Avatar_State.Korblox = Cfg.Korblox

            if Cfg.Korblox then

                if Avatar_State.KorbloxConn then Avatar_State.KorbloxConn:Disconnect() end

                Apply_Korblox(GetChar())

                Avatar_State.KorbloxConn = LP.CharacterAdded:Connect(function(Character)

                    task.wait(0.1)

                    if Cfg.Korblox then Apply_Korblox(Character) end

                end)

            else

                if Avatar_State.KorbloxConn then

                    Avatar_State.KorbloxConn:Disconnect()

                    Avatar_State.KorbloxConn = nil

                end

                Remove_Korblox(GetChar())

            end

        end

    end



    local function Apply_FOV()

        local Camera = workspace.CurrentCamera

        if not Camera then return end

        if Cfg.FOVEnabled then

            Camera.FieldOfView = Cfg.FOV or 70

        elseif FOV_State.Enabled then

            Camera.FieldOfView = 70

        end

        FOV_State.Enabled = Cfg.FOVEnabled

    end



    --// [ CUSTOM WIN MESSAGE ] —  custom_win ----------------------

    local function Custom_Win_Watch(Label, Getter)

        if not Label then return end

        local Conn = Label:GetPropertyChangedSignal("Text"):Connect(function()

            if not Cfg.CustomWin then return end

            local Value = Getter()

            if Value ~= nil and Value ~= "" and Label.Text ~= Value then

                Label.Text = Value

            end

        end)

        table.insert(Win_State.Connections, Conn)

        local Value = Getter()

        if Value ~= nil and Value ~= "" and Label.Text ~= Value then

            Label.Text = Value

        end

    end



    local function Sync_Custom_Win()

        if Win_State.Enabled == Cfg.CustomWin then return end

        Win_State.Enabled = Cfg.CustomWin

        if Cfg.CustomWin then

            task.spawn(function()

                local PlayerGui = LP:WaitForChild("PlayerGui", 10)

                local Announcer = PlayerGui and PlayerGui:WaitForChild("announcer", 10)

                if not Announcer then return end

                Custom_Win_Watch(Announcer:WaitForChild("Killed", 10), function() return Cfg.KillMessage end)

                Custom_Win_Watch(Announcer:FindFirstChild("Winner"), function() return Cfg.WinMessage end)

                table.insert(Win_State.Connections, Announcer.ChildAdded:Connect(function(Child)

                    if not Cfg.CustomWin then return end

                    if Child.Name == "Killed" then

                        Custom_Win_Watch(Child, function() return Cfg.KillMessage end)

                    elseif Child.Name == "Winner" then

                        Custom_Win_Watch(Child, function() return Cfg.WinMessage end)

                    end

                end))

            end)

        else

            for _, Conn in ipairs(Win_State.Connections) do

                pcall(function() Conn:Disconnect() end)

            end

            table.clear(Win_State.Connections)

        end

    end



    --// [ CUSTOM WINSTREAK ] —  winstreak -------------------------

    local function Winstreak_Update()

        if not Cfg.CustomWinstreak then return end

        Streak_State.Value = tostring(Cfg.Winstreak or "1")

        local Character = GetChar()

        if not Character then return end

        local Display = Character:FindFirstChild("WinStreakDisplay") or Character:WaitForChild("WinStreakDisplay", 5)

        if not Display then return end

        local Main = Display:FindFirstChild("Main")

        if not Main then return end

        local Icon, Value = Main:FindFirstChild("Icon"), Main:FindFirstChild("Value")

        if not Icon or not Value then return end



        if Streak_State.OriginalEnabled == nil then Streak_State.OriginalEnabled = Display.Enabled end

        if not Streak_State.OriginalText or Streak_State.OriginalText == "" then Streak_State.OriginalText = Value.Text end

        if not Streak_State.OriginalIcon or Streak_State.OriginalIcon == "" then Streak_State.OriginalIcon = Icon.Image end



        local Streak = Streak_State.Value

        local Number = tonumber(Streak)

        Icon.Image = (Number and Number >= 10) and "rbxassetid://75598166115655" or "rbxassetid://89658127170771"

        Value.Text = string.format("<b><stroke color='rgb(0, 0, 0)' thickness='2'>%s</stroke></b>", Streak)

        Display.Enabled = true



        if Streak_State.Conn then Streak_State.Conn:Disconnect() end

        if Streak_State.EnabledConn then Streak_State.EnabledConn:Disconnect() end



        Streak_State.Conn = Value:GetPropertyChangedSignal("Text"):Connect(function()

            if not Cfg.CustomWinstreak or Streak_State.Updating then return end

            Streak_State.OriginalText = Value.Text

            Streak_State.Updating = true

            local NewStreak = tostring(Cfg.Winstreak or "1")

            local NewNumber = tonumber(NewStreak)

            Icon.Image = (NewNumber and NewNumber >= 10) and "rbxassetid://75598166115655" or "rbxassetid://89658127170771"

            Value.Text = string.format("<b><stroke color='rgb(0, 0, 0)' thickness='2'>%s</stroke></b>", NewStreak)

            Streak_State.Updating = false

        end)



        Streak_State.EnabledConn = Display:GetPropertyChangedSignal("Enabled"):Connect(function()

            if not Cfg.CustomWinstreak or Streak_State.Updating then return end

            Streak_State.OriginalEnabled = Display.Enabled

            Streak_State.Updating = true

            Display.Enabled = true

            Streak_State.Updating = false

        end)

    end



    local function Sync_Winstreak()

        if Streak_State.Enabled ~= Cfg.CustomWinstreak then

            Streak_State.Enabled = Cfg.CustomWinstreak

            if Cfg.CustomWinstreak then

                if not Streak_State.CharConn then

                    Streak_State.CharConn = LP.CharacterAdded:Connect(function()

                        Streak_State.OriginalText = nil

                        Streak_State.OriginalIcon = nil

                        Streak_State.OriginalEnabled = nil

                        task.wait(1.5)

                        pcall(Winstreak_Update)

                    end)

                end

                pcall(Winstreak_Update)

            else

                if Streak_State.CharConn then Streak_State.CharConn:Disconnect() Streak_State.CharConn = nil end

                if Streak_State.Conn then Streak_State.Conn:Disconnect() Streak_State.Conn = nil end

                if Streak_State.EnabledConn then Streak_State.EnabledConn:Disconnect() Streak_State.EnabledConn = nil end

                local Character = GetChar()

                if Character then

                    local Display = Character:FindFirstChild("WinStreakDisplay")

                    if Display then

                        local Main = Display:FindFirstChild("Main")

                        if Main then

                            local Icon, Value = Main:FindFirstChild("Icon"), Main:FindFirstChild("Value")

                            if Icon and Streak_State.OriginalIcon and Streak_State.OriginalIcon ~= "" then Icon.Image = Streak_State.OriginalIcon end

                            if Value and Streak_State.OriginalText and Streak_State.OriginalText ~= "" then Value.Text = Streak_State.OriginalText end

                        end

                        if Streak_State.OriginalEnabled ~= nil then Display.Enabled = Streak_State.OriginalEnabled end

                    end

                end

                Streak_State.OriginalText, Streak_State.OriginalIcon, Streak_State.OriginalEnabled = nil, nil, nil

            end

        end

        if Streak_State.Enabled and tostring(Cfg.Winstreak) ~= Streak_State.Value then

            pcall(Winstreak_Update)

        end

    end



    --// [ MANUAL SPAM / AUTOSPAM ] —  spam engine ----------------------

    local function Get_Nearest_OpponentDistance(Character)

        if not Character or not Character.PrimaryPart then return math.huge end

        local Alive = workspace:FindFirstChild("Alive")

        if not Alive then return math.huge end

        local Best = math.huge

        for _, Other in ipairs(Alive:GetChildren()) do

            if Other ~= Character and Other.PrimaryPart then

                local Distance = (Character.PrimaryPart.Position - Other.PrimaryPart.Position).Magnitude

                if Distance < Best then Best = Distance end

            end

        end

        return Best

    end



    local function Spam_Tick(Delta, Ball)

        Expire_Parry_History()

        -- Manual Spam is handled entirely by ManualSpam_State / ManualSpam_Tick.

        -- Spam_Tick owns AutoSpam only. If neither AutoSpam is on, idle.

        if not Cfg.AutoSpam then

            Spam_State.Accumulator = 0

            return

        end

        local Character = GetChar()

        local Root = GetHRP(Character)

        if not Root or not Ball or not Ball.Parent then

            Spam_State.Accumulator = 0

            return

        end



        --  adaptive range: ball speed plus ping, floored/ceiled so a slow

        -- ball still opens a usable window. `SpamThreshold` scales it.

        local Speed = GetBallVel(Ball).Magnitude

        local Ping = GetPing() or 30

        local Base = math.clamp((Speed / 5) + (Ping / 5000), 26, 70)

        local Range = Base * (tonumber(Cfg.SpamThreshold) or 1)

        local BallDistance = (Root.Position - GetBallPos(Ball)).Magnitude

        local OpponentDistance = Get_Nearest_OpponentDistance(Character)



        --  `trySpamParry` gate: the ball has to be closing on us AND a real

        -- opponent has to be within range.

        if BallDistance > Range * 1.5 or OpponentDistance > Range then

            Spam_State.Accumulator = 0

            return

        end



        -- AutoSpam needs a live parry count above 1 (parries in

        -- the last 0.5 s, decaying), so it only spams on top of active parrying.

        if Parry_History.Count <= 1 then

            Spam_State.Accumulator = 0

            return

        end



        local CPS = tonumber(Cfg.CPS) or 60

        if CPS <= 0 then return end

        Spam_State.Accumulator = Spam_State.Accumulator + (Delta or 0)

        local Shots = math.floor(Spam_State.Accumulator * CPS)

        if Shots <= 0 then return end

        Spam_State.Accumulator = Spam_State.Accumulator - (Shots / CPS)

        if Spam_State.Accumulator < 0 then Spam_State.Accumulator = 0 end

        if Shots > 10 then Shots = 10 end

        for _ = 1, Shots do

            FireParry(Ball, true)

        end

    end



    --// [ PRE-CLICK ] —  kill_pre_click ---------------------------

    local function Get_Alive_Position(Name)

        if type(Name) ~= "string" or Name == "" then return nil end

        local Alive = workspace:FindFirstChild("Alive")

        local Model = Alive and Alive:FindFirstChild(Name)

        if not Model then Model = workspace:FindFirstChild(Name) end

        if Model and Model:IsA("Model") then

            local Root = Model:FindFirstChild("HumanoidRootPart") or Model.PrimaryPart or Model:FindFirstChildWhichIsA("BasePart")

            if Root then return Root.Position end

        end

        return nil

    end



    local function Get_Fastest_Ball_Speed()

        local Fastest = 0

        for _, Ball in ipairs(GetBalls()) do

            local Speed = GetBallVel(Ball).Magnitude

            if Speed > Fastest then Fastest = Speed end

        end

        return Fastest

    end



    local function On_Killed_Event(...)

        if not Cfg.AutoParry or not Cfg.PreClick then return end

        local Character = GetChar()

        local Root = GetHRP(Character)

        if not Root then return end

        local Humanoid = GetHum(Character)

        if not Humanoid or Humanoid.Health <= 0 then return end



        local MinSpeed = tonumber(Cfg.PreClickSpeed) or 1

        if MinSpeed > 1 and Get_Fastest_Ball_Speed() < MinSpeed then return end



        local Range = tonumber(Cfg.PreClickRange) or 30

        local Found = false



        local Args = table.pack(...)

        for Index = 1, Args.n do

            local Value = Args[Index]

            local Name

            if type(Value) == "string" then

                Name = Value

            elseif type(Value) == "table" then

                Name = Value.Name or Value.DisplayName or Value.Victim or Value.Player

            end

            local Position = Get_Alive_Position(Name)

            if Position and (Root.Position - Position).Magnitude <= Range then

                Found = true

                break

            end

        end



        if not Found then

            local Alive = workspace:FindFirstChild("Alive")

            if Alive then

                for _, Model in ipairs(Alive:GetChildren()) do

                    if Model ~= Character and Model:IsA("Model") then

                        local OtherRoot = Model:FindFirstChild("HumanoidRootPart") or Model.PrimaryPart

                        if OtherRoot and (Root.Position - OtherRoot.Position).Magnitude <= Range then

                            Found = true

                            break

                        end

                    end

                end

            end

        end



        if Found then

            local Ball = GetBall()

            pcall(function() FireParry(Ball, true) end)

        end

    end



    pcall(function()

        RS.Remotes.Killed.OnClientEvent:Connect(On_Killed_Event)

    end)



    --// [ DEVICE SPOOFER ] —  DEVICE_SPOOFER_SOURCE (profile-aware) ------

    --  shipped a single hard-coded "PC" target. The Misc dropdown picks a

    -- profile and the placeholders below are substituted into the source

    -- before it is run or written to the auto-exec folder.

    local DEVICE_PROFILES = {

        ['PC']      = { Label = 'PC',      Platform = 'Windows', Touch = false, Keyboard = true,  Mouse = true,  Gamepad = false, VR = false, Preferred = 'KeyboardAndMouse' },

        ['Mobile']  = { Label = 'Mobile',  Platform = 'Android', Touch = true,  Keyboard = false, Mouse = false, Gamepad = false, VR = false, Preferred = 'Touch' },

        ['Tablet']  = { Label = 'Tablet',  Platform = 'IOS',     Touch = true,  Keyboard = false, Mouse = false, Gamepad = false, VR = false, Preferred = 'Touch' },

        ['Console'] = { Label = 'Console', Platform = 'XboxOne', Touch = false, Keyboard = false, Mouse = false, Gamepad = true,  VR = false, Preferred = 'Gamepad' },

        ['VR']      = { Label = 'VR',      Platform = 'Windows', Touch = false, Keyboard = false, Mouse = false, Gamepad = false, VR = true,  Preferred = 'Gamepad' },

    }



    local DEVICE_SPOOFER_TEMPLATE = [==[

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")

local TARGET_DEVICE = "__DEVICE_LABEL__"

local TARGET_PLATFORM = __TARGET_PLATFORM__

task.spawn(function()

	local cgm = ReplicatedStorage:WaitForChild("ClientGameModules", 30)

	if not cgm then return end

	local mod = cgm:WaitForChild("DeviceListener", 30)

	if not mod then return end

	local ok, DL = pcall(require, mod)

	if not ok or not DL then return end

	if DL.RegisterDeviceChanged then

		local OriginalRegister = DL.RegisterDeviceChanged

		DL.RegisterDeviceChanged = function(self, deviceTable, ...)

			if type(deviceTable) == "table" then

				for k, v in pairs(deviceTable) do

					if type(v) == "string" then

						local l = v:lower()

						if l == "mobile" or l == "phone" or l == "tablet" or l == "android" or l == "ios"

							or l == "windows" or l == "pc" or l == "mac" or l == "osx" then

							deviceTable[k] = TARGET_DEVICE

						end

					elseif typeof(v) == "EnumItem" then

						if v == Enum.Platform.Android or v == Enum.Platform.IOS

							or v == Enum.Platform.Windows or v == Enum.Platform.OSX then

							deviceTable[k] = TARGET_PLATFORM

						end

					end

				end

			elseif type(deviceTable) == "string" then

				local l = deviceTable:lower()

				if l == "mobile" or l == "phone" or l == "tablet" or l == "android" or l == "ios"

					or l == "windows" or l == "pc" or l == "mac" or l == "osx" then

					deviceTable = TARGET_DEVICE

				end

			end

			return OriginalRegister(self, deviceTable, ...)

		end

	end

	pcall(function() DL.Device = TARGET_DEVICE end)

	pcall(function()

		if type(DL.Device) == "table" then

			for k, v in pairs(DL.Device) do

				if type(v) == "string" then

					local l = v:lower()

					if l == "mobile" or l == "phone" or l == "android" or l == "ios"

						or l == "windows" or l == "pc" or l == "mac" or l == "osx" then

						DL.Device[k] = TARGET_DEVICE

					end

				end

			end

		end

	end)

	task.wait(1)

	pcall(function() DL:RegisterDeviceChanged(DL.Device) end)

	task.wait(2)

	pcall(function() DL:RegisterDeviceChanged(DL.Device) end)

	task.wait(3)

	pcall(function() DL:RegisterDeviceChanged(DL.Device) end)

end)

local mt = getrawmetatable(game)

local oldIndex = mt.__index

setreadonly(mt, false)

mt.__index = newcclosure(function(self, key)

	if self == UserInputService then

		if key == "GetPlatform" then

			return function() return TARGET_PLATFORM end

		end

		if key == "TouchEnabled" or key == "TouchScreenEnabled" or key == "AccelerometerEnabled" or key == "GyroscopeEnabled" then

			return __TOUCH__

		end

		if key == "GamepadEnabled" then

			return __GAMEPAD__

		end

		if key == "VREnabled" then

			return __VR__

		end

		if key == "KeyboardEnabled" then

			return __KEYBOARD__

		end

		if key == "MouseEnabled" then

			return __MOUSE__

		end

		if key == "PreferredInput" then

			return __PREFERRED__

		end

	end

	return oldIndex(self, key)

end)

setreadonly(mt, true)

]==]



    local function Build_Device_Spoofer_Source(Target)

        local Profile = DEVICE_PROFILES[Target] or DEVICE_PROFILES['PC']

        local Source = DEVICE_SPOOFER_TEMPLATE

        Source = Source:gsub('__DEVICE_LABEL__', Profile.Label)

        Source = Source:gsub('__TARGET_PLATFORM__', 'Enum.Platform.' .. Profile.Platform)

        Source = Source:gsub('__TOUCH__', tostring(Profile.Touch))

        Source = Source:gsub('__KEYBOARD__', tostring(Profile.Keyboard))

        Source = Source:gsub('__MOUSE__', tostring(Profile.Mouse))

        Source = Source:gsub('__GAMEPAD__', tostring(Profile.Gamepad))

        Source = Source:gsub('__VR__', tostring(Profile.VR))

        Source = Source:gsub('__PREFERRED__', 'Enum.PreferredInput.' .. Profile.Preferred)

        return Source

    end



    local function Recognize_Autoexec_Folder()

        local Folders = {

            "autoexec", "AutoExec", "autoexec/scripts",

            "workspace/autoexec", "scripts/autoexec",

        }

        for _, Candidate in ipairs(Folders) do

            if isfolder and isfolder(Candidate) then

                return Candidate

            end

        end

        return nil

    end



    local function Apply_Device_Spoofer(Rejoin)

        local Target = Cfg.DeviceTarget or 'PC'

        local Source = Build_Device_Spoofer_Source(Target)

        local Success = pcall(function()

            local Chunk = loadstring(Source)

            if Chunk then Chunk() end

        end)

        pcall(function()

            if writefile then

                pcall(writefile, "ds_rejoin.flag", "1")

                local Folder = Recognize_Autoexec_Folder()

                if Folder then

                    pcall(writefile, Folder .. "/device_spoofer.lua", Source)

                end

            end

        end)

        if Rejoin then

            task.spawn(function()

                task.wait(0.5)

                pcall(function()

                    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)

                end)

            end)

        end

        Log(Success and 'Success' or 'Warning', 'Device Spoofer',

            Success and (' device spoofer applied (' .. Target .. ').')

                or (' device spoofer loaded with warnings (' .. Target .. ').'))

    end



    --// [ IMMORTALITY DESYNC ] — V1 (Virex Triangle) + V2 (Orbit Desync) --

    -- Port of immortal.txt. A transparent, anchored EH_CamAnchor holds the

    -- camera while the module walks/carries the HumanoidRootPart and floods

    -- the physics sender rate, so the server keeps the last-seen pose. V1

    -- flings a rotating triangle, V2 orbits between Height Min and Height

    -- Max. Each root change is restored one render frame later. This is a

    -- desync, not a real godmode: it can strand you out of the map.

    local Immortal_State = {

        Anchor = nil,

    }



    local function Immortal_Anchor()

        local Anchor = Immortal_State.Anchor

        if Anchor and Anchor.Parent then return Anchor end

        Anchor = workspace:FindFirstChild("EH_CamAnchor")

        if not Anchor then

            Anchor = Instance.new("Part")

            Anchor.Size = Vector3.new(0.1, 0.1, 0.1)

            Anchor.Transparency = 1

            Anchor.CanCollide = false

            Anchor.Anchored = true

            Anchor.Name = "EH_CamAnchor"

            Anchor.Parent = workspace

        end

        Immortal_State.Anchor = Anchor

        return Anchor

    end



    local function Immortal_Tick()

        local Character = LP.Character

        local HRP = Character and Character:FindFirstChild("HumanoidRootPart")

        local Hum = Character and Character:FindFirstChildOfClass("Humanoid")

        local Cam = workspace.CurrentCamera

        if not HRP or not Hum or Hum.Health <= 0 or not Cam then return end



        local Anchor = Immortal_Anchor()

        local V1 = Cfg.ImmortalEnabled and Cfg.ImmortalV1

        local V2 = Cfg.ImmortalEnabled and Cfg.ImmortalV2



        if not (V1 or V2) then

            if Cam.CameraSubject == Anchor then Cam.CameraSubject = Hum end

            return

        end



        Anchor.CFrame = Anchor.CFrame:Lerp(CFrame.new(HRP.Position), 0.3)

        if Cam.CameraSubject ~= Anchor then Cam.CameraSubject = Anchor end

        if type(setfflag) == "function" then

            pcall(setfflag, "S2PhysicsSenderRate", "15")

        end



        if V1 then

            local T = tick()

            local Spot = math.floor(T * 95) % 3

            local Reach = 14

            if type(setfflag) == "function" then

                pcall(setfflag, "S2PhysicsSenderRate", "1333335")

            end

            HRP.CFrame = HRP.CFrame + Vector3.new(0, 0.01, 0)

            local Look = HRP.CFrame.LookVector

            local Right = HRP.CFrame.RightVector

            local Triangle, Velocity = Vector3.zero, Vector3.zero

            if Spot == 0 then

                Triangle = (-Right * Reach) + (Look * (Reach * 0.5)); Velocity = -Right * 350

            elseif Spot == 1 then

                Triangle = (Right * Reach) + (Look * (Reach * 0.5)); Velocity = Right * 350

            else

                Triangle = -Look * Reach; Velocity = -Look * 350

            end

            local OldCF = HRP.CFrame

            local OldVel = HRP.AssemblyLinearVelocity

            HRP.CFrame = OldCF * CFrame.new(Triangle)

            HRP.AssemblyLinearVelocity = Velocity

            task.spawn(function()

                RunService.RenderStepped:Wait()

                if HRP and HRP.Parent then

                    HRP.CFrame = OldCF

                    HRP.AssemblyLinearVelocity = OldVel

                end

            end)

        elseif V2 then

            local Angle = (Cfg.ImmortalMode == "Auto") and 145 or (tonumber(Cfg.ImmortalAngle) or 145)

            local T = tick()

            if type(setfflag) == "function" then

                pcall(setfflag, "S2PhysicsSenderRate", "1333335")

            end

            HRP.CFrame = HRP.CFrame + Vector3.new(0, 0.01, 0)

            local Round = T * math.pi * 2 * Angle / 5

            local HeightMin = tonumber(Cfg.ImmortalHeightMin) or -8

            local HeightMax = tonumber(Cfg.ImmortalHeightMax) or 35

            local Y = (math.floor(T * 135) % 2 == 0) and HeightMin or HeightMax

            local Radius = tonumber(Cfg.ImmortalRadius) or 10

            local Offset = Vector3.new(math.cos(Round) * Radius, Y, math.sin(Round) * Radius)

            local OldCF = HRP.CFrame

            local OldVel = HRP.AssemblyLinearVelocity

            HRP.CFrame = OldCF + Offset

            HRP.AssemblyLinearVelocity = Vector3.new(

                math.sin(Round) * 250,

                (Y == HeightMax) and 280 or -280,

                math.cos(Round) * 250

            )

            task.spawn(function()

                RunService.RenderStepped:Wait()

                if HRP and HRP.Parent then

                    HRP.CFrame = OldCF

                    HRP.AssemblyLinearVelocity = OldVel

                end

            end)

        end

    end

    

 Players = game:GetService("Players")

 ReplicatedStorage = game:GetService("ReplicatedStorage")

 LocalPlayer = Players.LocalPlayer



local ESP_Storage = {}

local ESP_RespawnConns = {}

local ESP_Active_Task = nil

local ESP_Running = false



local DataAbilities = ReplicatedStorage:WaitForChild("Misc"):WaitForChild("DataAbilities")



local function RemovePlayerESP(plr)

    if ESP_Storage[plr] then

        pcall(function() ESP_Storage[plr]:Destroy() end)

        ESP_Storage[plr] = nil

    end

end



local function DetachRespawnHook(plr)

    if ESP_RespawnConns[plr] then

        pcall(function() ESP_RespawnConns[plr]:Disconnect() end)

        ESP_RespawnConns[plr] = nil

    end

end



local function AttachPlayerESP(plr)

    if plr == LocalPlayer then return end

    RemovePlayerESP(plr)



    local char = plr.Character

    if not char then

        local ok, result = pcall(function()

            return plr.CharacterAdded:Wait()

        end)

        if not ok or not ESP_Running then return end

        char = result

    end

    if not ESP_Running then return end



    local head = char:WaitForChild("Head", 5)

    if not head or not ESP_Running then return end



    local sGui = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

    local espStyle = Cfg.ESPStyle or 'Default'

    -- 'Default'   = icon (26x26) + name + cooldown (140x40)

    -- 'Name Only' = no icon, just name + cooldown text (100x20)

    -- 'Icon Only' = only icon (28x28)



    local BGui = Instance.new("BillboardGui")

    BGui.Name = "Plr_Ability_ESP"

    BGui.AlwaysOnTop = true

    BGui.Size = (espStyle == 'Icon Only')  and UDim2.new(0,28,0,28)

             or (espStyle == 'Name Only')  and UDim2.new(0,110,0,22)

             or UDim2.new(0, 140, 0, 40)

    BGui.StudsOffset = Vector3.new(0, 3.0, 0)

    BGui.Adornee = head

    BGui.Parent = sGui

    ESP_Storage[plr] = BGui



    local Icon = Instance.new("ImageLabel")

    Icon.BackgroundTransparency = 1

    Icon.Image = "rbxassetid://3944703587"

    if espStyle == 'Icon Only' then

        Icon.Size     = UDim2.fromOffset(28, 28)

        Icon.Position = UDim2.fromOffset(0, 0)

    elseif espStyle == 'Name Only' then

        Icon.Size     = UDim2.fromOffset(0, 0)  -- hidden

        Icon.Position = UDim2.fromOffset(0, 0)

        Icon.Visible  = false

    else

        Icon.Size     = UDim2.fromOffset(26, 26)

        Icon.Position = UDim2.fromOffset(5, 7)

    end

    Icon.Parent = BGui



    local StatusLbl = Instance.new("TextLabel")

    StatusLbl.BackgroundTransparency = 1

    StatusLbl.TextColor3 = Color3.fromRGB(255, 255, 255)

    StatusLbl.Font = Enum.Font.GothamBold

    StatusLbl.TextXAlignment = Enum.TextXAlignment.Left

    StatusLbl.TextStrokeTransparency = 0

    StatusLbl.Text = "NINGUNA"

    if espStyle == 'Name Only' then

        StatusLbl.Size     = UDim2.fromOffset(106, 13)

        StatusLbl.Position = UDim2.fromOffset(2, 1)

        StatusLbl.TextSize = 10

    else

        StatusLbl.Size     = UDim2.fromOffset(95, 14)

        StatusLbl.Position = UDim2.fromOffset(36, 5)

        StatusLbl.TextSize = 10

    end

    StatusLbl.Visible = (espStyle ~= 'Icon Only')

    StatusLbl.Parent = BGui



    local ReadyLbl = Instance.new("TextLabel")

    ReadyLbl.BackgroundTransparency = 1

    ReadyLbl.TextColor3 = Color3.fromRGB(80, 220, 120)

    ReadyLbl.Font = Enum.Font.GothamBlack

    ReadyLbl.TextXAlignment = Enum.TextXAlignment.Left

    ReadyLbl.TextStrokeTransparency = 0

    ReadyLbl.Text = "LISTO"

    if espStyle == 'Name Only' then

        ReadyLbl.Size     = UDim2.fromOffset(106, 10)

        ReadyLbl.Position = UDim2.fromOffset(2, 12)

        ReadyLbl.TextSize = 9

    else

        ReadyLbl.Size     = UDim2.fromOffset(95, 14)

        ReadyLbl.Position = UDim2.fromOffset(36, 18)

        ReadyLbl.TextSize = 10

    end

    ReadyLbl.Visible = (espStyle ~= 'Icon Only')

    ReadyLbl.Parent = BGui



    task.spawn(function()

        while BGui and BGui.Parent and ESP_Running do

            pcall(function()

                local liveChar = plr.Character

                if not liveChar then return end



                local liveHead = liveChar:FindFirstChild("Head")

                if liveHead and BGui.Adornee ~= liveHead then

                    BGui.Adornee = liveHead

                end



                local rawAbility = plr:GetAttribute("EquippedAbility") or plr:GetAttribute("Ability") or "None"

                StatusLbl.Text = string.upper(tostring(rawAbility))



                local abilityFolder = DataAbilities:FindFirstChild(tostring(rawAbility))

                if abilityFolder then

                    local assetIcon = abilityFolder:GetAttribute("Icon") or abilityFolder:GetAttribute("Icon1")

                    Icon.Image = (assetIcon and assetIcon ~= "") and assetIcon or "rbxassetid://9094483852"

                else

                    Icon.Image = "rbxassetid://9094483852"

                end



                local abActive = liveChar:GetAttribute("AbilityActive") == true

                local cdActive = liveChar:GetAttribute("CooldownActive") == true

                local cdExpiry = plr:GetAttribute("CooldownExpiration")

                local cdExpired = cdExpiry and workspace:GetServerTimeNow() < cdExpiry

                local isReady = not (abActive or cdActive or cdExpired)



                if isReady then

                    ReadyLbl.Text = "LISTO"

                    ReadyLbl.TextColor3 = Color3.fromRGB(80, 220, 120)

                else

                    local cdDiff = cdExpiry and (cdExpiry - workspace:GetServerTimeNow()) or 0

                    ReadyLbl.Text = cdDiff > 0 and string.format("%.1fS", cdDiff) or "USADO"

                    ReadyLbl.TextColor3 = Color3.fromRGB(220, 100, 80)

                end

            end)

            task.wait(0.2)

        end

        pcall(function()

            if BGui and BGui.Parent then BGui:Destroy() end

        end)

        if ESP_Storage[plr] == BGui then ESP_Storage[plr] = nil end

    end)

end



local function HookPlayerRespawn(plr)

    DetachRespawnHook(plr)

    ESP_RespawnConns[plr] = plr.CharacterAdded:Connect(function()

        if not ESP_Running then return end

        task.delay(0.3, function()

            if ESP_Running then

                task.spawn(AttachPlayerESP, plr)

            end

        end)

    end)

end



function SetESPAbility()

    ESP_Running = false



    if ESP_Active_Task then

        pcall(function() task.cancel(ESP_Active_Task) end)

        ESP_Active_Task = nil

    end



    for plr, _ in pairs(ESP_RespawnConns) do DetachRespawnHook(plr) end

    table.clear(ESP_RespawnConns)



    for plr, _ in pairs(ESP_Storage) do RemovePlayerESP(plr) end

    table.clear(ESP_Storage)



    if not Cfg.espability then return end



    ESP_Running = true



    ESP_Active_Task = task.spawn(function()

        for _, p in ipairs(Players:GetPlayers()) do

            if p ~= LocalPlayer then

                HookPlayerRespawn(p)

                task.spawn(AttachPlayerESP, p)

            end

        end



        local connAdded = Players.PlayerAdded:Connect(function(p)

            if not ESP_Running or p == LocalPlayer then return end

            HookPlayerRespawn(p)

            task.spawn(AttachPlayerESP, p)

        end)



        local connRemoving = Players.PlayerRemoving:Connect(function(p)

            DetachRespawnHook(p)

            RemovePlayerESP(p)

        end)



        while ESP_Running do

            task.wait(0.5)

        end



        pcall(function() connAdded:Disconnect() end)

        pcall(function() connRemoving:Disconnect() end)



        for plr, _ in pairs(ESP_RespawnConns) do DetachRespawnHook(plr) end

        table.clear(ESP_RespawnConns)

        for plr, _ in pairs(ESP_Storage) do RemovePlayerESP(plr) end

        table.clear(ESP_Storage)

    end)

end



    --// [ SKIN CHANGER ] —  sword model / animation / FX override --

    -- Resolves the real Swords module + SwordsController, equips the named

    -- sword for the local player and rewrites the sword/slash arguments of

    -- the parry/sound/visual remotes so the chosen skin and its slash VFX are

    -- what everyone sees. Every executor-dependent step is pcall-guarded.

    local Skin_State = {

        Initialized = false,

        Enabled = false,

        Renderer = nil,

        Controller = nil,

        SwordModel = "",

        SwordAnimations = "",

        SwordFX = "",

        SlashName = "SlashEffect",

        Installed = {},

        HookedFuncs = {},

    }



    local function Skin_Refresh_Slash()

        local FXName = (Skin_State.SwordFX ~= "" and Skin_State.SwordFX) or Skin_State.SwordModel

        if FXName ~= "" and Skin_State.Renderer then

            local OK, Slash = pcall(function() return Skin_State.Renderer:GetSword(FXName) end)

            Skin_State.SlashName = (OK and Slash and Slash.SlashName) or "SlashEffect"

        else

            Skin_State.SlashName = "SlashEffect"

        end

    end



    local function Skin_Set_Sword()

        if Skin_State.SwordModel == "" or not LP.Character then return end

        local Renderer = Skin_State.Renderer

        pcall(function()

            if Renderer and type(rawget(Renderer, "EquipSwordTo")) == "function" then

                local Func = rawget(Renderer, "EquipSwordTo")

                if type(getupvalues) == "function" and type(setupvalue) == "function" then

                    local Ups = getupvalues(Func)

                    for i = 1, #Ups do

                        if type(Ups[i]) == "boolean" then

                            setupvalue(Func, i, false)

                            break

                        end

                    end

                end

            end

        end)

        pcall(function()

            if Renderer and type(Renderer.EquipSwordTo) == "function" then

                Renderer:EquipSwordTo(LP.Character, Skin_State.SwordModel)

            end

        end)

        task.spawn(function()

            local Attempts = 0

            while not Skin_State.Controller and Attempts < 20 do

                task.wait(0.5)

                Attempts = Attempts + 1

            end

            local Controller = Skin_State.Controller

            if not Controller then return end

            pcall(function()

                if type(Controller.SetSword) == "function" then

                    Controller:SetSword(Skin_State.SwordAnimations ~= "" and Skin_State.SwordAnimations or Skin_State.SwordModel)

                end

            end)

            pcall(function()

                local TargetSword = Skin_State.SwordFX ~= "" and Skin_State.SwordFX or Skin_State.SwordModel

                if RS.Remotes:FindFirstChild("FireSwordInfo") then

                    RS.Remotes.FireSwordInfo:FireServer(TargetSword)

                end

                if Controller.currentSword ~= nil then Controller.currentSword = TargetSword end

                if Controller.SwordFX ~= nil then Controller.SwordFX = TargetSword end

            end)

        end)

    end



    local function Skin_Hook_Remotes()

        if type(getconnections) ~= "function" then return end

        for _, RemoteName in ipairs({ "ParrySuccessAll", "ParryAttempt", "ParrySuccess", "PlaySound", "PlayVisuals" }) do

            local Remote = RS.Remotes:FindFirstChild(RemoteName)

            if Remote and Remote:IsA("RemoteEvent") then

                local Installed = Skin_State.Installed[RemoteName]

                if Installed then

                    for i = #Installed, 1, -1 do

                        if not Installed[i].Orig.Connected then

                            pcall(function() Installed[i].Wrap:Disconnect() end)

                            Skin_State.HookedFuncs[Installed[i].OrigFn] = nil

                            Skin_State.HookedFuncs[Installed[i].WrapFn] = nil

                            table.remove(Installed, i)

                        end

                    end

                end

                local OK, Conns = pcall(getconnections, Remote.OnClientEvent)

                if OK and type(Conns) == "table" then

                    for _, Connection in ipairs(Conns) do

                        local Func = Connection.Function

                        if Func and not Skin_State.HookedFuncs[Func] then

                            Skin_State.HookedFuncs[Func] = true

                            pcall(function() Connection:Disable() end)

                            local TargetFunc = Func

                            local OurFunc = function(...)

                                local Args = { ... }

                                local IsLocal = false

                                for _, Arg in ipairs(Args) do

                                    if tostring(Arg) == LP.Name or (typeof(Arg) == "Instance" and (Arg == LP.Character or Arg == LP)) then

                                        IsLocal = true

                                        break

                                    end

                                end

                                if IsLocal and Skin_State.Enabled then

                                    local FXSword = (Skin_State.SwordFX ~= "" and Skin_State.SwordFX) or Skin_State.SwordModel

                                    Skin_Refresh_Slash()

                                    local SwordFound, SlashFound = false, false

                                    for i, Arg in ipairs(Args) do

                                        if type(Arg) == "string" then

                                            if FXSword ~= "" and not SlashFound and (Arg:match("Slash") or Arg == "Default" or Arg:match("Effect")) then

                                                Args[i] = Skin_State.SlashName

                                                SlashFound = true

                                            elseif FXSword ~= "" and not SwordFound then

                                                local IsSword = false

                                                pcall(function()

                                                    if RS.Shared.ReplicatedInstances.Swords:FindFirstChild(Arg) then IsSword = true end

                                                end)

                                                if IsSword or Arg == LP:GetAttribute("CurrentlyEquippedSword") then

                                                    Args[i] = FXSword

                                                    SwordFound = true

                                                end

                                            end

                                        end

                                    end

                                    if FXSword ~= "" and not SlashFound and type(Args[1]) == "string" then

                                        Args[1] = Skin_State.SlashName

                                    end

                                    if FXSword ~= "" and not SwordFound and type(Args[3]) == "string" then

                                        Args[3] = FXSword

                                    end

                                end

                                if setthreadidentity then pcall(setthreadidentity, 2) end

                                pcall(TargetFunc, unpack(Args))

                            end

                            Skin_State.HookedFuncs[OurFunc] = true

                            local Entry = { Orig = Connection, OrigFn = Func, WrapFn = OurFunc }

                            Entry.Wrap = Remote.OnClientEvent:Connect(OurFunc)

                            Skin_State.Installed[RemoteName] = Skin_State.Installed[RemoteName] or {}

                            table.insert(Skin_State.Installed[RemoteName], Entry)

                        end

                    end

                end

            end

        end

    end



    local function Skin_Initialize()

        if Skin_State.Initialized then return end

        Skin_State.Initialized = true

        task.spawn(function()

            local OK, Renderer = pcall(function()

                return require(RS:WaitForChild("Shared", 9e9):WaitForChild("ReplicatedInstances", 9e9):WaitForChild("Swords", 9e9))

            end)

            if not OK then

                Skin_State.Initialized = false

                return

            end

            Skin_State.Renderer = Renderer

            task.spawn(function()

                while task.wait(0.25) and not Skin_State.Controller do

                    if type(getconnections) ~= "function" then return end

                    local OK2, Conns = pcall(getconnections, RS.Remotes.FireSwordInfo.OnClientEvent)

                    if OK2 and Conns then

                        for _, Connection in ipairs(Conns) do

                            if Connection.Function and type(islclosure) == "function" and islclosure(Connection.Function) then

                                local OK3, Ups = pcall(getupvalues, Connection.Function)

                                if OK3 and #Ups == 1 and type(Ups[1]) == "table" then

                                    Skin_State.Controller = Ups[1]

                                    break

                                end

                            end

                        end

                    end

                end

            end)

            task.spawn(function()

                while task.wait(1) do

                    if Skin_State.Enabled then

                        Skin_Hook_Remotes()

                        local Character = LP.Character

                        if Character and Skin_State.SwordModel ~= "" then

                            if LP:GetAttribute("CurrentlyEquippedSword") ~= Skin_State.SwordModel

                                or not Character:FindFirstChild(Skin_State.SwordModel) then

                                Skin_Set_Sword()

                            end

                            for _, Child in ipairs(Character:GetChildren()) do

                                if Child:IsA("Model") and Child.Name ~= Skin_State.SwordModel then

                                    pcall(function() Child:Destroy() end)

                                end

                                task.wait()

                            end

                        end

                    end

                end

            end)

        end)

    end



    local function Sync_Skin_Changer()

        if Skin_State.Enabled ~= Cfg.SkinChanger then

            Skin_State.Enabled = Cfg.SkinChanger

            if Cfg.SkinChanger then

                Skin_Initialize()

                task.spawn(function()

                    task.wait(0.5)

                    Skin_Refresh_Slash()

                    Skin_Set_Sword()

                end)

            end

        end

        local Name = tostring(Cfg.SkinName or "")

        if Name ~= "" and Name ~= Skin_State.SwordModel then

            Skin_State.SwordModel = Name

            Skin_State.SwordAnimations = Name

            Skin_State.SwordFX = Name

            Skin_Refresh_Slash()

            if Skin_State.Enabled then Skin_Set_Sword() end

        end

    end



    --// [ SWORD SLASH COLOR ] —  colorable ParryFX -----------------

    local Slash_Config = {

        Enabled = false,

        Color = Color3.fromRGB(255, 0, 0),

        Mode = "Solid",

    }

    local Slash_State = {

        Connections = {},

        Reassert = setmetatable({}, { __mode = "k" }),

        RainbowLoop = nil,

    }

    local KNOWN_EFFECT_PATHS = {

        "Impact/Glow2Sided",

        "Impact/flare2",

        "Impact/circles",

        "Impact/fast-burst",

        "Impact/impact",

        "Star",

        "Slash/Effect",

        "Slash/Effect3",

    }



    local function Slash_Get_Color()

        local Color = Slash_Config.Color

        if Slash_Config.Mode == "Rainbow" then

            Color = Color3.fromHSV((os.clock() % 3) / 3, 1, 1)

        elseif Slash_Config.Mode == "Random" then

            Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))

        end

        return Color

    end



    local function Slash_Apply_Color(Instance_, Color)

        pcall(function()

            if Instance_:IsA("BasePart") then

                Instance_.Color = Color

            elseif Instance_:IsA("Highlight") then

                Instance_.FillColor = Color

                Instance_.OutlineColor = Color

            elseif Instance_:IsA("ParticleEmitter") or Instance_:IsA("Beam") or Instance_:IsA("Trail") then

                Instance_.Color = ColorSequence.new(Color)

            end

        end)

    end



    local function Slash_Color_Object(Part)

        if not Slash_Config.Enabled or not Part or not Part:IsDescendantOf(workspace) then return end

        local Character = LP.Character

        if not Character or not Part:IsDescendantOf(Character) then return end

        local Color = Slash_Get_Color()

        Slash_Apply_Color(Part, Color)

        for _, Path in ipairs(KNOWN_EFFECT_PATHS) do

            local Current = Part

            for Segment in Path:gmatch("[^/]+") do

                Current = Current and Current:FindFirstChild(Segment)

            end

            if Current then Slash_Apply_Color(Current, Color) end

        end

        for _, Descendant in ipairs(Part:GetDescendants()) do

            Slash_Apply_Color(Descendant, Color)

        end

        if Slash_State.Reassert[Part] then return end

        Slash_State.Reassert[Part] = true

        local Start = os.clock()

        local Acc = 0

        local Conn

        Conn = RunService.Heartbeat:Connect(function(Delta)

            if not Part.Parent or (os.clock() - Start) > 0.4 then

                Slash_State.Reassert[Part] = nil

                Conn:Disconnect()

                return

            end

            Acc = Acc + Delta

            if Acc < 0.05 then return end

            Acc = 0

            Slash_Apply_Color(Part, Slash_Get_Color())

        end)

    end



    local function Slash_Start()

        if Slash_Config.Enabled then return end

        Slash_Config.Enabled = true

        for _, Conn in ipairs(Slash_State.Connections) do pcall(function() Conn:Disconnect() end) end

        table.clear(Slash_State.Connections)

        for _, Inst in ipairs(CollectionService:GetTagged("ParryFX")) do

            Slash_Color_Object(Inst)

        end

        table.insert(Slash_State.Connections, CollectionService:GetInstanceAddedSignal("ParryFX"):Connect(Slash_Color_Object))

    end



    local function Slash_Stop()

        Slash_Config.Enabled = false

        for _, Conn in ipairs(Slash_State.Connections) do pcall(function() Conn:Disconnect() end) end

        table.clear(Slash_State.Connections)

        table.clear(Slash_State.Reassert)

        if Slash_State.RainbowLoop then

            Slash_State.RainbowLoop:Disconnect()

            Slash_State.RainbowLoop = nil

        end

    end



    local function Slash_Reapply_All()

        if not Slash_Config.Enabled then return end

        for _, Inst in ipairs(CollectionService:GetTagged("ParryFX")) do

            Slash_Color_Object(Inst)

        end

    end



    local function Sync_Slash_Color()

        Slash_Config.Color = Cfg.SlashColorValue or Slash_Config.Color

        Slash_Config.Mode = Cfg.SlashColorMode or Slash_Config.Mode

        if Cfg.SlashColor then

            Slash_Start()

            local Wants_Loop = (Slash_Config.Mode == "Rainbow" or Slash_Config.Mode == "Random")

            if Wants_Loop and not Slash_State.RainbowLoop then

                Slash_State.RainbowLoop = RunService.RenderStepped:Connect(Slash_Reapply_All)

            elseif not Wants_Loop and Slash_State.RainbowLoop then

                Slash_State.RainbowLoop:Disconnect()

                Slash_State.RainbowLoop = nil

            end

        else

            Slash_Stop()

        end

    end



    --// [ STAFF DETECTION ] --------------------------

    -- Resolves each player's rank in the game's staff group and alerts (or

    -- disconnects) when someone at or above StaffMinRank is in the session.

    -- Ranks are cached per UserId so each visitor costs at most one group

    -- lookup, and the module runs even when Auto Parry is off.

    local DEFAULT_STAFF_GROUP = 12836673

    local DEFAULT_STAFF_RANK  = 10



    local Staff_State = {

        Enabled    = false,

        Scan_Pulse = tonumber(Cfg.StaffScanPulse) or 0,

        Detected   = {},   -- [UserId] = { Name, DisplayName, Rank, Time }

        Rank_Cache = {},   -- [UserId] = rank

    }

    local Staff_Connection = nil



    local function Staff_Group_Id()

        return tonumber(Cfg.StaffGroupId) or DEFAULT_STAFF_GROUP

    end



    local function Staff_Min_Rank()

        return tonumber(Cfg.StaffMinRank) or DEFAULT_STAFF_RANK

    end



    local function Staff_Get_Rank(Player)

        if not Player or not Player:IsA("Player") then return 0 end

        local Cached = Staff_State.Rank_Cache[Player.UserId]

        if Cached ~= nil then return Cached end



        local Ok, Rank = pcall(function()

            return Player:GetRankInGroup(Staff_Group_Id())

        end)

        if Ok and type(Rank) == "number" then

            Staff_State.Rank_Cache[Player.UserId] = Rank

            return Rank

        end

        return 0

    end



    local function Staff_Process_Player(Player)

        if not Player or Player == LP then return end

        local UserId = Player.UserId

        if Staff_State.Detected[UserId] then return end



        task.spawn(function()

            local Rank = Staff_Get_Rank(Player)

            if Rank < Staff_Min_Rank() then return end

            -- Another scan may have reported this player while the group

            -- lookup above was in flight.

            if Staff_State.Detected[UserId] then return end



            Staff_State.Detected[UserId] = {

                Name        = Player.Name,

                DisplayName = Player.DisplayName,

                Rank        = Rank,

                Time        = os.time(),

            }



            if Cfg.StaffActionMode == 'Kick' then

                Log('Error', 'Detección de staff',

                    'Staff detectado: ' .. Player.Name .. ' (Rango ' .. tostring(Rank) .. '). Desconectando.', 8)

                task.wait(0.2)

                LP:Kick('\n[MayOs]\nStaff detectado en la sesión: ' .. Player.Name ..

                    '.\nDesconectado para proteger la integridad de tu cuenta.')

            else

                Log('Warning', 'STAFF DETECTADO',

                    'Moderador en el servidor: ' .. Player.Name .. ' (Rango ' .. tostring(Rank) .. '+)', 6)

            end

        end)

    end



    local function Staff_Scan_Count()

        local Count = 0

        for _, Player in ipairs(Players:GetPlayers()) do

            if Player ~= LP and Staff_Get_Rank(Player) >= Staff_Min_Rank() then

                Count = Count + 1

            end

        end

        return Count

    end



    local function Staff_Start()

        if Staff_Connection then return end

        -- Connect first so a player joining mid-scan is not missed.

        Staff_Connection = Players.PlayerAdded:Connect(function(Player)

            if Staff_State.Enabled then

                Staff_Process_Player(Player)

            end

        end)

        for _, Player in ipairs(Players:GetPlayers()) do

            if Player ~= LP then

                Staff_Process_Player(Player)

            end

        end

    end



    local function Staff_Stop()

        if Staff_Connection then

            Staff_Connection:Disconnect()

            Staff_Connection = nil

        end

        table.clear(Staff_State.Detected)

    end



    local function Sync_Staff()

        local Enabled = Cfg.StaffDetection and true or false

        if Enabled ~= Staff_State.Enabled then

            Staff_State.Enabled = Enabled

            if Enabled then

                Staff_Start()

                Log('Success', 'Detección de staff', 'Sistema de detección de staff activado', 3)

            else

                Staff_Stop()

                Log('Info', 'Detección de staff', 'Sistema de detección de staff desactivado', 3)

            end

        end



        local Pulse = tonumber(Cfg.StaffScanPulse) or 0

        if Pulse ~= Staff_State.Scan_Pulse then

            Staff_State.Scan_Pulse = Pulse

            -- The roster audit may hit the group API; keep it off the

            -- heartbeat thread in case the lookup yields.

            task.spawn(function()

                Log('Info', 'Auditoría del servidor completada',

                    'Miembros del staff activos identificados: ' .. tostring(Staff_Scan_Count()), 3)

            end)

        end

    end



    --// [ FEATURE TICK ] --------------------------------------------------

    local function Feature_Tick()

        xpcall(function()

            Expire_Parry_History()

            Apply_FOV()

            Sync_Avatar()

            Sync_Custom_Win()

            Sync_Winstreak()

            Immortal_Tick()

            Sync_Skin_Changer()

            Sync_Slash_Color()

            Sync_Staff()

            if Cfg.DeviceSpoofPulse and Cfg.DeviceSpoofPulse ~= Device_State.Spoof then

                Device_State.Spoof = Cfg.DeviceSpoofPulse

                Apply_Device_Spoofer(false)

            end

            if Cfg.DeviceSpoofRejoinPulse and Cfg.DeviceSpoofRejoinPulse ~= Device_State.Rejoin then

                Device_State.Rejoin = Cfg.DeviceSpoofRejoinPulse

                Apply_Device_Spoofer(true)

            end

        end, function(Error)

            Log('Error', 'Funciones', tostring(Error))

        end)

    end



    Setup_Detections()

    RunService.Heartbeat:Connect(Feature_Tick)

    task.spawn(Feature_Tick)



    local Is_Curved_Data = {}

    local function GetCurveData(ball)

        if Is_Curved_Data[ball] then return Is_Curved_Data[ball] end

        local data = {

            Curving = 0, Lerp_Radians = 0, Last_Warping = 0,

            Dot = 0, Flips = 0, Flip_Time = 0,

            Backward_Dot = 0, Backward_Flips = 0, Backward_Flip_Time = 0,

            Returned = false, Target_Count = 0,

        }

        Is_Curved_Data[ball] = data

        local function updateFrom()

            local from = ball:GetAttribute("from")

            if from == LP.Name and data.First_Hit then

                data.Returned = true

            elseif from and from ~= "" and from ~= LP.Name then

                data.First_Hit = data.First_Hit or from

                data.Returned = false

            end

        end

        data.FromConn   = ball:GetAttributeChangedSignal("from"):Connect(updateFrom)

        data.TargetConn = ball:GetAttributeChangedSignal("target"):Connect(function()

            local currentTarget = ball:GetAttribute("target")

            if currentTarget ~= LP.Name then

                -- ใช้ Unlock_Parry แทนเพื่อยกเลิก task และ reset seq ด้วย

                Unlock_Parry(ball, nil)

            end

            data.Target_Count = (data.Target_Count or 0) + 1

        end)

        updateFrom()

        return data

    end



    shared._TargetStartedDist = shared._TargetStartedDist or {}



    local lerp_radians = 0

    local last_warping = os.clock()

    local curving_tick = os.clock()



    local function IsCurvedAdvanced(ball)

        local status, err = pcall(function()

            if not ball or not ball.Parent then return false end

            local zoomies = ball:FindFirstChild("zoomies")

            if not zoomies then return false end

            local velocity = zoomies.VectorVelocity or zoomies.Velocity

            if not velocity then return false end

            local speed = velocity.Magnitude

            if speed < 1 then return false end

            

            local char = game:GetService("Players").LocalPlayer.Character

            if not char or not char.PrimaryPart then return false end

            

            local pos = char.PrimaryPart.Position

            local direction = (pos - ball.Position).Unit

            local ball_dir = velocity.Unit

            local dot = direction:Dot(ball_dir)

            

            local distance = (pos - ball.Position).Magnitude

            if ball:GetAttribute("target") == game:GetService("Players").LocalPlayer.Name then

                if not shared._TargetStartedDist[ball] then

                    local pingMs  = GetPing() or 30

                    local pingBuf = math.clamp((pingMs - 30) / 1000 * speed, 0, 8)

                    shared._TargetStartedDist[ball] = math.max(distance / 3 - pingBuf, 4)

                end

                if distance <= shared._TargetStartedDist[ball] then

                    local char2 = game:GetService("Players").LocalPlayer.Character

                    local hrp2  = char2 and char2.PrimaryPart

                    if hrp2 and hrp2.Position.Y <= ball.Position.Y + 0.5 then

                        shared._TargetStartedDist[ball] = nil

                    else

                        return false

                    end

                end

            else

                shared._TargetStartedDist[ball] = nil

            end

            

            if Cfg.apearly then

            if dot > 0.8165 or (dot > 0.757 and distance <= 15) then            

                return false            

            end

            elseif dot > 0.92 or (dot > 0.87 and distance <= 8) then

            return false

            end

            

            local current_ping = (GetPing() or 30) / 1000

            if pos.Y > ball.Position.Y + 1 then return false end

            

            local reach_time = distance / speed - current_ping

            local dot_threshold = math.clamp(0.55 - (current_ping * 0.75), -1, 0.45)

            local speed_threshold = math.min(speed / 100, 45)

            local ball_distance_threshold = 15 - math.min(distance / 1000, 15) + speed_threshold

            local clamped_dot = math.clamp(dot, -1, 1)

            local radians = math.asin(clamped_dot)

            

            lerp_radians = lerp_radians + (radians - lerp_radians) * 0.85

            if lerp_radians < 0.016 or dot > 0.81238 then 

                last_warping = os.clock() 

            end

            if distance < (ball_distance_threshold * 0.85) then 

                return false 

            end

            if (os.clock() - last_warping) < (reach_time / 1.5) then 

                return true 

            end

            if (os.clock() - curving_tick) < (reach_time / 1.5) then 

                return true 

            end

            return dot < dot_threshold

        end)

        if not status then return false end

        return err

    end



    RS.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(a, b)

        local char = game:GetService("Players").LocalPlayer.Character

        local primary = char and char.PrimaryPart

        if b ~= primary then

            local ball = GetBall()

            if ball and primary then

                local distance = (primary.Position - ball.Position).Magnitude

                local zoomies = ball:FindFirstChild("zoomies")

                local speed = zoomies and zoomies.VectorVelocity.Magnitude or 1

                local pings = GetPing()

                local speed_threshold = math.min(speed / 100, 40)

                local reach_time = distance / speed - (pings / 1000)

                local ball_distance_threshold = 15 - math.min(distance / 1000, 15) + speed_threshold

                if speed > 1 and reach_time > pings / 10 then

                    ball_distance_threshold = math.max(ball_distance_threshold - 15, 15)

                end

                if distance > ball_distance_threshold then

                    curving_tick = os.clock()

                end

            end

        end

    end)



    if shared._VisualCDConn then

        shared._VisualCDConn:Disconnect()

        shared._VisualCDConn = nil

    end



    activeParryTasks = activeParryTasks or {}



    shared._VisualCDConn = RS.Remotes.VisualCD.OnClientEvent:Connect(function(block, active, duration)

        xpcall(function()

            local ball = GetBall()

            if not ball then return end



            -- Cfg.Cooldown is already in seconds (slider value * 0.01)

            local cooldownSec = math.max(tonumber(Cfg.Cooldown) or 0.5, 0.01)



            if block == true and active == true then

                -- Server บอกว่า cooldown เริ่ม — lock ทันที

                Lock_Parry(ball, os.clock())



            elseif block == true and active == nil and duration == nil then

                -- Cooldown ended signal — schedule unlock

                local seq = Lock_Parry(ball, os.clock())



                if Cfg.AutoCooldownMode and Cfg.CooldownProtection then

                    -- Auto Cooldown: poll every frame and unlock the moment

                    -- cooldownSec has elapsed — fastest window, no double-fire because

                    -- _firedThisStep guard handles PreSimulation within the same step.

                    local t0 = os.clock()

                    activeParryTasks[ball] = task.spawn(function()

                        while true do

                            task.wait()  -- yield one frame

                            if _lockSeq[ball] ~= seq then break end  -- superseded

                            if (os.clock() - t0) >= cooldownSec then

                                Unlock_Parry(ball, seq)

                                activeParryTasks[ball] = nil

                                break

                            end

                        end

                    end)

                else

                    activeParryTasks[ball] = task.delay(cooldownSec, function()

                        Unlock_Parry(ball, seq)

                        activeParryTasks[ball] = nil

                    end)

                end

            end

        end, function(err) end)

    end)



    local LastSingularityActiveTime = 0

    local LastFrameTarget = {}

    local _parryConn = nil



    local function StartParryLoop()

        if _parryConn then _parryConn:Disconnect(); _parryConn = nil end



        -- Frame-level dedup: reset after each physics step via Stepped

        local _firedThisStep = false

        RunService.Stepped:Connect(function() _firedThisStep = false end)



        local loopFn = function(Delta)

            xpcall(function()

                local char = GetChar()

                local hrp  = GetHRP(char)

                local hum  = GetHum(char)

                if not hrp or not hum or hum.Health <= 0 then return end



                -- Training mode: ถ้าไม่อยู่ใน Alive อนุญาต Training ball แต่ lock

                -- triggerbot/detection ไว้ (ไม่มีคู่ต่อสู้ใน training)

                local alive    = workspace:FindFirstChild("Alive")

                local inAlive  = alive and char:IsDescendantOf(alive)



                local balls = GetBalls()   -- อัพเดท BallState ด้วย

                if #balls == 0 then

                    Spam_State.Accumulator = 0

                    return

                end



                local myPos = hrp.Position

                local now   = os.clock()



                -- Spam engine (อยู่ก่อน AutoParry gate เสมอ)

                Spam_Tick(Delta, balls[1])



                if not Cfg.AutoParry then return end



                -- หา ball ที่ target เรา (จาก BallState แล้ว)

                local ball = BallState.ball

                if not ball or not ball.Parent then return end



                local isTargetingMe = BallState.targetMe

                local target        = BallState.targetName



                -- Training mode: target attribute อาจว่าง (ไม่มีคู่ต่อสู้)

                -- ถ้าอยู่ใน training ให้ถือว่า target เราเสมอถ้า ball ใกล้สุด

                if BallState.isTraining and not isTargetingMe then

                    isTargetingMe = (BallState.dist < 60)

                end



                --=============================================================

                -- COOLDOWN PROTECTION — ใช้ Unlock_Parry แทน raw write

                -- ตรวจจาก BallState.targetName ซึ่งอัพเดทจาก GetBalls() ทุก frame

                --=============================================================

                if Cfg.CooldownProtection then

                    local now2 = os.clock()

                    for b, locked in pairs(parryLocked) do

                        if not locked then

                            if (lockTime[b] or 0) > 0 then lockTime[b] = 0 end

                        else

                            local bt = b and b.Parent and b:GetAttribute("target")

                            local targetChanged = bt ~= nil and bt ~= LP.Name

                            local froze = (lockTime[b] or 0) > 0 and (now2 - lockTime[b]) > 0.65

                            if targetChanged or froze then

                                Unlock_Parry(b, nil)

                            end

                        end

                    end

                end



                if parryLocked[ball] == true then return end



                local ballPos = GetBallPos(ball)

                local vel     = GetBallVel(ball)

                local speed   = vel.Magnitude

                local dist    = (myPos - ballPos).Magnitude

                local ping    = GetPing()



                -- Triggerbot (ใช้เฉพาะใน Alive mode)

                if inAlive and Cfg.Triggerbot and isTargetingMe

                    and not Has_Singularity_Cape() and not Trigger_State.Parrying then

                    Trigger_State.Parrying = true

                    FireParry(ball, true)

                    ball:GetAttributeChangedSignal("target"):Once(function()

                        Trigger_State.Parrying = false

                    end)

                    task.delay(1, function() Trigger_State.Parrying = false end)

                    return

                end



                -- Detection gate (เฉพาะ Alive)

                if inAlive and Detection_Blocked(ball) then return end



                -- Singularity cape

                local isSingularActiveNow = (char:GetAttribute("IS_EVENT_SINGULARITY") == true)

                if isSingularActiveNow then LastSingularityActiveTime = now end

                if (now - LastSingularityActiveTime) <= 0.1 then

                    if dist <= 12 and speed <= 8 then return end

                end



                local curvedVirex = IsCurvedAdvanced(ball)



                local cap  = math.min(math.max(speed - 9.5, 0), 650)

                local div  = (2.4 + cap * 0.002) * (Cfg.Accuracy and (0.7 + (Cfg.Accuracy - 1) * (0.9 / 99)) or 1.1)

                local zone = math.clamp(ping / 10, 5, 17) + math.max(speed / div, 9.5)

                if speed >= 450 then

                    zone = zone + (speed / 500) * math.clamp(ping / 10, 4, 11)

                end



                local trigger = false

                if dist <= 14.5 then

                    trigger = true

                elseif dist <= zone and not curvedVirex then

                    trigger = true

                end



                -- Tornado delay parry

                local tornado      = workspace:FindFirstChild("Runtime") and workspace.Runtime:FindFirstChild("Tornado")

                local tornadoTime  = tornado and (tornado:GetAttribute("TornadoTime") or 1)

                local isAerodynamic = ball:GetAttribute("AerodynamicTime") or 0



                if isTargetingMe and inAlive then

                    if LastFrameTarget[ball] == LP.Name and tornado

                        and (now - isAerodynamic) < (tornadoTime + 0.314159) then

                        trigger = false

                        local seq = Lock_Parry(ball, now)

                        task.delay(0.12, function()

                            xpcall(function()

                                if ball and ball.Parent then

                                    if tostring(ball:GetAttribute("target") or "") == LP.Name then

                                        Unlock_Parry(ball, seq)

                                        FireParry(ball, false)

                                    else

                                        Unlock_Parry(ball, seq)

                                    end

                                end

                            end, function() end)

                        end)

                    end

                end



                LastFrameTarget[ball] = target



                -- ============================================================

                -- TRIGGER — single fire gate, anti double-click

                -- ============================================================

                if trigger then

                    if not isTargetingMe then return end

                    local fst = getgenv().FlyteBB_State

                    if fst then

                        if fst.ParryCooldownUntil and now < fst.ParryCooldownUntil then return end

                        if fst.ExtraParryCooldownUntil and now < fst.ExtraParryCooldownUntil then return end

                        fst.ExtraParryCooldownUntil = nil

                    end

                    local ballLastFire = lastHitTick[ball] or 0

                    local pingS        = ping / 1000

                    -- minWindow ป้องกัน double-click: ไม่ยิงซ้ำในช่วง ping+0.1

                    local minWindow    = math.clamp(pingS + 0.1, 0.15, 1)

                    local recentlySent = fst and fst.AutoParryAt and (now - fst.AutoParryAt) <= minWindow



                    local triggerGap = (Cfg.TriggerParryGap or 3) * 0.01

                    if not recentlySent

                        and not _firedThisStep

                        and (now - lastParryTime) >= triggerGap

                        and (now - ballLastFire)  >= minWindow then



                        _firedThisStep = true

                        local seq = Lock_Parry(ball, now)

                        lastHitTick[ball] = now



                        local usedAbility = Try_Auto_Ability()

                        if usedAbility then

                            -- Auto Ability ถูกใช้ — รอ target เปลี่ยนแล้วค่อย unlock

                            -- ใช้ connection แบบ once ไม่ใช่ loop

                            local abilityConn

                            abilityConn = ball:GetAttributeChangedSignal("target"):Connect(function()

                                local newTarget = ball and ball.Parent and ball:GetAttribute("target")

                                if newTarget ~= LP.Name then

                                    Unlock_Parry(ball, seq)

                                    if abilityConn then abilityConn:Disconnect() end

                                end

                            end)

                            -- safety timeout: unlock หลัง 3 วิถ้า signal ไม่ fire

                            task.delay(3, function()

                                Unlock_Parry(ball, seq)

                                if abilityConn then pcall(function() abilityConn:Disconnect() end) end

                            end)

                        else

                            FireParry(ball, false)

                        end



                        lastParryTime = now

                        if fst then fst.AutoParryAt = now end

                    end

                end



            end, function(e) end)

        end



        _parryConn = RunService.PreSimulation:Connect(loopFn)

    end



    StartParryLoop()

    

    



    if not sendParry and not _firstSignal and not (_reverted and next(_reverted) ~= nil) then

        Log('Warning', 'Bypass', 'No se detectó bypass: usando la entrada alternativa.')

    end



    --=================================================================

    -- MANUAL SPAM — direct-fire, no range/condition gate

    -- Uses RunService.Heartbeat accumulator driven by CPS (same field

    -- the auto-spam uses) so both modes share one config slider.

    -- Independent of the auto-spam condition checks — fires as long as

    -- the floating toggle is ON, nothing else required.

    --=================================================================

    local ManualSpam_State = {

        Active      = false,  -- controlled only by floating toggle (open/close)

        Accumulator = 0,

        -- rolling FPS estimate from Heartbeat deltas, no yielding

        FPS_Acc     = 0,

        FPS_Frames  = 0,

        FPS_Est     = 60,

        FPS_Clock   = 0,

    }



    local function ManualSpam_Tick(Delta)

        -- pure open/close gate — no range, no conditions, nothing else

        if not ManualSpam_State.Active then

            ManualSpam_State.Accumulator = 0

            return

        end



        -- rolling FPS estimate: average delta over 0.5s windows, no yield

        ManualSpam_State.FPS_Acc    = ManualSpam_State.FPS_Acc + Delta

        ManualSpam_State.FPS_Frames = ManualSpam_State.FPS_Frames + 1

        local now = os.clock()

        if (now - ManualSpam_State.FPS_Clock) >= 0.5 then

            if ManualSpam_State.FPS_Acc > 0 then

                ManualSpam_State.FPS_Est = ManualSpam_State.FPS_Frames / ManualSpam_State.FPS_Acc

            end

            ManualSpam_State.FPS_Acc    = 0

            ManualSpam_State.FPS_Frames = 0

            ManualSpam_State.FPS_Clock  = now

        end



        local CPS = tonumber(Cfg.CPS) or 60

        if CPS <= 0 then return end



        -- burst cap scales with FPS so one slow frame doesn't dump 20 remotes at once

        -- and fast ball speed earns +1–2 extra shots

        local ball = GetBall()

        local ballSpeed = ball and GetBallVel(ball).Magnitude or 0

        local fpsCap    = math.clamp(ManualSpam_State.FPS_Est / 10, 1, 8)

        local speedBonus = math.clamp(ballSpeed / 200, 0, 8)

        local burstCap  = math.max(1, math.floor(fpsCap + speedBonus))



        ManualSpam_State.Accumulator = ManualSpam_State.Accumulator + Delta

        local Shots = math.floor(ManualSpam_State.Accumulator * CPS)

        if Shots <= 0 then return end

        ManualSpam_State.Accumulator = ManualSpam_State.Accumulator - (Shots / CPS)

        if ManualSpam_State.Accumulator < 0 then ManualSpam_State.Accumulator = 0 end

        if Shots > burstCap then Shots = burstCap end



        for _ = 1, Shots do

            pcall(FireParry, ball, true)

            Record_Parry()

        end

    end



    -- build the floating switch GUI and wire V-key to toggle

    local function BuildFloatingSwitch()

        local TweenService     = game:GetService('TweenService')

        local UserInputService = game:GetService('UserInputService')

        local CoreGui          = game:GetService('CoreGui')



        if CoreGui:FindFirstChild('StellarFloatingToggle') then

            CoreGui.StellarFloatingToggle:Destroy()

        end



        local Style = Cfg.ManualSpamStyle or 'Default'

        -- Default    = rectangle card, full label (original look)

        -- Rectangle  = wider flat pill, label centred, cyan accent

        -- Square     = square badge, label hidden, corner radius small

        -- Circle     = circular badge, label hidden, full radius



        local FloatCfg = {

            Title         = 'SPAM',

            Keybind       = Enum.KeyCode.V,

            StartPosition = UDim2.new(1, -190, 1, -168),

            ColorOff      = Color3.fromRGB(40, 40, 46),

            ColorOn       = Color3.fromRGB(48, 224, 158),

            KnobColor     = Color3.fromRGB(248, 248, 252),

        }



        if Style == 'Rectangle' then

            FloatCfg.ColorOn = Color3.fromRGB(80, 200, 255)

        elseif Style == 'Square' then

            FloatCfg.ColorOn = Color3.fromRGB(220, 90, 255)

            FloatCfg.Title   = ''

        elseif Style == 'Circle' then

            FloatCfg.ColorOn = Color3.fromRGB(255, 160, 60)

            FloatCfg.Title   = ''

        end



        local IsOn = false



        local screenGui = Instance.new('ScreenGui')

        screenGui.Name = 'StellarFloatingToggle'

        screenGui.ResetOnSpawn = false

        screenGui.IgnoreGuiInset = true

        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        screenGui.Enabled = Cfg.ManualSpam

        screenGui.Parent = CoreGui



        -- Style sizing:

        -- Default    168x114  card r16  — original rectangle card, track + status row

        -- Rectangle  180x60   card r10  — wide flat pill, only track

        -- Square     80x80    card r12  — square badge, only track + colour dot

        -- Circle     80x80    card r40  — full circle, only colour indicator

        local rootW  = (Style == 'Circle' or Style == 'Square') and 80

                    or (Style == 'Rectangle') and 180

                    or 168

        local rootH  = (Style == 'Circle' or Style == 'Square') and 80

                    or (Style == 'Rectangle') and 60

                    or 114

        local cardW  = rootW - 18

        local cardH  = rootH - 18

        local radius = (Style == 'Circle') and 40

                    or (Style == 'Square')  and 12

                    or (Style == 'Rectangle') and 10

                    or 16



        local root = Instance.new('CanvasGroup')

        root.Name = 'Root'

        root.Size = UDim2.fromOffset(rootW, rootH)

        root.Position = FloatCfg.StartPosition

        root.BackgroundTransparency = 1

        root.GroupTransparency = 1

        root.Parent = screenGui



        local rootScale = Instance.new('UIScale')

        rootScale.Scale = 0.75

        rootScale.Parent = root



        local shadow = Instance.new('Frame')

        shadow.AnchorPoint = Vector2.new(0.5, 0.5)

        shadow.Position = UDim2.new(0.5, 0, 0.5, 4)

        shadow.Size = UDim2.fromOffset(cardW + 4, cardH + 4)

        shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

        shadow.BackgroundTransparency = 0.5

        shadow.BorderSizePixel = 0

        shadow.ZIndex = 0

        shadow.Parent = root

        Instance.new('UICorner', shadow).CornerRadius = UDim.new(0, radius + 2)



        local card = Instance.new('Frame')

        card.AnchorPoint = Vector2.new(0.5, 0.5)

        card.Position = UDim2.new(0.5, 0, 0.5, 0)

        card.Size = UDim2.fromOffset(cardW, cardH)

        card.BackgroundColor3 = (Style == 'New2') and Color3.fromRGB(18, 18, 22) or Color3.fromRGB(24, 24, 29)

        card.BackgroundTransparency = 0.05

        card.BorderSizePixel = 0

        card.ZIndex = 1

        card.Parent = root

        Instance.new('UICorner', card).CornerRadius = UDim.new(0, radius)

        local cardStroke = Instance.new('UIStroke')

        cardStroke.Color = (Style ~= 'Classic') and FloatCfg.ColorOn or Color3.fromRGB(255, 255, 255)

        cardStroke.Transparency = (Style ~= 'Classic') and 0.6 or 0.91

        cardStroke.Thickness = 1

        cardStroke.Parent = card

        local cg = Instance.new('UIGradient')

        cg.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 34, 40)), ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 20)) })

        cg.Rotation = 60

        cg.Parent = card



        local title = Instance.new('TextLabel')

        title.BackgroundTransparency = 1

        title.Size = UDim2.new(1, -16, 0, 16)

        title.Position = UDim2.new(0, 8, 0, (Style == 'New2') and 4 or 8)

        title.Font = Enum.Font.GothamBold

        title.Text = FloatCfg.Title

        title.TextSize = (Style == 'New2') and 10 or 12

        title.TextColor3 = (Style == 'Classic') and Color3.fromRGB(195, 195, 205) or FloatCfg.ColorOn

        title.TextTransparency = (Style == 'New2') and 0.3 or 0.1

        title.TextXAlignment = Enum.TextXAlignment.Center

        title.TextScaled = true

        title.ZIndex = 2

        title.Parent = card

        local tc2 = Instance.new('UITextSizeConstraint', title)

        tc2.MaxTextSize = (Style == 'New2') and 10 or 12; tc2.MinTextSize = 8



        -- Track/knob layout per style

        local trackY  = (Style == 'Circle' or Style == 'Square') and (cardH // 2 + 2)

                     or (Style == 'Rectangle') and (cardH // 2 + 2)

                     or 46

        local trackW  = (Style == 'Circle' or Style == 'Square') and 44

                     or (Style == 'Rectangle') and 60

                     or 72

        local trackH  = (Style == 'Circle' or Style == 'Square') and 24

                     or (Style == 'Rectangle') and 26

                     or 34

        local knobSz  = (Style == 'Circle' or Style == 'Square') and 18

                     or (Style == 'Rectangle') and 20

                     or 28

        local statusY = 70  -- only used by Default; hidden otherwise



        local glowOuter = Instance.new('Frame')

        glowOuter.AnchorPoint = Vector2.new(0.5, 0.5)

        glowOuter.Position = UDim2.new(0.5, 0, 0, trackY)

        glowOuter.Size = UDim2.fromOffset(trackW + 32, trackH + 30)

        glowOuter.BackgroundColor3 = FloatCfg.ColorOn

        glowOuter.BackgroundTransparency = 1

        glowOuter.BorderSizePixel = 0

        glowOuter.ZIndex = 1

        glowOuter.Parent = card

        Instance.new('UICorner', glowOuter).CornerRadius = UDim.new(1, 0)



        local glowInner = Instance.new('Frame')

        glowInner.AnchorPoint = Vector2.new(0.5, 0.5)

        glowInner.Position = UDim2.new(0.5, 0, 0, trackY)

        glowInner.Size = UDim2.fromOffset(trackW + 12, trackH + 14)

        glowInner.BackgroundColor3 = FloatCfg.ColorOn

        glowInner.BackgroundTransparency = 1

        glowInner.BorderSizePixel = 0

        glowInner.ZIndex = 1

        glowInner.Parent = card

        Instance.new('UICorner', glowInner).CornerRadius = UDim.new(1, 0)



        local track = Instance.new('Frame')

        track.Name = 'Track'

        track.Active = true

        track.AnchorPoint = Vector2.new(0.5, 0.5)

        track.Position = UDim2.new(0.5, 0, 0, trackY)

        track.Size = UDim2.fromOffset(trackW, trackH)

        track.BackgroundColor3 = FloatCfg.ColorOff

        track.BorderSizePixel = 0

        track.ZIndex = 2

        track.Parent = card

        Instance.new('UICorner', track).CornerRadius = UDim.new(1, 0)

        local trkStroke = Instance.new('UIStroke')

        trkStroke.Color = Color3.fromRGB(64, 64, 72)

        trkStroke.Thickness = 1.5

        trkStroke.Transparency = 0.2

        trkStroke.Parent = track

        local trkGrad = Instance.new('UIGradient')

        trkGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))

        trkGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(0.5, 0.94), NumberSequenceKeypoint.new(1, 1) })

        trkGrad.Rotation = 90

        trkGrad.Parent = track



        local knob = Instance.new('Frame')

        knob.Name = 'Knob'

        knob.AnchorPoint = Vector2.new(0, 0.5)

        knob.Position = UDim2.new(0, 3, 0.5, 0)

        knob.Size = UDim2.fromOffset(knobSz, knobSz)

        knob.BackgroundColor3 = FloatCfg.KnobColor

        knob.BorderSizePixel = 0

        knob.ZIndex = 3

        knob.Parent = track

        Instance.new('UICorner', knob).CornerRadius = UDim.new(1, 0)

        local knobStroke = Instance.new('UIStroke')

        knobStroke.Color = Color3.fromRGB(224, 224, 230)

        knobStroke.Thickness = 1

        knobStroke.Transparency = 0.5

        knobStroke.Parent = knob



        local statusRow = Instance.new('Frame')

        statusRow.AnchorPoint = Vector2.new(0.5, 0)

        statusRow.Position = UDim2.new(0.5, 0, 0, statusY)

        statusRow.Size = UDim2.new(1, -16, 0, 20)

        statusRow.Visible = (Style == 'Default')

        statusRow.BackgroundTransparency = 1

        statusRow.ZIndex = 2

        statusRow.Parent = card

        local sLayout = Instance.new('UIListLayout', statusRow)

        sLayout.FillDirection = Enum.FillDirection.Horizontal

        sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        sLayout.VerticalAlignment = Enum.VerticalAlignment.Center

        sLayout.Padding = UDim.new(0, 6)

        sLayout.SortOrder = Enum.SortOrder.LayoutOrder



        local dot = Instance.new('Frame')

        dot.Size = UDim2.fromOffset(8, 8)

        dot.BackgroundColor3 = FloatCfg.ColorOff

        dot.BorderSizePixel = 0

        dot.LayoutOrder = 1

        dot.ZIndex = 2

        dot.Parent = statusRow

        Instance.new('UICorner', dot).CornerRadius = UDim.new(1, 0)



        local statusText = Instance.new('TextLabel')

        statusText.BackgroundTransparency = 1

        statusText.Size = UDim2.fromOffset(28, 16)

        statusText.Font = Enum.Font.GothamBold

        statusText.Text = 'OFF'

        statusText.TextSize = 12

        statusText.TextColor3 = Color3.fromRGB(150, 150, 160)

        statusText.TextXAlignment = Enum.TextXAlignment.Left

        statusText.LayoutOrder = 2

        statusText.ZIndex = 2

        statusText.Parent = statusRow



        local keyTag = Instance.new('TextLabel')

        keyTag.AutomaticSize = Enum.AutomaticSize.X

        keyTag.Size = UDim2.fromOffset(0, 18)

        keyTag.BackgroundColor3 = Color3.fromRGB(32, 32, 38)

        keyTag.Font = Enum.Font.GothamBold

        keyTag.Text = FloatCfg.Keybind.Name

        keyTag.TextSize = 11

        keyTag.TextColor3 = Color3.fromRGB(205, 205, 215)

        keyTag.LayoutOrder = 3

        keyTag.ZIndex = 2

        keyTag.Parent = statusRow

        Instance.new('UICorner', keyTag).CornerRadius = UDim.new(0, 5)

        local ktStroke = Instance.new('UIStroke', keyTag)

        ktStroke.Color = Color3.fromRGB(68, 68, 76); ktStroke.Thickness = 1

        local ktPad = Instance.new('UIPadding', keyTag)

        ktPad.PaddingLeft = UDim.new(0, 7); ktPad.PaddingRight = UDim.new(0, 7)



        local knobTravel = trackW - knobSz - 3

        local function applyVisualState(on, animated)

            local q  = TweenInfo.new(animated and 0.2 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            local qk = TweenInfo.new(animated and 0.28 or 0, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

            local kp = on and UDim2.new(0, knobTravel, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)

            TweenService:Create(track, q, { BackgroundColor3 = on and FloatCfg.ColorOn or FloatCfg.ColorOff }):Play()

            TweenService:Create(trkStroke, q, { Color = on and FloatCfg.ColorOn or Color3.fromRGB(64, 64, 72) }):Play()

            TweenService:Create(knob, qk, { Position = kp }):Play()

            TweenService:Create(dot, q, { BackgroundColor3 = on and FloatCfg.ColorOn or Color3.fromRGB(90, 90, 98) }):Play()

            TweenService:Create(statusText, q, { TextColor3 = on and FloatCfg.ColorOn or Color3.fromRGB(150, 150, 160) }):Play()

            TweenService:Create(glowOuter, q, { BackgroundTransparency = on and 0.82 or 1 }):Play()

            TweenService:Create(glowInner, q, { BackgroundTransparency = on and 0.7 or 1 }):Play()

            statusText.Text = on and 'ON' or 'OFF'

        end



        local function toggleState()

            IsOn = not IsOn

            ManualSpam_State.Active = IsOn

            ManualSpam_State.Accumulator = 0

            applyVisualState(IsOn, true)

        end



        applyVisualState(false, false)



        -- drag logic

        local dragging, moved = false, false

        local dragStart, startPos = Vector2.zero, Vector2.zero

        local DRAG_TOL = 4



        track.InputBegan:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

                dragging = true; moved = false

                dragStart = Vector2.new(input.Position.X, input.Position.Y)

                startPos = root.AbsolutePosition

                TweenService:Create(track, TweenInfo.new(0.12), { Size = UDim2.fromOffset(76, 36) }):Play()

            end

        end)

        UserInputService.InputChanged:Connect(function(input)

            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then

                local pt = Vector2.new(input.Position.X, input.Position.Y)

                local delta = pt - dragStart

                if delta.Magnitude > DRAG_TOL then moved = true end

                local cam = workspace.CurrentCamera

                local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)

                local sz = root.AbsoluteSize

                local x = math.clamp(startPos.X + delta.X, 0, math.max(vp.X - sz.X, 0))

                local y = math.clamp(startPos.Y + delta.Y, 0, math.max(vp.Y - sz.Y, 0))

                root.Position = UDim2.fromOffset(x, y)

            end

        end)

        UserInputService.InputEnded:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

                if dragging then

                    dragging = false

                    TweenService:Create(track, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(72, 34) }):Play()

                    if not moved then toggleState() end

                end

            end

        end)

        UserInputService.InputBegan:Connect(function(input, gp)

            if gp then return end

            if input.KeyCode == FloatCfg.Keybind then

                toggleState()

                local resting = keyTag.BackgroundColor3

                TweenService:Create(keyTag, TweenInfo.new(0.06), { BackgroundColor3 = FloatCfg.ColorOn }):Play()

                task.delay(0.15, function()

                    TweenService:Create(keyTag, TweenInfo.new(0.25), { BackgroundColor3 = resting }):Play()

                end)

            end

        end)



        TweenService:Create(root, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 }):Play()

        TweenService:Create(rootScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

    end



    -- expose builder to menu

    Cfg.__BuildFloatingSwitch = BuildFloatingSwitch

    if Cfg.ManualSpam then BuildFloatingSwitch() end



    -- hook ManualSpam_Tick into the existing heartbeat

    local _manualSpamConn = RunService.Heartbeat:Connect(function(Delta)

        ManualSpam_Tick(Delta)

    end)



    --=================================================================

    -- PLAYER MOVEMENT SYSTEMS (merged from normal.txt)

    --=================================================================

    local UIS_Mov = cloneref(game:GetService('UserInputService'))



    local function GetMovChar() return LP.Character end

    local function GetMovHRP(c) return c and (c.PrimaryPart or c:FindFirstChild('HumanoidRootPart')) end

    local function GetMovHum(c) return c and c:FindFirstChildOfClass('Humanoid') end



    -- 1. WALKSPEED

    task.spawn(function()

        while true do

            task.wait(0.2)

            if Cfg.SpeedEnabled then

                local hum = GetMovHum(GetMovChar())

                if hum and hum.WalkSpeed ~= Cfg.SpeedValue then

                    pcall(function() hum.WalkSpeed = Cfg.SpeedValue end)

                end

            end

        end

    end)



    -- 2. JUMP POWER

    task.spawn(function()

        while true do

            task.wait(0.2)

            if Cfg.JumpEnabled then

                local hum = GetMovHum(GetMovChar())

                if hum then

                    pcall(function()

                        hum.UseJumpPower = true

                        if hum.JumpPower ~= Cfg.JumpValue then

                            hum.JumpPower = Cfg.JumpValue

                        end

                    end)

                end

            end

        end

    end)



    -- 3. FLY SYSTEM

    local _flyConn_Mov, _flyBV_Mov, _flyGyro_Mov = nil, nil, nil



    local function StopFly_Mov()

        if _flyConn_Mov then _flyConn_Mov:Disconnect(); _flyConn_Mov = nil end

        pcall(function() if _flyBV_Mov   then _flyBV_Mov:Destroy()   end end); _flyBV_Mov   = nil

        pcall(function() if _flyGyro_Mov then _flyGyro_Mov:Destroy() end end); _flyGyro_Mov = nil

        local hum = GetMovHum(GetMovChar())

        if hum then pcall(function() hum.PlatformStand = false end) end

    end



    local function StartFly_Mov()

        local char = GetMovChar()

        local hrp  = GetMovHRP(char)

        local hum  = GetMovHum(char)

        if not hrp or not hum then return end

        StopFly_Mov()

        pcall(function() hum.PlatformStand = true end)



        _flyBV_Mov = Instance.new('BodyVelocity')

        _flyBV_Mov.MaxForce = Vector3.new(1e9, 1e9, 1e9)

        _flyBV_Mov.Velocity  = Vector3.zero

        _flyBV_Mov.Parent    = hrp



        _flyGyro_Mov = Instance.new('BodyGyro')

        _flyGyro_Mov.MaxTorque = Vector3.new(1e9, 1e9, 1e9)

        _flyGyro_Mov.P         = 9e4

        _flyGyro_Mov.Parent    = hrp



        _flyConn_Mov = RunService.RenderStepped:Connect(function()

            if not Cfg.FlyEnabled or not hrp or not _flyBV_Mov or not _flyGyro_Mov then

                StopFly_Mov(); return

            end

            pcall(function() hum.PlatformStand = true end)

            local cam = workspace.CurrentCamera

            if not cam then return end

            _flyGyro_Mov.CFrame = cam.CFrame



            local mv = hum.MoveDirection

            if mv.Magnitude == 0 then

                if UIS_Mov:IsKeyDown(Enum.KeyCode.W) then mv = mv + Vector3.new(0,0,-1) end

                if UIS_Mov:IsKeyDown(Enum.KeyCode.S) then mv = mv + Vector3.new(0,0, 1) end

                if UIS_Mov:IsKeyDown(Enum.KeyCode.A) then mv = mv + Vector3.new(-1,0,0) end

                if UIS_Mov:IsKeyDown(Enum.KeyCode.D) then mv = mv + Vector3.new( 1,0,0) end

            end

            local sp  = Cfg.FlySpeed or 50

            local dir = cam.CFrame:VectorToWorldSpace(mv)

            local vy  = 0

            if UIS_Mov:IsKeyDown(Enum.KeyCode.Space)      then vy =  sp end

            if UIS_Mov:IsKeyDown(Enum.KeyCode.LeftControl) then vy = -sp end

            _flyBV_Mov.Velocity = (dir * sp) + Vector3.new(0, vy, 0)

        end)

    end



    local _flyWasEnabled = false

    RunService.Heartbeat:Connect(function()

        xpcall(function()

            if Cfg.FlyEnabled ~= _flyWasEnabled then

                _flyWasEnabled = Cfg.FlyEnabled

                if Cfg.FlyEnabled then StartFly_Mov() else StopFly_Mov() end

            end

        end, function() end)

    end)



    LP.CharacterAdded:Connect(function()

        task.wait(0.8)

        if Cfg.FlyEnabled then StartFly_Mov() end

    end)



    -- 4. AUTO JUMP — fires status.jump (HumanoidStateType.Jumping) every heartbeat

    RunService.Heartbeat:Connect(function()

        xpcall(function()

            if not Cfg.AutoJumpEnabled then return end

            local hum = GetMovHum(GetMovChar())

            if not hum or hum.Health <= 0 then return end

            pcall(function()

                hum:ChangeState(Enum.HumanoidStateType.Jumping)

            end)

        end, function() end)

    end)



    -- 5. ANTI-AFK

    task.spawn(function()

        while true do

            task.wait(Cfg.AntiAFKInterval or 28)

            if Cfg.AntiAFKEnabled then

                local hum = GetMovHum(GetMovChar())

                if hum then

                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)

                end

            end

        end

    end)



    -- 6. NOCLIP

    RunService.Stepped:Connect(function()

        xpcall(function()

            if not Cfg.NoclipEnabled then return end

            local char = GetMovChar()

            if not char then return end

            for _, part in ipairs(char:GetDescendants()) do

                if part:IsA('BasePart') then

                    part.CanCollide = false

                end

            end

        end, function() end)

    end)



    -- 7. FREE CAMERA

    local _freecamPos   = Vector3.zero

    local _freecamYaw   = 0

    local _freecamPitch = 0

    local _freecamGui   = nil

    local _ctrlMod      = nil

    pcall(function()

        _ctrlMod = require(LP.PlayerScripts:WaitForChild('PlayerModule'):WaitForChild('ControlModule'))

    end)



    local function RemoveFreecamUI()

        if _freecamGui then _freecamGui:Destroy(); _freecamGui = nil end

    end



    local function CreateFreecamUI()

        if _freecamGui then return end

        local pGui = LP:FindFirstChild('PlayerGui')

        if not pGui then return end

        _freecamGui = Instance.new('ScreenGui')

        _freecamGui.Name = 'MayOsFreecamUI'

        _freecamGui.ResetOnSpawn = false

        _freecamGui.Parent = pGui



        local function mkBtn(text, pos, cbUp, cbDown)

            local b = Instance.new('TextButton')

            b.Size = UDim2.fromOffset(50,50)

            b.Position = pos

            b.BackgroundColor3 = Color3.fromRGB(30,30,45)

            b.BackgroundTransparency = 0.4

            b.TextColor3 = Color3.fromRGB(255,255,255)

            b.TextSize = 18

            b.Font = Enum.Font.GothamBold

            b.Text = text

            b.Parent = _freecamGui

            Instance.new('UICorner',b).CornerRadius = UDim.new(0,8)

            b.MouseButton1Down:Connect(cbDown)

            b.MouseButton1Up:Connect(cbUp)

            b.MouseLeave:Connect(cbUp)

        end

        local ox, oy = 20, -150

        mkBtn('▲', UDim2.new(0,ox+60,1,oy+0),  function() end, function() _freecamPos = _freecamPos + Vector3.new(0,0,-0.5) end)

        mkBtn('▼', UDim2.new(0,ox+60,1,oy+60), function() end, function() _freecamPos = _freecamPos + Vector3.new(0,0, 0.5) end)

        mkBtn('◄', UDim2.new(0,ox+0, 1,oy+60), function() end, function() _freecamPos = _freecamPos + Vector3.new(-0.5,0,0) end)

        mkBtn('►', UDim2.new(0,ox+120,1,oy+60),function() end, function() _freecamPos = _freecamPos + Vector3.new( 0.5,0,0) end)

    end



    UIS_Mov.TouchMoved:Connect(function(touch, processed)

        if Cfg.FreecamEnabled and not processed then

            _freecamYaw   = _freecamYaw   - (touch.Delta.X * 0.005)

            _freecamPitch = math.clamp(_freecamPitch - (touch.Delta.Y * 0.005), -math.rad(89), math.rad(89))

        end

    end)



    UIS_Mov.InputChanged:Connect(function(input, processed)

        if Cfg.FreecamEnabled and input.UserInputType == Enum.UserInputType.MouseMovement then

            if UIS_Mov:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or not UIS_Mov.TouchEnabled then

                _freecamYaw   = _freecamYaw   - (input.Delta.X * 0.003)

                _freecamPitch = math.clamp(_freecamPitch - (input.Delta.Y * 0.003), -math.rad(89), math.rad(89))

            end

        end

    end)



    RunService.RenderStepped:Connect(function(dt)

        xpcall(function()

            local cam = workspace.CurrentCamera

            if Cfg.FreecamEnabled then

                if cam.CameraType ~= Enum.CameraType.Scriptable then

                    _freecamPos   = cam.CFrame.Position

                    _freecamYaw, _freecamPitch, _ = cam.CFrame:ToOrientation()

                    cam.CameraType = Enum.CameraType.Scriptable

                    if _ctrlMod then pcall(function() _ctrlMod:Disable() end) end

                    if UIS_Mov.TouchEnabled then CreateFreecamUI() end

                end

                local md = Vector3.zero

                if UIS_Mov:IsKeyDown(Enum.KeyCode.W) then md = md + Vector3.new(0,0,-1) end

                if UIS_Mov:IsKeyDown(Enum.KeyCode.S) then md = md + Vector3.new(0,0, 1) end

                if UIS_Mov:IsKeyDown(Enum.KeyCode.A) then md = md + Vector3.new(-1,0,0) end

                if UIS_Mov:IsKeyDown(Enum.KeyCode.D) then md = md + Vector3.new( 1,0,0) end

                if UIS_Mov:IsKeyDown(Enum.KeyCode.E) then md = md + Vector3.new(0, 1,0) end

                if UIS_Mov:IsKeyDown(Enum.KeyCode.Q) then md = md + Vector3.new(0,-1,0) end

                local spd = Cfg.FreecamSpeed or 50

                if UIS_Mov:IsKeyDown(Enum.KeyCode.LeftShift) then spd = spd * 3 end

                local rot = CFrame.Angles(0, _freecamYaw, 0) * CFrame.Angles(_freecamPitch, 0, 0)

                _freecamPos = _freecamPos + (rot:VectorToWorldSpace(md) * spd * dt)

                cam.CFrame  = CFrame.new(_freecamPos) * rot

            else

                if cam.CameraType == Enum.CameraType.Scriptable then

                    cam.CameraType = Enum.CameraType.Custom

                    local char = GetMovChar()

                    if char and char:FindFirstChild('Humanoid') then cam.CameraSubject = char.Humanoid end

                    if _ctrlMod then pcall(function() _ctrlMod:Enable() end) end

                    RemoveFreecamUI()

                end

            end

        end, function() end)

    end)



    --=================================================================

    -- BALL STATUS BILLBOARD

    -- แสดง BillboardGui เหนือบอล — target, speed, from, dist

    --=================================================================

    local BallStatusBUI = nil

    local BallStatusLbl = nil



    local function RemoveBallStatusBUI()

        if BallStatusBUI then

            pcall(function() BallStatusBUI:Destroy() end)

            BallStatusBUI = nil

            BallStatusLbl = nil

        end

    end



    local function EnsureBallStatusBUI(ball)

        if BallStatusBUI and BallStatusBUI.Parent and BallStatusBUI.Adornee == ball then return end

        RemoveBallStatusBUI()

        if not ball or not ball.Parent then return end



        local sGui = (gethui and gethui()) or LP:WaitForChild("PlayerGui")

        local bg = Instance.new("BillboardGui")

        bg.Name = "MayOsBallStatus"

        bg.AlwaysOnTop = true

        bg.Size = UDim2.new(0, 160, 0, 54)

        bg.StudsOffset = Vector3.new(0, 2.5, 0)

        bg.Adornee = ball

        bg.ResetOnSpawn = false

        bg.Parent = sGui



        local back = Instance.new("Frame")

        back.Size = UDim2.new(1, 0, 1, 0)

        back.BackgroundColor3 = Color3.fromRGB(14, 14, 18)

        back.BackgroundTransparency = 0.3

        back.BorderSizePixel = 0

        back.Parent = bg

        Instance.new("UICorner", back).CornerRadius = UDim.new(0, 8)



        local stroke = Instance.new("UIStroke")

        stroke.Color = Color3.fromRGB(80, 220, 160)

        stroke.Transparency = 0.5

        stroke.Thickness = 1

        stroke.Parent = back



        local lbl = Instance.new("TextLabel")

        lbl.Size = UDim2.new(1, -8, 1, -6)

        lbl.Position = UDim2.new(0, 4, 0, 3)

        lbl.BackgroundTransparency = 1

        lbl.TextColor3 = Color3.fromRGB(230, 230, 240)

        lbl.TextSize = 11

        lbl.Font = Enum.Font.GothamBold

        lbl.TextXAlignment = Enum.TextXAlignment.Left

        lbl.TextYAlignment = Enum.TextYAlignment.Top

        lbl.TextStrokeTransparency = 0.6

        lbl.RichText = true

        lbl.Text = '—'

        lbl.Parent = back



        BallStatusBUI = bg

        BallStatusLbl = lbl

    end



    local _ballStatusClock = 0

    RunService.Heartbeat:Connect(function()

        xpcall(function()

            if not Cfg.BallStatus then

                if BallStatusBUI then RemoveBallStatusBUI() end

                return

            end

            local now = os.clock()

            if (now - _ballStatusClock) < 0.08 then return end

            _ballStatusClock = now



            local ball = BallState.ball

            if not ball or not ball.Parent then

                RemoveBallStatusBUI(); return

            end



            EnsureBallStatusBUI(ball)

            if not BallStatusLbl then return end



            local target  = tostring(ball:GetAttribute("target") or "—")

            local from    = tostring(ball:GetAttribute("from")   or "—")

            local spd     = math.floor(BallState.speed + 0.5)

            local dist    = math.floor(BallState.dist  + 0.5)

            local tColor  = BallState.targetMe and '<font color="#50DC9C">' or '<font color="#FF6060">'



            BallStatusLbl.Text = string.format(

                '%s▶ %s</font>\n<font color="#AAAACC">vel</font> %d  <font color="#AAAACC">dist</font> %d\n<font color="#888899">de</font> %s',

                tColor, target, spd, dist, from

            )

        end, function() end)

    end)



    --=================================================================

    -- AUTO REWARD SYSTEM (ported from flyte.txt — non-event rewards)

    -- Covers: Daily Login, Playtime Rewards, Daily Quests

    --

    -- Key fixes vs V4:

    --   1. Data comes from replicatedStorage.Packages.Replion (game's

    --      own state replication), not shared/FlyteBB_State

    --   2. Loop sentinel is a unique table, not the coroutine thread

    --      itself — prevents double-spawn on rapid toggle on/off

    --   3. Controller paths match flyte source exactly:

    --        Daily  → Controllers.UI.DailyLoginController

    --        Time   → Controllers.UI.PlaytimeRewardsController

    --        Quests → Controllers.UI.QuestsController

    --=================================================================

    local RS_Rew    = game:GetService('ReplicatedStorage')

    local Rew_Lines = {}  -- [button] = {ID, Check} — pending claim checks

    local Rew_Items = {}  -- registered runners

    local Rew_Token = nil -- sentinel table; nil = loop stopped



    -- Lazy-init the game's Replion Data client (same path as flyte)

    local _RewData = nil

    local function GetRewData()

        if _RewData then return _RewData end

        local ok, v = pcall(function()

            return require(RS_Rew.Packages.Replion).Client:WaitReplion('Data')

        end)

        if ok and v then _RewData = v end

        return _RewData

    end



    local function RewFindUI(...)

        local node = LP:FindFirstChild('PlayerGui')

        for _, n in ipairs({...}) do

            if not node then return nil end

            node = node:FindFirstChild(n)

        end

        return node

    end



    -- Fire a UI button by finding its Activated/MouseButton1Click connection

    -- that belongs to `controller` (a ModuleScript in RS.Controllers).

    local function RewFire(id, button, ctrlName, checkFn, evName)

        if not button then return false end

        if not button.Parent then return false end

        if not button.Visible then return false end

        if Rew_Lines[button] then return false end   -- already pending

        if not getconnections then return false end



        local ctrl = RS_Rew:FindFirstChild('Controllers')

        ctrl = ctrl and ctrl:FindFirstChild('UI') and ctrl.UI:FindFirstChild(ctrlName)



        local ev = button:FindFirstChild(evName or 'Activated')

        if not ev then return false end



        for _, conn in pairs(getconnections(ev)) do

            if conn.Enabled and conn.Function then

                local ok, match = pcall(function()

                    return getfenv(conn.Function).script == ctrl

                end)

                if ok and match then

                    Rew_Lines[button] = { ID = id, Check = checkFn }

                    pcall(function() conn:Fire() end)

                    return true

                end

            end

        end

        return false

    end



    local function RewRegister(id, label, fn, interval)

        Rew_Items[#Rew_Items + 1] = {

            ID = id, Label = label, Run = fn,

            Interval = interval or 5, Next = 0,

        }

    end



    -- ── 1. DAILY LOGIN ──────────────────────────────────────────────

    RewRegister('Claim_Daily_Rewards', 'Auto Claim Daily', function()

        local Data = GetRewData()

        if not Data then return end



        local loginType = Data:Get('CurrentDailyLoginType')

        if not loginType then return end



        local info = Data:Get({'DailyLoginData', loginType})

        if not info or type(info.NextClaim) ~= 'number' then return end

        if workspace:GetServerTimeNow() < info.NextClaim then return end



        -- find the claim button for the current login type

        local head = RewFindUI('DailyLogin_' .. loginType .. '_Rewards')

        if not head then return end



        if loginType == 'D30' then

            local streak = tonumber(info.DaysClaimedStreak) or 0

            local day = head:FindFirstChild('Page')

            day = day and day:FindFirstChild('Rewards')

            day = day and day:FindFirstChild('Day' .. (streak + 1), true)

            if day then head = day end

        elseif loginType == 'Longterm' then

            local f = head:FindFirstChild('Frame')

            head = f and f:FindFirstChild('Claim')

        end



        local snap = info.NextClaim

        RewFire('Claim_Daily_Rewards', head, 'DailyLoginController', function()

            local d = Data:Get({'DailyLoginData', loginType, 'NextClaim'})

            return d ~= snap

        end)

    end, 5)



    -- ── 2. PLAYTIME REWARDS ─────────────────────────────────────────

    RewRegister('Claim_Playtime_Rewards', 'Auto Claim Playtime', function()

        local Data = GetRewData()

        if not Data then return end



        local ok, PlaytimeInfo = pcall(function()

            return require(RS_Rew.Common.PlaytimeRewardsInfo).Rewards

        end)

        if ok and PlaytimeInfo then

            local pData = Data:Get('PlaytimeRewardsData')

            if pData and pData.ClaimedRewards then

                for idx, reward in pairs(PlaytimeInfo) do

                    if not pData.ClaimedRewards[tostring(idx)] then

                        if workspace:GetServerTimeNow() >= (pData.TimerStart + reward.Duration) then

                            local btn = RewFindUI(

                                'PlaytimeRewards','PlaytimeRewards',

                                'Page','List','RewardsList',tostring(idx),'ClaimButton'

                            )

                            RewFire('Claim_Playtime_Rewards', btn, 'PlaytimeRewardsController', function()

                                return Data:Get({'PlaytimeRewardsData','ClaimedRewards',tostring(idx)}) == true

                            end)

                            break

                        end

                    end

                end

            end

        end

    end, 5)



    -- ── 3. DAILY QUESTS ─────────────────────────────────────────────

    RewRegister('Claim_Quest_Rewards', 'Auto Claim Quests', function()

        local Data = GetRewData()

        if not Data then return end



        local ok, QuestDefs = pcall(function()

            return require(RS_Rew.Shared.Quests)

        end)

        if not ok or not QuestDefs then return end



        for _, questId in pairs(Data:Get('CurrentQuests') or {}) do

            local q = QuestDefs[questId]

            if q and type(q.stat) == 'string' and type(q.goal) == 'number' then

                local progress = Data:Get({'QuestStats', q.stat}) or 0

                if progress >= q.goal then

                    if not table.find(Data:Get('QuestsAwarded') or {}, questId) then

                        local btn = RewFindUI('NewDailyQuests','Holder','Quests',questId,'Intermediate')

                        RewFire('Claim_Quest_Rewards', btn, 'QuestsController', function()

                            return table.find(Data:Get('QuestsAwarded') or {}, questId) ~= nil

                        end)

                    end

                end

            end

        end

    end, 5)



    -- ── LOOP ────────────────────────────────────────────────────────

    -- Sentinel pattern: Rew_Token is a unique table while running.

    -- Any code that captures the token can tell if the loop was restarted

    -- (token changed) and self-terminate without touching a shared flag.

    local function Reward_Toggle()

        -- check if any reward flag is on

        local anyOn = false

        for _, item in pairs(Rew_Items) do

            if Cfg['Reward_' .. item.ID] then anyOn = true; break end

        end

        -- also check quest flag

        if Cfg['Reward_Claim_Quest_Rewards'] then anyOn = true end



        if not anyOn then

            Rew_Token = nil   -- signal running loop to stop

            return

        end



        if Rew_Token then return end   -- already running



        local token = {}       -- unique sentinel

        Rew_Token = token



        task.spawn(function()

            while Rew_Token == token do

                -- expire pending claim checks

                for btn, entry in pairs(Rew_Lines) do

                    local ok, done = pcall(entry.Check)

                    if (ok and done) or not btn.Parent then

                        Rew_Lines[btn] = nil

                    end

                end

                -- run scheduled items

                local now = os.clock()

                for _, item in pairs(Rew_Items) do

                    if Cfg['Reward_' .. item.ID] and now >= item.Next then

                        item.Next = now + item.Interval

                        task.spawn(item.Run)   -- run in separate thread so one failure doesn't block others

                    end

                end

                task.wait(1)

            end

        end)

    end



    -- Expose for GUI callbacks + add quest flag to Cfg defaults

    Cfg.__RewardToggle = Reward_Toggle

    if Cfg.Reward_Claim_Quest_Rewards == nil then

        Cfg.Reward_Claim_Quest_Rewards = false

    end



    -- Export BallState for console debugging

    getgenv().MayOsBallState = BallState



    --=================================================================

    -- ANTI-LAG — mirrors Flyte's SetAntiLag implementation

    -- Drops QualityLevel to 1, kills GlobalShadows, Atmosphere,

    -- Clouds, Bloom, BlurEffect, DepthOfFieldEffect, SunRaysEffect.

    -- Full property restore on disable. No geometry removed.

    --=================================================================

    local AntiLag_Cache = {}     -- [obj] = { [prop] = originalValue }

    local AntiLag_Connections = {}

    local AntiLag_Active = false



    local function AL_Save(obj, prop, newVal)

        if not AntiLag_Cache[obj] then AntiLag_Cache[obj] = {} end

        if AntiLag_Cache[obj][prop] == nil then

            AntiLag_Cache[obj][prop] = obj[prop]

        end

        pcall(function() obj[prop] = newVal end)

    end



    local function AL_Restore()

        for _, conn in ipairs(AntiLag_Connections) do

            pcall(function() conn:Disconnect() end)

        end

        table.clear(AntiLag_Connections)

        for obj, props in pairs(AntiLag_Cache) do

            pcall(function()

                for prop, val in pairs(props) do

                    obj[prop] = val

                end

            end)

        end

        table.clear(AntiLag_Cache)

        AntiLag_Active = false

    end



    local AL_FX_CLASSES = {

        BloomEffect = true, BlurEffect = true,

        DepthOfFieldEffect = true, SunRaysEffect = true,

    }



    local function AL_HandleDescendant(inst)

        if not AntiLag_Active then return end

        local cn = inst.ClassName

        if cn == 'Atmosphere' then

            AL_Save(inst, 'Density', 0)

            AL_Save(inst, 'Haze', 0)

            AL_Save(inst, 'Glare', 0)

        elseif cn == 'Clouds' then

            AL_Save(inst, 'Enabled', false)

        elseif AL_FX_CLASSES[cn] then

            if not (AntiLag_Cache[inst] and AntiLag_Cache[inst].Enabled ~= nil) then

                AL_Save(inst, 'Enabled', false)

                -- re-lock in case game re-enables

                table.insert(AntiLag_Connections, inst:GetPropertyChangedSignal('Enabled'):Connect(function()

                    if AntiLag_Active and inst.Enabled then

                        pcall(function() inst.Enabled = false end)

                    end

                end))

            end

        end

    end



    local function AL_ScanContainer(container)

        if not container then return end

        for _, desc in ipairs(container:GetDescendants()) do

            AL_HandleDescendant(desc)

        end

        table.insert(AntiLag_Connections, container.DescendantAdded:Connect(AL_HandleDescendant))

    end



    local function AntiLag_Apply()

        if not AntiLag_Active then return end

        local Lighting  = game:GetService('Lighting')

        local Terrain   = workspace.Terrain

        local Rendering = settings().Rendering

        -- re-apply core properties every time (they may have been reset by a round)

        AL_Save(Rendering, 'QualityLevel', Enum.QualityLevel.Level01)

        AL_Save(Lighting,  'GlobalShadows', false)

        AL_Save(Lighting,  'EnvironmentDiffuseScale', 0)

        AL_Save(Lighting,  'EnvironmentSpecularScale', 0)

        AL_Save(Terrain,   'WaterWaveSize', 0)

        AL_Save(Terrain,   'WaterWaveSpeed', 0)

        AL_Save(Terrain,   'WaterReflectance', 0)

        AL_ScanContainer(Lighting)

        AL_ScanContainer(Terrain)

        AL_ScanContainer(workspace.CurrentCamera)

    end



    local function AntiLag_Enable()

        AL_Restore() -- clean slate

        AntiLag_Active = true



        AntiLag_Apply()



        -- re-scan whenever camera is replaced (round reset, teleport)

        table.insert(AntiLag_Connections, workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()

            if AntiLag_Active then

                AL_ScanContainer(workspace.CurrentCamera)

            end

        end))



        -- re-apply after player respawn — round reset recreates Lighting children

        table.insert(AntiLag_Connections, LP.CharacterAdded:Connect(function()

            if not AntiLag_Active then return end

            task.delay(0.3, function()

                if AntiLag_Active then

                    -- clear cached values so AL_Save re-reads the fresh ones

                    table.clear(AntiLag_Cache)

                    AntiLag_Apply()

                end

            end)

        end))



        -- re-apply every 8 seconds to catch mid-round resets (map events, etc.)

        task.spawn(function()

            while AntiLag_Active do

                task.wait(8)

                if AntiLag_Active then

                    AntiLag_Apply()

                end

            end

        end)



        Log('Success', 'Anti-lag', 'Activado: calidad nivel 1, sombras y post-FX desactivados.')

    end



    --=================================================================

    -- NO-RENDER — disable particles, decals, beams, trails, world GUIs

    -- outside player characters. Full restore on disable.

    --=================================================================

    local NoRender_Cache = {}   -- [inst] = { [prop] = originalValue }

    local NoRender_Conn  = nil

    local NoRender_Active = false



    local function NR_Save(inst, prop, newVal)

        if not NoRender_Cache[inst] then NoRender_Cache[inst] = {} end

        if NoRender_Cache[inst][prop] == nil then

            NoRender_Cache[inst][prop] = inst[prop]

        end

        pcall(function() inst[prop] = newVal end)

        if inst:IsA('ParticleEmitter') then pcall(function() inst:Clear() end) end

    end



    local function NR_Restore()

        if NoRender_Conn then pcall(function() NoRender_Conn:Disconnect() end); NoRender_Conn = nil end

        for inst, props in pairs(NoRender_Cache) do

            pcall(function()

                for prop, val in pairs(props) do inst[prop] = val end

            end)

        end

        table.clear(NoRender_Cache)

        NoRender_Active = false

    end



    local function NR_IsPlayerModel(inst)

        local par = inst.Parent

        while par and par ~= workspace do

            if par:IsA('Model') then

                local plr = game:GetService('Players'):GetPlayerFromCharacter(par)

                if plr then return true end

            end

            par = par.Parent

        end

        return false

    end



    local function NR_Process(inst)

        if not NoRender_Active then return end

        if NR_IsPlayerModel(inst) then return end

        if inst:IsA('ParticleEmitter') or inst:IsA('Beam') or inst:IsA('Trail') then

            NR_Save(inst, 'Enabled', false)

            NR_Save(inst, 'Transparency', NumberSequence.new(1))

        elseif inst:IsA('Decal') or inst:IsA('Texture') then

            NR_Save(inst, 'Transparency', 1)

        elseif (inst:IsA('SurfaceGui') or inst:IsA('BillboardGui')) and not NR_IsPlayerModel(inst) then

            NR_Save(inst, 'Enabled', false)

        end

    end



    local function NoRender_Enable()

        NR_Restore()

        NoRender_Active = true

        for _, desc in ipairs(workspace:GetDescendants()) do

            NR_Process(desc)

        end

        NoRender_Conn = workspace.DescendantAdded:Connect(NR_Process)

        Log('Success', 'Sin renderizado', 'Activado: partículas, calcomanías y GUIs del mundo suprimidos.')

    end



    --=================================================================

    -- ANTI-LAG / NO-RENDER pulse watcher (runs in Feature_Tick)

    --=================================================================

    local _antiLagPulse  = 0

    local _noRenderPulse = 0





    -- extend Feature_Tick by patching the heartbeat connection after the fact

    RunService.Heartbeat:Connect(function()

        xpcall(function()

            local alp = tonumber(Cfg.__AntiLagPulse) or 0

            if alp ~= _antiLagPulse then

                _antiLagPulse = alp

                if Cfg.AntiLag then

                    AntiLag_Enable()

                else

                    AL_Restore()

                    Log('Info', 'Anti-lag', 'Desactivado: renderizado restaurado.')

                end

            end

            local nrp = tonumber(Cfg.__NoRenderPulse) or 0

            if nrp ~= _noRenderPulse then

                _noRenderPulse = nrp

                if Cfg.NoRender then

                    NoRender_Enable()

                else

                    NR_Restore()

                    Log('Info', 'Sin renderizado', 'Desactivado: efectos restaurados.')

                end

            end

        end, function() end)

    end)





    pcall(function()

        if type(setfpscap) == 'function' then

            setfpscap(9999)

        end

    end)

    pcall(function()

        if type(setfflag) == 'function' then

            -- tighten interpolation budget → less wasted frame time

            setfflag('DFIntInterpolationDelayOverride',      '-1')

            -- disable the in-process micro-profiler thread cost

            setfflag('FFlagDebugDisableMicroProfiler',       'True')

            -- reduce redundant heartbeat callbacks at high frequency

            setfflag('DFIntTaskSchedulerTargetFps',          '9999')

            -- prevent quality auto-downgrade during framerate dips

            setfflag('FFlagGraphicsQualityAutoAdjust',       'False')

            -- keep the physics sender lean; immortal uses its own rate

            setfflag('DFIntS2PhysicsSenderRate',             '15')

        end

    end)



    return {

        Cfg = Cfg,

        Restart = StartParryLoop,

        Ping = GetPing,

        Staff = {

            Scan = Staff_Scan_Count,

            GetRank = Staff_Get_Rank,

            IsStaff = function(Player)

                return Player ~= nil and Staff_State.Detected[Player.UserId] ~= nil

            end,

            Detected = Staff_State.Detected,

        },

        Stop = function()

            if _parryConn then

                _parryConn:Disconnect()

                _parryConn = nil

            end

        end,

    }

end



end)()



--// [ BOOT ] ---------------------------------------------------------------

local App = Create_Menu({ Library = Library, Window = Window })

-- Carga la configuración autoguardada de Luna (si existe); los callbacks sincronizan Cfg.
pcall(function()
    Luna:LoadAutoloadConfig()
end)

local Engine = Create_AP({ Cfg = App.Cfg, Log = App.Log })



--// [ VERSION ] ------------------------------------------------------------

local function Set_Version(New_Version)

    New_Version = tostring(New_Version or CONFIG.Version)

    CONFIG.Version = New_Version

    ENV.Product_Version = New_Version



    local Gui = Window and Window.Gui

    local Label = Gui and Gui:FindFirstChild('Version', true)

    if Label and Label:IsA('TextLabel') then

        Label.Text = New_Version

    end

    if ENV.MayOs then

        ENV.MayOs.Version = New_Version

    end

    return New_Version

end



--// [ API ] ----------------------------------------------------------------

ENV.MayOs = {

    Version = CONFIG.Version,

    Set_Version = Set_Version,

    UI_URL = CONFIG.UI_URL,

    Library = Library,

    Window = Window,

    Notify = App.Log,

    Cfg = App.Cfg,

    Engine = Engine,

    Staff = Engine.Staff,

}

-- Compatibilidad con scripts que aún leen ENV.Ethereal
ENV.Ethereal = ENV.MayOs
