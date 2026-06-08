--[[---------------------------------------------------------------------------
    Tag de bienvenue join — Marseille RP
    "[Marseille] Bienvenue Nom !" diffuse a tous les joueurs (en bleu OM + or).
    Utilise DarkRP.talkToPerson : rendu natif EasyChat (couleurs + scroll).
---------------------------------------------------------------------------]]

-- desactive le message join/leave EasyChat (replicated -> set serveur)
local cv = GetConVar("easychat_joinleave_msg")
if cv then cv:SetInt(0) end
timer.Simple(2, function()
    local c = GetConVar("easychat_joinleave_msg")
    if c then c:SetInt(0) end
end)

hook.Add("PlayerInitialSpawn", "FRChat_Welcome", function(ply)
    timer.Simple(4, function()
        if not IsValid(ply) then return end
        if not (DarkRP and DarkRP.talkToPerson) then return end
        local OM    = Color(45, 170, 225)
        local WHITE = Color(238, 242, 248)
        for _, target in ipairs(player.GetAll()) do
            DarkRP.talkToPerson(
                target,
                OM,    "[Marseille] ",   -- espace avant le ":" force par DarkRP
                WHITE, "Bienvenue <flash>" .. ply:Nick() .. "<stop> !",
                nil
            )
        end
    end)
end)
