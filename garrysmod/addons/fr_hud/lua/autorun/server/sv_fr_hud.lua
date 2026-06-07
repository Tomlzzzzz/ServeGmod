--[[---------------------------------------------------------------------------
    Force le download des assets par les clients (vrai serveur).
    Sans ca : police de fallback + pas de logo chez les joueurs.
---------------------------------------------------------------------------]]
resource.AddSingleFile("resource/fonts/SedgwickAveDisplay-Regular.ttf")

-- Materials (logo + icones) : envoyes seulement s'ils existent
for _, f in ipairs({ "logo_marseille_final.png", "coeur.png", "armure.png", "faim.png" }) do
    if file.Exists("materials/fr_hud/" .. f, "GAME") then
        resource.AddSingleFile("materials/fr_hud/" .. f)
    end
end
