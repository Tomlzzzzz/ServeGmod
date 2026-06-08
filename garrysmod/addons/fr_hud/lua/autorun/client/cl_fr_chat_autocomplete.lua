--[[---------------------------------------------------------------------------
    Autocomplete Tab — whitelist des commandes de communication FR.
    Vire les autres OnChatTab (FAdmin/DarkRP) puis installe le notre.
---------------------------------------------------------------------------]]

local COMM = {
    "annonce", "ano", "ooc", "me", "w", "y", "pm", "g",
    "broadcast", "channel", "radio", "credits",
}

local function suggest(text)
    text = text or ""
    if string.sub(text, 1, 1) ~= "/" then return end
    local q = string.lower(string.sub(text, 2))
    if q == "" then return "/" .. COMM[1] end
    for _, name in ipairs(COMM) do
        if string.StartWith(name, q) then return "/" .. name end
    end
    return text  -- bloque les autres suggestions
end

local function cleanAndInstall()
    local tbl = hook.GetTable().OnChatTab
    if tbl then
        for k in pairs(tbl) do
            if k ~= "FRChat_Whitelist" then hook.Remove("OnChatTab", k) end
        end
    end
    hook.Add("OnChatTab", "FRChat_Whitelist", suggest)
end

-- nettoie toutes les 2s : si DarkRP/FAdmin se reinstalle, on les vire encore
timer.Create("FRChat_AutocompleteClean", 2, 0, cleanAndInstall)
cleanAndInstall()

-- Override DarkRP.getSortedChatCommands pour filtrer la liste affichee dans
-- le panneau dropdown (la liste /000, /112, /addagenda... visible quand on
-- ouvre le chat). On ne garde QUE les commandes de la whitelist.
local function overrideSortedCommands()
    if not (DarkRP and DarkRP.getSortedChatCommands) then return false end
    if DarkRP.FR_oldGetSortedChatCommands then return true end
    DarkRP.FR_oldGetSortedChatCommands = DarkRP.getSortedChatCommands
    local whitelist = {}
    for _, n in ipairs(COMM) do whitelist[n] = true end
    function DarkRP.getSortedChatCommands()
        local out = {}
        local all = DarkRP.FR_oldGetSortedChatCommands()
        for _, cmd in ipairs(all) do
            if whitelist[cmd.command] then table.insert(out, cmd) end
        end
        return out
    end
    return true
end

hook.Add("DarkRPFinishedLoading", "FRChat_OverrideSorted", overrideSortedCommands)
timer.Simple(1, overrideSortedCommands)
timer.Simple(5, overrideSortedCommands)
overrideSortedCommands()
