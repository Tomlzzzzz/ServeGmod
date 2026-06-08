--[[---------------------------------------------------------------------------
    Commandes serveur /annonce et /ano — Marseille RP
    Diffuse via net : le client recoit et appelle chat.AddText
    (EasyChat capte et applique son rendu = avatars + scroll + couleurs).
    Cooldown anti-spam.
---------------------------------------------------------------------------]]

util.AddNetworkString("FRChat_Annonce")
util.AddNetworkString("FRChat_Anonyme")
util.AddNetworkString("FRChat_AnnonceBanner")

local COOLDOWN = 15

local function doAnnonce(ply, args)
    args = string.Trim(args or "")
    if args == "" then
        if DarkRP and DarkRP.notify then DarkRP.notify(ply, 1, 4, "Utilisation : /annonce <message>") end
        return ""
    end
    ply.FRNextAnnonce = ply.FRNextAnnonce or 0
    if CurTime() < ply.FRNextAnnonce then
        if DarkRP and DarkRP.notify then DarkRP.notify(ply, 1, 4, "Attends avant de refaire une annonce.") end
        return ""
    end
    ply.FRNextAnnonce = CurTime() + COOLDOWN

    net.Start("FRChat_Annonce")
        net.WriteEntity(ply)
        net.WriteString(args)
    net.Broadcast()
    -- bannière en haut de l'ecran
    net.Start("FRChat_AnnonceBanner")
        net.WriteString(ply:Nick())
        net.WriteString(args)
    net.Broadcast()
    return ""
end

local function doAno(ply, args)
    args = string.Trim(args or "")
    if args == "" then
        if DarkRP and DarkRP.notify then DarkRP.notify(ply, 1, 4, "Utilisation : /ano <message anonyme>") end
        return ""
    end
    ply.FRNextAno = ply.FRNextAno or 0
    if CurTime() < ply.FRNextAno then
        if DarkRP and DarkRP.notify then DarkRP.notify(ply, 1, 4, "Attends avant de renvoyer un message anonyme.") end
        return ""
    end
    ply.FRNextAno = CurTime() + COOLDOWN

    print(string.format("[ANONYME] %s (%s): %s", ply:Nick(), ply:SteamID(), args))
    net.Start("FRChat_Anonyme")
        net.WriteString(args)
    net.Broadcast()
    return ""
end

-- inscription DarkRP
local registered = false
local function register()
    if registered then return end
    if not (DarkRP and DarkRP.defineChatCommand) then return end
    DarkRP.defineChatCommand("annonce", doAnnonce)
    DarkRP.defineChatCommand("ano",     doAno)
    registered = true
end
hook.Add("DarkRPFinishedLoading", "FRChat_Commands",  register)
hook.Add("InitPostEntity",        "FRChat_Commands2", register)
local tries = 0
timer.Create("FRChat_RegRetry", 1, 20, function()
    tries = tries + 1
    register()
    if registered or tries >= 20 then timer.Remove("FRChat_RegRetry") end
end)
register()

-- Filet : EasyChat hook.Run("PlayerSay") contourne le detour DarkRP -> on capte ici
hook.Add("PlayerSay", "FRChat_InterceptCmd", function(ply, text)
    if not IsValid(ply) or type(text) ~= "string" then return end
    local cmd, rest = string.match(text, "^/(%S+)%s*(.*)$")
    if not cmd then return end
    cmd = string.lower(cmd)
    if cmd == "annonce" then return doAnnonce(ply, rest) end
    if cmd == "ano"     then return doAno(ply, rest)     end
end)
