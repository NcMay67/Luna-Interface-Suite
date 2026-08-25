-- ==========================================
-- NC HUB | OFFICIAL LOADER
-- ==========================================

local PlaceId = game.PlaceId
local BaseURL = "https://raw.githubusercontent.com/NcMay67/Luna-Interface-Suite/master/"

-- Diccionario de juegos (ID = nombre del archivo en este repositorio).
-- Por ahora, Factory Tycoon es el único módulo específico activo.
local Games = {
    [15197136141] = "FactoryTycoon.lua",
    [96033388567901] = "LootEvo.lua"
}


-- Carga FactoryTycoon.lua en ese juego y Universal.lua en cualquier otro.
local scriptToLoad = Games[PlaceId] or "Universal.lua"

print("------------------------------------------")
print("[NC HUB] Cargando sistema modular...")
print("[NC HUB] Juego detectado (ID): " .. PlaceId)
print("[NC HUB] Archivo a cargar: " .. scriptToLoad)
print("------------------------------------------")

local success, err = pcall(function()
    loadstring(game:HttpGet(BaseURL .. scriptToLoad))()
end)

if not success then
    warn("[NC HUB] Error crítico al cargar: " .. tostring(err))

    -- Respaldo: intenta el universal solo si falló Factory Tycoon.
    if scriptToLoad ~= "Universal.lua" then
        pcall(function()
            loadstring(game:HttpGet(BaseURL .. "Universal.lua"))()
        end)
    end
end
