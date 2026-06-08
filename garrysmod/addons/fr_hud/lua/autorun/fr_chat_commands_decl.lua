--[[---------------------------------------------------------------------------
    Declaration shared des commandes custom — pour qu'EasyChat les liste
    dans le panneau dropdown cote client (sinon /annonce et /ano absentes).
---------------------------------------------------------------------------]]

local function declare()
    if not (DarkRP and DarkRP.declareChatCommand) then return false end
    DarkRP.declareChatCommand{
        command     = "annonce",
        description = "Faire une annonce au serveur",
        delay       = 15,
    }
    DarkRP.declareChatCommand{
        command     = "ano",
        description = "Envoyer un message anonyme",
        delay       = 15,
    }
    return true
end

hook.Add("DarkRPFinishedLoading", "FRChat_DeclCommands",  declare)
hook.Add("InitPostEntity",        "FRChat_DeclCommands2", declare)
local tries = 0
timer.Create("FRChat_DeclRetry", 1, 20, function()
    tries = tries + 1
    if declare() or tries >= 20 then timer.Remove("FRChat_DeclRetry") end
end)
declare()
