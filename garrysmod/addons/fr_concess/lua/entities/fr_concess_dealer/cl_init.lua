--[[---------------------------------------------------------------------------
    fr_concess_dealer — client (affichage hover "Appuie sur E")
---------------------------------------------------------------------------]]

include("shared.lua")

surface.CreateFont("FRConcess_Hint", { font = "Poppins", size = 22, weight = 600, antialias = true, extended = true })
surface.CreateFont("FRConcess_HintSmall", { font = "Poppins", size = 14, weight = 500, antialias = true, extended = true })

function ENT:Draw()
    self:DrawModel()
end

-- texte 3D2D au-dessus du NPC quand le joueur regarde l'entite a courte distance
function ENT:DrawTranslucent()
    self:DrawModel()
    local lp = LocalPlayer()
    if not IsValid(lp) then return end
    local dist = lp:GetPos():Distance(self:GetPos())
    if dist > 200 then return end

    -- check si le joueur regarde le NPC
    local trace = lp:GetEyeTrace()
    if trace.Entity ~= self then return end

    local pos = self:GetPos() + Vector(0, 0, 85)
    local ang = (lp:EyePos() - pos):Angle()
    ang:RotateAroundAxis(ang:Forward(),  90)
    ang:RotateAroundAxis(ang:Right(),    90)

    cam.Start3D2D(pos, Angle(0, ang.y - 90, 90), 0.1)
        draw.RoundedBox(8, -150, -40, 300, 70, Color(11, 23, 42, 230))
        draw.RoundedBox(0, -150, -40, 4, 70, Color(45, 170, 225))
        draw.SimpleText("CONCESSIONNAIRE", "FRConcess_Hint", 0, -22, Color(255, 198, 64), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Appuie sur E pour voir les véhicules", "FRConcess_HintSmall", 0, 8, Color(238, 242, 248), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
