--[[---------------------------------------------------------------------------
    HUD FR custom â€” Marseille RP
    Header : nom RP (gauche) + job (droite). Corps : ARGENT / SALAIRE.
    Jauges circulaires VIE (coeur) & ARMURE (bouclier), epaisses & lissees.
    Logo sur le coin (deborde, penchÃ©). Cadre OM + or. Typo Poppins. Euro.
    N'ecrase PAS DarkRP-master. Addon isole.
---------------------------------------------------------------------------]]

local draw      = draw
local surface   = surface
local math      = math
local Color     = Color
local Lerp      = Lerp
local cos, sin  = math.cos, math.sin
local TAU       = math.pi * 2

--[[-------------------------------------------------------------------------]]
-- 1) Tuer le HUD DarkRP par defaut (bloc bas-gauche)
--[[-------------------------------------------------------------------------]]
hook.Add("HUDShouldDraw", "FRHUD_HideDefault", function(name)
    if name == "DarkRP_LocalPlayerHUD" then return false end
    if name == "CHudAmmo" or name == "CHudSecondaryAmmo" then return false end
end)

--[[-------------------------------------------------------------------------]]
-- 2) Polices
--[[-------------------------------------------------------------------------]]
local FONT_CUSTOM = "Sedgwick Ave Display"
local FONT_NUMBERS  = "Roboto"
local function CreateFonts()
    local s = math.max(1, ScrH() / 1080)
    -- Mots / Titres (Pseudo, Job, "ARGENT", "SALAIRE")
    surface.CreateFont("FRHUD_Name",  { font = FONT_CUSTOM, size = math.floor(70*s), weight = 500, antialias = true, extended = true })
    surface.CreateFont("FRHUD_Job",   { font = FONT_CUSTOM, size = math.floor(70*s), weight = 500, antialias = true, extended = true })
    surface.CreateFont("FRHUD_Label", { font = FONT_CUSTOM, size = math.floor(70*s), weight = 500, antialias = true, extended = true })
    
    -- Nombres (Montant Argent, Montant Salaire, Jauges)
    surface.CreateFont("FRHUD_Money", { font = FONT_NUMBERS, size = math.floor(20*s), weight = 800, antialias = true, extended = true })
    surface.CreateFont("FRHUD_Sal",   { font = FONT_NUMBERS, size = math.floor(20*s), weight = 800, antialias = true, extended = true })
    surface.CreateFont("FRHUD_Ring",  { font = FONT_NUMBERS, size = math.floor(30*s), weight = 800, antialias = true, extended = true })
    surface.CreateFont("FRHUD_Ammo",  { font = FONT_NUMBERS, size = math.floor(36*s), weight = 800, antialias = true, extended = true })
    surface.CreateFont("FRHUD_AmmoS", { font = FONT_NUMBERS, size = math.floor(18*s), weight = 800, antialias = true, extended = true })
end
CreateFonts()
hook.Add("OnScreenSizeChanged", "FRHUD_Refont", CreateFonts)

--[[-------------------------------------------------------------------------]]
-- Logo serveur
--[[-------------------------------------------------------------------------]]
local logo = Material("fr_hud/logo_marseille_final.png", "smooth mips")
local hasLogo = logo and not logo:IsError()

-- icones custom (coeur / gilet) â€” vectoriel en secours si absentes
local matHeart  = Material("fr_hud/coeur.png", "smooth mips")
local matShield = Material("fr_hud/armure.png", "smooth mips")
local matFaim   = Material("fr_hud/faim.png", "smooth mips")
local hasHeart  = matHeart  and not matHeart:IsError()
local hasShield = matShield and not matShield:IsError()
local hasFaim   = matFaim   and not matFaim:IsError()

--[[-------------------------------------------------------------------------]]
-- Palette OM
--[[-------------------------------------------------------------------------]]
local col = {
    bg      = Color(11, 23, 42, 240),
    om      = Color(45, 170, 225),
    white   = Color(238, 242, 248),
    gold    = Color(255, 198, 64),
    hp      = Color(228, 64, 64),
    hpBack  = Color(52, 24, 32, 255),
    armor   = Color(45, 170, 225),
    armBack = Color(20, 38, 58, 255),
    faim    = Color(235, 150, 45),
    faimBack= Color(48, 34, 16, 255),
    dim     = Color(155, 180, 205),
    shadow  = Color(0, 0, 8, 200),
    divider = Color(255, 198, 64, 90),
    outline = Color(6, 14, 26, 255),
}

--[[-------------------------------------------------------------------------]]
-- Helpers texte
--[[-------------------------------------------------------------------------]]
local function txt(text, font, x, y, color, ax, ay)
    draw.SimpleText(text, font, x + 1, y + 1, col.shadow, ax, ay)
    draw.SimpleText(text, font, x, y, color, ax, ay)
end

local function comma(n)
    local str = tostring(math.floor(math.abs(n)))
    local out = str:reverse():gsub("(%d%d%d)", "%1 "):reverse()
    return (out:gsub("^%s+", ""))
end

-- euro formate maison (garanti, independant de la config DarkRP)
local function money(v)
    v = tonumber(v) or 0
    return (v < 0 and "-" or "") .. comma(v) .. " €"
end

--[[-------------------------------------------------------------------------]]
-- Primitives vectorielles (winding horaire, y vers le bas)
--[[-------------------------------------------------------------------------]]
local function setColor(c) surface.SetDrawColor(c.r, c.g, c.b, c.a or 255) end

local function disc(cx, cy, r, c, seg)
    seg = seg or 28
    local pts = {}
    for i = 0, seg do
        local a = (i / seg) * TAU
        pts[#pts + 1] = { x = cx + cos(a) * r, y = cy + sin(a) * r }
    end
    draw.NoTexture(); setColor(c); surface.DrawPoly(pts)
end

-- anneau epais & lisse (arc de aStart a aEnd)
local function ringArc(cx, cy, rIn, rOut, aStart, aEnd, c)
    local total = aEnd - aStart
    if total == 0 then return end
    local steps = math.max(3, math.ceil(150 * math.abs(total) / TAU))
    local da = total / steps
    draw.NoTexture(); setColor(c)
    for i = 0, steps - 1 do
        local a1, a2 = aStart + da*i, aStart + da*(i+1)
        local c1, s1 = cos(a1), sin(a1)
        local c2, s2 = cos(a2), sin(a2)
        surface.DrawPoly({
            { x = cx + rIn*c1,  y = cy + rIn*s1  },
            { x = cx + rOut*c1, y = cy + rOut*s1 },
            { x = cx + rOut*c2, y = cy + rOut*s2 },
            { x = cx + rIn*c2,  y = cy + rIn*s2  },
        })
    end
end

-- coeur (2 disques + triangle)
local function heart(cx, cy, sz, c)
    local r = sz * 0.31
    disc(cx - r*0.92, cy - r*0.5, r, c, 20)
    disc(cx + r*0.92, cy - r*0.5, r, c, 20)
    draw.NoTexture(); setColor(c)
    surface.DrawPoly({
        { x = cx - r*1.82, y = cy - r*0.18 },
        { x = cx + r*1.82, y = cy - r*0.18 },
        { x = cx,          y = cy + sz*0.6 },
    })
end

-- bouclier (silhouette convexe, taper doux)
local function shield(cx, cy, w, h, c)
    local hw, hh = w/2, h/2
    draw.NoTexture(); setColor(c)
    surface.DrawPoly({
        { x = cx - hw,      y = cy - hh        },
        { x = cx + hw,      y = cy - hh        },
        { x = cx + hw,      y = cy - hh*0.15   },
        { x = cx + hw*0.66, y = cy + hh*0.5    },
        { x = cx,           y = cy + hh        },
        { x = cx - hw*0.66, y = cy + hh*0.5    },
        { x = cx - hw,      y = cy - hh*0.15   },
    })
end

-- bouts arrondis (disque a chaque extremite de l'arc)
local function arcCaps(cx, cy, rMid, capR, aS, aE, c)
    disc(cx + cos(aS)*rMid, cy + sin(aS)*rMid, capR, c, 14)
    disc(cx + cos(aE)*rMid, cy + sin(aE)*rMid, capR, c, 14)
end

local function alpha(c, a) return Color(c.r, c.g, c.b, a) end

-- jauge circulaire : contour + anneau bouts arrondis + icone custom + valeur
local function gauge(s, cx, cy, r, frac, cBack, cFill, mat, value, ynudge)
    local th   = math.floor(11*s)          -- epaisseur anneau
    local rIn  = r - th
    local rMid = (rIn + r) / 2
    local capR = th / 2
    frac = math.Clamp(frac, 0, 1)
    local aS, aE = -math.pi/2, -math.pi/2 + frac*TAU

    -- piste (anneau de fond)
    ringArc(cx, cy, rIn, r, 0, TAU, cBack)

    -- remplissage (RIEN si frac == 0 : pas de cap residuel)
    if frac > 0 then
        ringArc(cx, cy, rIn, r, aS, aE, cFill)
        arcCaps(cx, cy, rMid, capR, aS, aE, cFill)
    end

    -- icone custom centree (ynudge = recentrage optique, ex: coeur)
    if mat then
        local isz = math.floor(rIn * 1.8)
        surface.SetMaterial(mat); surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(cx - isz/2, cy - isz/2 + isz*(ynudge or 0), isz, isz)
    end

    -- txt(value, "FRHUD_Ring", cx, cy + r + math.floor(5*s), col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

-- cadre arrondi : bordure OM + liserÃ© or + fond
local matGrad = Material("vgui/gradient-d")

local function frame(s, x, y, w, h)
    local r = math.floor(12*s)
    
    -- ERREUR CORRIGÃ‰E : La toute premiÃ¨re boÃ®te de fond Ã©tait solide Ã  100% ! On la rend transparente.
    draw.RoundedBox(r,     x,       y,       w,       h,       Color(col.om.r, col.om.g, col.om.b, 80))
    
    -- LiserÃ© bleu transparent
    draw.RoundedBox(r - 1, x + 2*s, y + 2*s, w - 4*s, h - 4*s, Color(col.om.r, col.om.g, col.om.b, 40))
    
    -- Fond gris trÃ¨s transparent pour voir le jeu
    draw.RoundedBox(r - 2, x + 3*s, y + 3*s, w - 6*s, h - 6*s, Color(50, 50, 55, 30))
    
    -- Masque stencil pour le dÃ©gradÃ© (pour ne pas dÃ©passer des coins arrondis)
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    render.SetStencilReferenceValue(1)
    
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    
    -- IMPORTANT: DÃ©sactiver l'Ã©criture de la couleur pour que le masque ne s'affiche pas en BLANC !
    render.OverrideColorWriteEnable(true, false)
    draw.RoundedBox(r - 2, x + 3*s, y + 3*s, w - 6*s, h - 6*s, color_white)
    render.OverrideColorWriteEnable(false, false)
    
    -- On applique le dÃ©gradÃ© uniquement Ã  l'intÃ©rieur de la forme
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilPassOperation(STENCIL_KEEP)
    
    surface.SetMaterial(matGrad)
    surface.SetDrawColor(100, 200, 255, 25) -- Bleu beaucoup plus clair et trÃ¨s transparent
    surface.DrawTexturedRect(x + 3*s, y + 3*s, w - 6*s, h - 6*s)
    
    -- Fin du masque
    render.SetStencilEnable(false)
    render.ClearStencil()
end

--[[-------------------------------------------------------------------------]]
-- Etat lisse
--[[-------------------------------------------------------------------------]]
local lerpHP, lerpArmor, lerpFaim = 100, 0, 100

--[[-------------------------------------------------------------------------]]
-- Dessin
--[[-------------------------------------------------------------------------]]
hook.Add("HUDPaint", "FRHUD_Paint", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    if ply:GetObserverMode() ~= OBS_MODE_NONE then return end

    local s    = math.max(1, ScrH() / 1080)
    local pad  = math.floor(14 * s)
    local inset= math.floor(5 * s)

    -- valeurs joueur
    local hp      = math.Clamp(ply:Health(), 0, ply:GetMaxHealth())
    local maxHP   = math.max(1, ply:GetMaxHealth())
    local armor   = math.Clamp(ply:Armor(), 0, 100)
    local hunger  = math.Clamp(tonumber(ply.getDarkRPVar and ply:getDarkRPVar("Energy") or 100) or 100, 0, 100)
    local rpname  = ply.getDarkRPVar and (ply:getDarkRPVar("rpname") or ply:Nick()) or ply:Nick()
    local jobName = ply.getDarkRPVar and (ply:getDarkRPVar("job") or "Citoyen") or "Citoyen"
    local wallet  = ply.getDarkRPVar and ply:getDarkRPVar("money") or 0
    local salary  = ply.getDarkRPVar and ply:getDarkRPVar("salary") or 0

    local f   = math.Clamp(FrameTime() * 8, 0, 1)
    lerpHP    = Lerp(f, lerpHP, hp)
    lerpArmor = Lerp(f, lerpArmor, armor)
    lerpFaim  = Lerp(f, lerpFaim, hunger)
    -- snap a 0 : evite le point de couleur residuel (cap) quand la jauge est vide
    if lerpHP    < 0.5 then lerpHP    = 0 end
    if lerpArmor < 0.5 then lerpArmor = 0 end
    if lerpFaim  < 0.5 then lerpFaim  = 0 end

    -- geometrie (resserree)
    local hH       = math.floor(46 * s)
    local labelCol = math.floor(120 * s)
    local valueCol = math.floor(88 * s)
    local gapG     = math.floor(12 * s)
    local ringR    = math.floor(24 * s) -- Taille augmentÃ©e
    local ringGap  = math.floor(12 * s)
    local ringsW   = math.floor(180 * s) -- Largeur fixe originale (6*26 + 2*12) pour ne pas changer la taille du HUD
    local W = inset + pad + labelCol + valueCol + gapG + ringsW + pad + inset
    local H = hH + math.floor(100 * s)
    local x = math.floor(22 * s)
    local y = ScrH() - H - math.floor(22 * s)

    -- CADRE
    frame(s, x, y, W, H)

    local cx    = x + inset + pad
    local rEdge = x + W - inset - pad

    -- HEADER : nom RP (gauche) + job (droite)
    local nameX = x + math.floor(60*s)         -- apres le logo
    local nameY = y + math.floor(14*s)
    txt(rpname, "FRHUD_Name", nameX, nameY, col.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    surface.SetDrawColor(col.gold.r, col.gold.g, col.gold.b, 230)
    surface.DrawRect(nameX, nameY + math.floor(26*s), math.floor(32*s), math.floor(2*s))
    txt(jobName, "FRHUD_Job", rEdge, nameY, col.white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    -- separateur or
    draw.RoundedBox(0, x + inset + pad, y + hH, W - 2*(inset + pad), math.floor(2*s), col.divider)

    -- CORPS : ARGENT / SALAIRE
    local cyA = y + hH + math.floor(28*s)
    txt("ARGENT", "FRHUD_Label", cx, cyA - math.floor(12*s), col.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    txt(money(wallet), "FRHUD_Money", cx + labelCol, cyA, col.gold, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    local cyS = y + hH + math.floor(62*s)
    txt("SALAIRE", "FRHUD_Label", cx, cyS - math.floor(12*s), col.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    txt(money(salary), "FRHUD_Sal", cx + labelCol, cyS, col.gold, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    -- JAUGES VIE (coeur) / ARMURE (bouclier) / FAIM (burger)
    local gcy    = y + hH + math.floor(66*s) -- RemontÃ© lÃ©gÃ¨rement
    local faimCX = rEdge - ringR
    local armCX  = faimCX - 2*ringR - ringGap
    local vieCX  = armCX - 2*ringR - ringGap
    gauge(s, vieCX,  gcy, ringR, lerpHP / maxHP,  col.hpBack,   col.hp,    hasHeart  and matHeart  or nil, math.Round(hp),     0.06)
    gauge(s, armCX,  gcy, ringR, lerpArmor / 100, col.armBack,  col.armor, hasShield and matShield or nil, math.Round(armor),  0)
    gauge(s, faimCX, gcy, ringR, lerpFaim / 100,  col.faimBack, col.faim,  hasFaim   and matFaim   or nil, math.Round(hunger), 0)

    -- LOGO sur le coin (deborde, penchÃ©) â€” au-dessus de tout
    if hasLogo then
        local size = math.floor(82 * s)
        local lcx  = x + math.floor(11*s)
        local lcy  = y + math.floor(7*s)
        surface.SetMaterial(logo)
        surface.SetDrawColor(0, 0, 0, 110)
        surface.DrawTexturedRectRotated(lcx + 2, lcy + 2, size, size, 12)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRectRotated(lcx, lcy, size, size, 12)
    end

    -- AMMO HUD
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) then
        local clip = wep:Clip1()
        local maxClip = wep:GetMaxClip1()
        local ammoType = wep:GetPrimaryAmmoType()
        
        -- Si l'arme a des munitions ou un chargeur valide
        if clip >= 0 or (ammoType and ammoType > 0) then
            local reserve = ply:GetAmmoCount(ammoType) or 0
            
            local clipText = ""
            if maxClip > 0 then
                if reserve <= 0 then
                    clipText = clip .. " / 0"
                else
                    clipText = clip .. " / " .. maxClip
                end
            else
                clipText = reserve .. " / 0"
            end
            
            surface.SetFont("FRHUD_Ammo")
            local cw = surface.GetTextSize(clipText)

            local magText = ""
            local magTextW = 0
            if maxClip > 0 then
                local mags = math.floor(reserve / maxClip)
                
                magText = tostring(mags)
                
                surface.SetFont("FRHUD_Ammo")
                magTextW = surface.GetTextSize(magText)
            end

            local magW = math.floor(22 * s)
            
            -- Largeur dynamique selon le texte
            local contentW = math.floor(20*s) + cw + math.floor(15*s) + magW
            if magTextW > 0 then
                contentW = contentW + math.floor(15*s) + magTextW
            end
            local aw = contentW + math.floor(25*s)
            
            local ah = math.floor(70 * s)
            local ax = ScrW() - aw - math.floor(22 * s)
            local ay = ScrH() - ah - math.floor(22 * s)

            frame(s, ax, ay, aw, ah)

            -- GAUCHE: Munitions actuelles
            local textY = ay + ah / 2
            txt(clipText, "FRHUD_Ammo", ax + math.floor(20*s), textY - math.floor(4*s), col.gold, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            -- MILIEU: Icône Chargeur
            local magX = ax + math.floor(20*s) + cw + math.floor(15*s)
            local magY = ay + math.floor(18 * s)
            local magH = math.floor(36 * s)
            
            draw.RoundedBox(2, magX, magY, magW, magH, col.white)
            draw.RoundedBox(0, magX + math.floor(5*s), magY - math.floor(6*s), math.floor(12*s), math.floor(6*s), col.white)
            -- Lignes décoratives
            draw.RoundedBox(0, magX + math.floor(4*s), magY + math.floor(6*s), math.floor(14*s), math.floor(3*s), col.om)
            draw.RoundedBox(0, magX + math.floor(4*s), magY + math.floor(16*s), math.floor(14*s), math.floor(3*s), col.om)
            draw.RoundedBox(0, magX + math.floor(4*s), magY + math.floor(26*s), math.floor(14*s), math.floor(3*s), col.om)

            -- DROITE: Chargeurs restants
            if maxClip > 0 then
                txt(magText, "FRHUD_Ammo", magX + magW + math.floor(15*s), textY - math.floor(4*s), col.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
    end

end)
