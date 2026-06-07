--[[---------------------------------------------------------------------------
    Override monnaie DarkRP : Dollar -> Euro, format FR ("1 500 €").
    Override GAMEMODE.Config sans toucher DarkRP-master/config.lua.
    Affecte tout ce qui passe par DarkRP.formatMoney (menu F4, messages...).
    Le HUD lui formate l'euro lui-meme (cf cl_fr_hud.lua) => garanti.
    Plusieurs filets car la config peut etre prete apres le chargement addon.
---------------------------------------------------------------------------]]

local function setEuro()
    if not GAMEMODE or not GAMEMODE.Config then return false end
    GAMEMODE.Config.currency                  = " €"   -- espace avant => "500 €"
    GAMEMODE.Config.currencyLeft              = false  -- symbole a droite (FR)
    GAMEMODE.Config.currencyThousandSeparator = " "    -- "1 500" a la francaise
    return true
end

hook.Add("DarkRPFinishedLoading", "FRHUD_Euro", setEuro)
hook.Add("InitPostEntity",        "FRHUD_Euro2", setEuro)

-- filet : reessaye chaque seconde jusqu'a ce que la config existe (max 15s)
local tries = 0
timer.Create("FRHUD_EuroRetry", 1, 15, function()
    tries = tries + 1
    if setEuro() or tries >= 15 then timer.Remove("FRHUD_EuroRetry") end
end)

setEuro()
