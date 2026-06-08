--[[---------------------------------------------------------------------------
    Theme EasyChat — Marseille RP
    Force les couleurs OM/or sur le chatbox EasyChat de chaque client.
    S'execute apres le chargement d'EasyChat.
---------------------------------------------------------------------------]]

local function apply()
    -- force le strip des tags markup dans le ChatBox
    local cv = GetConVar("easychat_tags_in_chatbox")
    if cv then cv:SetInt(0) end
    -- desactive les messages join/leave EasyChat (on a notre propre "Bienvenue")
    local cvJL = GetConVar("easychat_joinleave_msg")
    if cvJL then cvJL:SetInt(0) end
    -- desactive le rechargement de l'historique au boot (evite le spam Photon des sessions precedentes)
    local cvH = GetConVar("easychat_history")
    if cvH then cvH:SetInt(0) end
    -- clean l'historique sauvegarde existant
    if file.Exists("easychat/history/global.txt", "DATA") then
        file.Delete("easychat/history/global.txt")
    end

    if not EasyChat then return false end

    -- police Poppins (deja bundlee pour le HUD)
    RunConsoleCommand("easychat_font", "Poppins")
    RunConsoleCommand("easychat_font_size", "17")

    EasyChat.FontName = "Poppins"
    EasyChat.FontSize = 17
    -- force re-creation du font et application
    surface.CreateFont("EasyChatFont", {
        font = "Poppins", extended = true, size = 17, weight = 500, antialias = true,
    })
    if EasyChat.GUI and IsValid(EasyChat.GUI.RichText) then
        EasyChat.GUI.RichText:SetFontInternal("EasyChatFont")
    end
    if EasyChat.GUI and IsValid(EasyChat.GUI.TextEntry) then
        EasyChat.GUI.TextEntry:SetFont("EasyChatFont")
    end

    -- couleurs Marseille (raccord HUD)
    EasyChat.OutlayColor        = Color(11, 23, 42, 240)   -- fond chatbox (bleu nuit)
    EasyChat.OutlayOutlineColor = Color(255, 198, 64, 220) -- liseré or
    EasyChat.TabColor           = Color(11, 23, 42, 230)
    EasyChat.TabOutlineColor    = Color(45, 170, 225, 255) -- bleu OM
    EasyChat.TextColor          = Color(238, 242, 248, 255)

    -- persistance : sauve aussi dans data/easychat/colors.txt
    -- (utilise par EasyChat au prochain demarrage)
    if file.CreateDir then file.CreateDir("easychat") end
    local payload = util.TableToJSON({
        outlay        = { r = 11,  g = 23,  b = 42,  a = 240 },
        outlayoutline = { r = 255, g = 198, b = 64,  a = 220 },
        tab           = { r = 11,  g = 23,  b = 42,  a = 230 },
        taboutline    = { r = 45,  g = 170, b = 225, a = 255 },
    })
    file.Write("easychat/colors.txt", payload)

    return true
end

-- filets : EasyChat peut etre charge avant ou apres cet addon
hook.Add("ECInitialized", "FRTheme_EasyChat", apply)
hook.Add("InitPostEntity", "FRTheme_EasyChat_IPE", function()
    timer.Simple(1, apply)
end)
apply()
