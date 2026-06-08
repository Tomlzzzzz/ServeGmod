-- Ce script corrige dfinitivement l'erreur "bad argument #1 to 'pairs' (table expected, got nil)"
-- qui est trs frquente avec l'addon Photon 1 et d'autres addons mal cods.

-- On redfinit lgrement la fonction 'pairs' de faon scurise
local old_pairs = pairs
_G.pairs = function(t)
    if t == nil then
        -- Au lieu de faire planter le jeu avec une erreur rouge, on retourne un itrateur vide (qui ne fait rien).
        return function() return nil end, nil, nil
    end
    -- Fonctionnement normal pour tout le reste
    return old_pairs(t)
end

print("[Photon/Global Fix] La fonction pairs() a t scurise pour empcher les crashs de tables vides !")
