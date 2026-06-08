--[[---------------------------------------------------------------------------
    Filtre messages chat indesirables (spam d'addons : Photon, etc.)
    Retourne true sur les hooks pour supprimer l'affichage.
---------------------------------------------------------------------------]]

local BLACKLIST = {
    "photon lighting engine",
    "last session history",
    "!photon",
    "press c and click photon",
}

local function isSpam(text)
    if not isstring(text) then return false end
    local low = string.lower(text)
    for _, pat in ipairs(BLACKLIST) do
        if string.find(low, pat, 1, true) then return true end
    end
    return false
end

hook.Add("ChatText", "FRChat_FilterSpam", function(index, name, text, mtype)
    if isSpam(text) then return true end
end)

hook.Add("OnPlayerChat", "FRChat_FilterSpam", function(ply, text)
    if isSpam(text) then return true end
end)

-- intercepte aussi chat.AddText pour les addons qui passent par la
local _oldAddText = chat.AddText
chat.AddText = function(...)
    for _, a in ipairs({ ... }) do
        if isSpam(a) then return end
    end
    return _oldAddText(...)
end
