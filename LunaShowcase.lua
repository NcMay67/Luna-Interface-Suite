-- NC HUB | Luna Complete Showcase
-- PARTE 1/3: Arranque, HomeTab y elementos básicos.
-- Source attribution and BSD-3-Clause license remain in source.lua and LICENSE.

local Luna = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/NcMay67/Luna-Interface-Suite/refs/heads/master/source.lua"
))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Window = Luna:CreateWindow({
    Name = "NC HUB Showcase",
    Subtitle = "By hidjcjgg",
    LoadingEnabled = true,
    LoadingTitle = "NC HUB",
    LoadingSubtitle = "Mostrando las funciones de Luna",
    KeySystem = false
})

local Tabs = {
    Elementos = Window:CreateTab({
        Name = "Elementos",
        Icon = "widgets",
        ImageSource = "Material",
        ShowTitle = true
    }),
    Controles = Window:CreateTab({
        Name = "Controles",
        Icon = "tune",
        ImageSource = "Material",
        ShowTitle = true
    }),
    Avanzado = Window:CreateTab({
        Name = "Avanzado",
        Icon = "auto_awesome",
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

-- Dashboard especial que trae Luna: perfil, Server, Executor y Friends.
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

-- =========================================================
-- PESTAÑA: ELEMENTOS BÁSICOS
-- =========================================================
Tabs.Elementos:CreateSection("ELEMENTOS DE PESTAÑA")

Tabs.Elementos:CreateLabel({
    Text = "NC HUB Showcase",
    Style = 1
})

Tabs.Elementos:CreateLabel({
    Text = "Este texto usa el estilo de información de Luna.",
    Style = 2
})

Tabs.Elementos:CreateLabel({
    Text = "Este texto usa el estilo de aviso.",
    Style = 3
})

Tabs.Elementos:CreateParagraph({
    Title = "Párrafo",
    Text = "Un Paragraph permite títulos y explicaciones largas sin que el texto se salga de la tarjeta. Esta pestaña muestra primero los elementos visuales antes de pasar a los controles."
})

Tabs.Elementos:CreateDivider()

Tabs.Elementos:CreateButton({
    Name = "Notificación normal",
    Description = "Prueba Luna:Notification",
    Callback = function()
        notify("Notificación", "Esto salió desde un Button de NC HUB Showcase.", "notifications")
    end
})

Tabs.Elementos:CreateButton({
    Name = "Ir a Avanzado",
    Description = "Prueba Tab:Activate()",
    Callback = function()
        Tabs.Avanzado:Activate()
    end
})

-- Una sección devuelve un objeto con sus propios elementos.
local DemoSection = Tabs.Elementos:CreateSection("SECCIÓN ANIDADA")

DemoSection:CreateLabel({
    Text = "Esta etiqueta fue creada desde Section:CreateLabel().",
    Style = 2
})

DemoSection:CreateParagraph({
    Title = "Section",
    Text = "Las secciones agrupan controles dentro de una pestaña para mantener el Hub ordenado."
})

DemoSection:CreateDivider()

DemoSection:CreateButton({
    Name = "Renombrar sección",
    Description = "Prueba Section:Set",
    Callback = function()
        DemoSection:Set("SECCIÓN ACTUALIZADA")
        notify("Section:Set", "La sección se renombró correctamente.", "edit")
    end
})

-- =========================================================
-- PESTAÑA: CONTROLES
-- La parte 2 se pega debajo de esta línea.
-- =========================================================
Tabs.Controles:CreateSection("SLIDERS Y TOGGLES")

local DemoSpeed = 16
local DemoToggle = false

Tabs.Controles:CreateSlider({
    Name = "Velocidad de prueba",
    Description = "Slider con rango e incrementos",
    Range = {16, 100},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        DemoSpeed = Value
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid.WalkSpeed = DemoSpeed
        end
    end
}, "ShowcaseSpeed")

Tabs.Controles:CreateToggle({
    Name = "Toggle de prueba",
    Description = "Toggle normal con callback",
    CurrentValue = false,
    Callback = function(State)
        DemoToggle = State
        notify("Toggle", State and "Activado" or "Desactivado", "toggle_on")
    end
}, "ShowcaseToggle")

Tabs.Controles:CreateToggle({
    Name = "Toggle activado por defecto",
    Description = "Ejemplo de CurrentValue = true",
    CurrentValue = true,
    Callback = function(State)
        if not State then
            notify("Segundo toggle", "Ahora está apagado.", "toggle_off")
        end
    end
}, "ShowcaseDefaultToggle")

Tabs.Controles:CreateDivider()
Tabs.Controles:CreateSection("BINDS")

Tabs.Controles:CreateBind({
    Name = "Bind moderno",
    Description = "Toca el recuadro para cambiar Q por otra tecla",
    CurrentBind = "Q",
    HoldToInteract = false,
    Callback = function(State)
        notify("Bind moderno", State and "Modo activo" or "Modo inactivo", "keyboard")
    end,
    OnChangedCallback = function(NewKey)
        notify("Bind cambiado", "Nueva tecla: " .. tostring(NewKey), "edit")
    end
}, "ShowcaseBind")

Tabs.Controles:CreateKeybind({
    Name = "Bind legado",
    Description = "CreateKeybind antiguo, incluido para comparar",
    CurrentBind = "E",
    HoldToInteract = true,
    Callback = function(Held)
        if Held then
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.WalkSpeed = 70
            end
        else
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.WalkSpeed = DemoSpeed
            end
        end
    end
})

Tabs.Controles:CreateDivider()
Tabs.Controles:CreateSection("INPUTS")

Tabs.Controles:CreateInput({
    Name = "Texto dinámico",
    Description = "El callback cambia con cada letra",
    PlaceholderText = "Escribe un nombre",
    CurrentValue = "",
    Numeric = false,
    Enter = false,
    MaxCharacters = 24,
    Callback = function(Text)
        getgenv().NC_Showcase_Text = Text
    end
}, "ShowcaseText")

Tabs.Controles:CreateInput({
    Name = "Solo números",
    Description = "Numeric y máximo de 4 caracteres",
    PlaceholderText = "1234",
    CurrentValue = "",
    Numeric = true,
    Enter = false,
    MaxCharacters = 4,
    Callback = function(Text)
        getgenv().NC_Showcase_Number = tonumber(Text) or 0
    end
}, "ShowcaseNumber")

Tabs.Controles:CreateInput({
    Name = "Requiere Enter",
    Description = "Solo ejecuta callback tras confirmar con Enter",
    PlaceholderText = "Texto confirmado",
    CurrentValue = "",
    Numeric = false,
    Enter = true,
    MaxCharacters = 32,
    Callback = function(Text)
        notify("Input confirmado", "Escribiste: " .. tostring(Text), "check_circle")
    end
}, "ShowcaseEnterInput")

Tabs.Controles:CreateDivider()
Tabs.Controles:CreateSection("DROPDOWNS")

Tabs.Controles:CreateDropdown({
    Name = "Dropdown normal",
    Description = "Una opción a la vez",
    Options = {"Void", "Midnight", "Default", "Luna"},
    CurrentOption = "Void",
    MultipleOptions = false,
    Callback = function(Option)
        getgenv().NC_Showcase_ThemeChoice = Option
    end
}, "ShowcaseDropdown")

Tabs.Controles:CreateDropdown({
    Name = "Dropdown múltiple",
    Description = "Selecciona varias opciones",
    Options = {"ESP", "Fly", "Noclip", "Anti-AFK", "Salto infinito"},
    CurrentOption = {"ESP", "Anti-AFK"},
    MultipleOptions = true,
    Callback = function(Options)
        getgenv().NC_Showcase_MultiChoice = Options
    end
}, "ShowcaseMultiDropdown")

Tabs.Controles:CreateDropdown({
    Name = "Dropdown de jugadores",
    Description = "SpecialType Player se actualiza con el servidor",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    SpecialType = "Player",
    Callback = function(PlayerName)
        getgenv().NC_Showcase_Target = PlayerName
    end
}, "ShowcasePlayerDropdown")

Tabs.Controles:CreateDivider()
Tabs.Controles:CreateSection("COLOR PICKER")

Tabs.Controles:CreateColorPicker({
    Name = "Color de prueba",
    Description = "ColorPicker completo de Luna",
    Color = Color3.fromRGB(174, 113, 255),
    Callback = function(Color)
        getgenv().NC_Showcase_Color = Color

        local Character = LocalPlayer.Character
        if Character then
            local Highlight = Character:FindFirstChild("NC_ShowcaseHighlight")
            if not Highlight then
                Highlight = Instance.new("Highlight")
                Highlight.Name = "NC_ShowcaseHighlight"
                Highlight.FillTransparency = 0.7
                Highlight.OutlineTransparency = 0
                Highlight.Parent = Character
            end
            Highlight.FillColor = Color
            Highlight.OutlineColor = Color
        end
    end
}, "ShowcaseColor")

-- =========================================================
-- PESTAÑA: AVANZADO
-- La parte 3 se pega debajo de esta línea.
-- =========================================================
Tabs.Avanzado:CreateSection("ELEMENTOS DINÁMICOS")

local StatusLabel = Tabs.Avanzado:CreateLabel({
    Text = "Estado dinámico: esperando una acción",
    Style = 2
})

local DynamicSection = Tabs.Avanzado:CreateSection("SECCIÓN DINÁMICA")
DynamicSection:CreateLabel({
    Text = "Esta sección puede cambiar de nombre o destruirse.",
    Style = 1
})
DynamicSection:CreateDivider()
DynamicSection:CreateParagraph({
    Title = "Métodos dinámicos",
    Text = "Luna devuelve objetos para que puedas usar :Set() y :Destroy() después de crearlos."
})

Tabs.Avanzado:CreateButton({
    Name = "Actualizar label",
    Description = "Prueba Label:Set",
    Callback = function()
        StatusLabel:Set({
            Text = "Estado dinámico: actualizado a las " .. os.date("%H:%M:%S")
        })
    end
})

Tabs.Avanzado:CreateButton({
    Name = "Actualizar slider",
    Description = "Prueba Luna.Options[Flag]:Set",
    Callback = function()
        local Slider = Luna.Options.ShowcaseSpeed
        if Slider then
            Slider:Set({
                Name = "Velocidad actualizada",
                CurrentValue = 55
            })
            notify("Slider:Set", "El slider ahora tiene valor 55.", "speed")
        end
    end
})

Tabs.Avanzado:CreateButton({
    Name = "Renombrar sección dinámica",
    Description = "Prueba Section:Set",
    Callback = function()
        DynamicSection:Set("SECCIÓN RENOMBRADA")
        notify("Section:Set", "La sección dinámica cambió de nombre.", "edit")
    end
})

Tabs.Avanzado:CreateButton({
    Name = "Destruir sección dinámica",
    Description = "Prueba Section:Destroy una sola vez",
    Callback = function()
        if DynamicSection then
            DynamicSection:Destroy()
            DynamicSection = nil
            StatusLabel:Set({
                Text = "Estado dinámico: sección destruida"
            })
        end
    end
})

Tabs.Avanzado:CreateDivider()
Tabs.Avanzado:CreateSection("CONFIGURACIÓN DIRECTA")

Tabs.Avanzado:CreateButton({
    Name = "Guardar Showcase manual",
    Description = "Prueba Luna:SaveConfig",
    Callback = function()
        local Success, Reason = Luna:SaveConfig("showcase_manual")
        if Success then
            notify("Config", "Guardado como showcase_manual.", "save")
        else
            notify("Config", "No se pudo guardar: " .. tostring(Reason), "error")
        end
    end
})

Tabs.Avanzado:CreateButton({
    Name = "Cargar Showcase manual",
    Description = "Prueba Luna:LoadConfig",
    Callback = function()
        local Success, Reason = Luna:LoadConfig("showcase_manual")
        if Success then
            notify("Config", "showcase_manual cargado.", "folder_open")
        else
            notify("Config", "No se pudo cargar: " .. tostring(Reason), "error")
        end
    end
})

Tabs.Avanzado:CreateButton({
    Name = "Ver cantidad de configs",
    Description = "Prueba Luna:RefreshConfigList",
    Callback = function()
        local List = Luna:RefreshConfigList()
        notify("Configs", "Encontré " .. tostring(#List) .. " configuración(es).", "list")
    end
})

Tabs.Avanzado:CreateButton({
    Name = "Cargar autoload",
    Description = "Prueba Luna:LoadAutoloadConfig",
    Callback = function()
        Luna:LoadAutoloadConfig()
    end
})

-- =========================================================
-- PESTAÑA: SISTEMA
-- =========================================================
Tabs.Sistema:CreateSection("CONFIGS Y TEMA")
Tabs.Sistema:BuildConfigSection()
Tabs.Sistema:BuildThemeSection()

Tabs.Sistema:CreateSection("UTILIDADES")

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

Tabs.Sistema:CreateButton({
    Name = "Cerrar Showcase",
    Description = "Prueba Luna:Destroy",
    Callback = function()
        Luna:Destroy()
    end
})

notify("NC HUB Showcase", "Todas las pestañas y funciones ya están cargadas.", "auto_awesome")
