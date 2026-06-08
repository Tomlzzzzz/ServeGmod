--[[---------------------------------------------------------------------------
    Client — tag de grade dans les 2 vues (ChatHUD + ChatBox).
    Capture OnPlayerChat :
      - say normal (EasyChat) : prefix vide -> on construit le tag depuis ULX
      - OOC/PM/me/radio/broadcast (DarkRP via talkToPerson) : prefix contient
        le markup <color=...>(Grade)<stop> injecté par le wrap serveur.
        On parse le markup et on reconstruit en couleurs natives.
---------------------------------------------------------------------------]]

local GROUPS = {
    ["superadmin"] = { "Fondateur",  Color(255, 80, 80)  },
    ["admin"]      = { "Admin",      Color(255, 140, 40) },
    ["operator"]   = { "Opérateur",  Color(80, 200, 120) },
    ["moderator"]  = { "Modérateur", Color(80, 200, 120) },
    ["vip"]        = { "VIP",         Color(255, 198, 64) },
}

local TEXT = Color(238, 242, 248)
local DEAD = Color(220, 70, 70)
local TEAM = Color(45, 170, 225)
local MENT = Color(255, 222, 70)   -- couleur du surlignage mention

-- Detecte le nom du LocalPlayer dans le texte (mot entier, insensible casse).
-- Split en parts {color?, string} pour chat.AddText. Retourne nil si pas trouve.
local function buildMentionParts(text)
    local lp = LocalPlayer()
    if not IsValid(lp) then return nil end
    local nick = lp:Nick()
    if not nick or #nick < 2 then return nil end       -- skip noms trop courts (faux positifs)
    local lowText = string.lower(text)
    local lowNick = string.lower(nick)
    -- match en tant que mot entier : pas un sous-string d'un autre mot
    local function findWord(start)
        local s = string.find(lowText, lowNick, start, true)
        while s do
            local before = string.sub(lowText, s - 1, s - 1)
            local after  = string.sub(lowText, s + #lowNick, s + #lowNick)
            -- bordure de mot : caractere non-alphanumerique (ou debut/fin)
            local okBefore = before == "" or not before:match("[%w]")
            local okAfter  = after  == "" or not after:match("[%w]")
            if okBefore and okAfter then return s end
            s = string.find(lowText, lowNick, s + 1, true)
        end
        return nil
    end
    local s = findWord(1)
    if not s then return nil end
    local out, pos = {}, 1
    while s do
        if s > pos then table.insert(out, string.sub(text, pos, s - 1)) end
        table.insert(out, MENT); table.insert(out, string.sub(text, s, s + #nick - 1))
        table.insert(out, TEXT)
        pos = s + #nick
        s = findWord(pos)
    end
    if pos <= #text then table.insert(out, string.sub(text, pos)) end
    surface.PlaySound("buttons/button17.wav")  -- ping
    return out
end

-- extrait <color=r,g,b>label<stop> rest -> color, label, rest
local function stripMarkup(s)
    if not isstring(s) then return nil, nil, "" end
    local r, g, b, label, rest = string.match(s, "^<color=(%d+),(%d+),(%d+)>(.-)<stop>%s*(.*)$")
    if r then return Color(tonumber(r), tonumber(g), tonumber(b)), label, rest end
    return nil, nil, s
end

-- Override le receiver net DarkRP_Chat pour parser le markup grade et appeler
-- chat.AddText avec couleurs natives (couvre /me, /w, /y qui passent par
-- talkToRange et ne declenchent PAS OnPlayerChat cote client).
-- On le fait en differe pour etre sur qu'il s'execute APRES DarkRP.
local function overrideDarkRPChat()
    net.Receive("DarkRP_Chat", function()
        local col1 = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))
        local prefixText = net.ReadString()
        local ply = net.ReadEntity()
        ply = IsValid(ply) and ply or LocalPlayer()
        if not IsValid(ply) then return end
        if prefixText == "" or not prefixText then
            prefixText = ply:Nick()
            if prefixText == "" then prefixText = ply:SteamName() end
        end
        local col2 = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))
        local text = net.ReadString()

        local tagCol, tagLabel, rest = stripMarkup(prefixText)
        local parts = {}
        if tagCol then
            table.insert(parts, tagCol); table.insert(parts, tagLabel .. " ")
            table.insert(parts, col1);   table.insert(parts, rest)
        else
            table.insert(parts, col1);   table.insert(parts, prefixText)
        end
        if text and text ~= "" then
            table.insert(parts, col2); table.insert(parts, ": ")
            local mentParts = buildMentionParts(text)
            if mentParts then
                for _, v in ipairs(mentParts) do table.insert(parts, v) end
            else
                table.insert(parts, text)
            end
        end
        chat.AddText(unpack(parts))
        chat.PlaySound()
    end)
end
hook.Add("InitPostEntity", "FRChat_DRPChatOverride", overrideDarkRPChat)
timer.Simple(1, overrideDarkRPChat)
overrideDarkRPChat()

hook.Add("OnPlayerChat", "FRChat_GradeClient", function(ply, text, teamChat, dead, prefixText, col1, col2)
    if not IsValid(ply) then return end

    -- Cas 1 : DarkRP talkToPerson (OOC, PM, /me, radio, broadcast)
    -- prefixText est une string (avec eventuellement notre markup grade)
    if isstring(prefixText) and prefixText ~= "" then
        local tagCol, tagLabel, rest = stripMarkup(prefixText)
        local parts = {}
        if tagCol and tagLabel and tagLabel ~= "" then
            table.insert(parts, tagCol);    table.insert(parts, tagLabel .. " ")
        end
        table.insert(parts, col1 or TEXT); table.insert(parts, rest)
        table.insert(parts, col2 or TEXT); table.insert(parts, ": ")
        local mentParts = buildMentionParts(tostring(text or ""))
        if mentParts then
            for _, v in ipairs(mentParts) do table.insert(parts, v) end
        else
            table.insert(parts, tostring(text or ""))
        end
        chat.AddText(unpack(parts))
        return true
    end

    -- Cas 2 : say normal (EasyChat) — pas de prefixText
    local g = ply:GetUserGroup()
    if not g or g == "user" or g == "" then return end
    local def = GROUPS[g]
    local label = def and def[1] or string.upper(g)
    local color = def and def[2] or TEAM
    local nameCol = team.GetColor(ply:Team()) or TEXT

    local parts = {}
    if dead     then table.insert(parts, DEAD); table.insert(parts, "*MORT* ") end
    if teamChat then table.insert(parts, TEAM); table.insert(parts, "(ÉQUIPE) ") end
    table.insert(parts, color);   table.insert(parts, "(" .. label .. ") ")
    table.insert(parts, nameCol); table.insert(parts, ply:Nick())
    table.insert(parts, TEXT);    table.insert(parts, ": ")
    local mentParts = buildMentionParts(text)
    if mentParts then
        for _, v in ipairs(mentParts) do table.insert(parts, v) end
    else
        table.insert(parts, text)
    end

    chat.AddText(unpack(parts))
    return true
end)
