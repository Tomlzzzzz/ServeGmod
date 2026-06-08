--[[---------------------------------------------------------------------------
    Serveur — chat hub Marseille RP (EasyChat + DarkRP)
    1. Wrap DarkRP.talkToPerson : injecte le tag de grade ULX en markup
       <color=...> dans le prefix. S'applique à OOC, PM, /me, radio, broadcast.
    2. Hook PlayerSay : tag de grade pour le say normal.
---------------------------------------------------------------------------]]

local GROUPS = {
    ["superadmin"] = { "Fondateur",  "255,80,80"  },
    ["admin"]      = { "Admin",      "255,140,40" },
    ["operator"]   = { "Opérateur",  "80,200,120" },
    ["moderator"]  = { "Modérateur", "80,200,120" },
    ["vip"]        = { "VIP",         "255,198,64" },
}

local function gradeTag(ply)
    if not IsValid(ply) or not ply.IsPlayer or not ply:IsPlayer() then return nil end
    local g = ply:GetUserGroup()
    if not g or g == "user" or g == "" then return nil end
    local def = GROUPS[g]
    local label = def and def[1] or string.upper(g)
    local color = def and def[2] or "45,170,225"
    return string.format("<color=%s>(%s)<stop> ", color, label)
end

-- 1) Wrap talkToPerson (OOC, PM, broadcast, radio) + talkToRange (/me, /w, /y)
-- (le grade pour say normal est gere cote client dans cl_fr_grades.lua)
local function wrapDarkRP()
    if not (DarkRP and DarkRP.talkToPerson and DarkRP.talkToRange) then return false end
    if DarkRP.FR_oldTalkToPerson then return true end  -- deja wrap

    DarkRP.FR_oldTalkToPerson = DarkRP.talkToPerson
    function DarkRP.talkToPerson(receiver, col1, text1, col2, text2, sender)
        local tag = gradeTag(sender)
        if tag and isstring(text1) and text1 ~= "" then text1 = tag .. text1 end
        return DarkRP.FR_oldTalkToPerson(receiver, col1, text1, col2, text2, sender)
    end

    -- talkToRange : /me, /w (whisper), /y (yell) — sender = ply (1er arg)
    DarkRP.FR_oldTalkToRange = DarkRP.talkToRange
    function DarkRP.talkToRange(ply, PlayerName, Message, size)
        local tag = gradeTag(ply)
        if tag and isstring(PlayerName) and PlayerName ~= "" then
            PlayerName = tag .. PlayerName
        end
        return DarkRP.FR_oldTalkToRange(ply, PlayerName, Message, size)
    end

    return true
end

hook.Add("DarkRPFinishedLoading", "FRChat_Wrap",  wrapDarkRP)
hook.Add("InitPostEntity",        "FRChat_Wrap2", wrapDarkRP)
local tries = 0
timer.Create("FRChat_WrapRetry", 1, 20, function()
    tries = tries + 1
    if wrapDarkRP() or tries >= 20 then timer.Remove("FRChat_WrapRetry") end
end)
wrapDarkRP()
