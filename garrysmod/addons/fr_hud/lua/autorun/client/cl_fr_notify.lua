--[[---------------------------------------------------------------------------
    Notifications Marseille RP — style natif DarkRP, teinté OM/or
    Même format/position que le notify DarkRP d'origine (petite boîte centrée
    en bas, empilée vers le haut, fade out) mais aux couleurs Marseille.

    Override de notification.AddLegacy (bottleneck universel) + GAMEMODE:AddNotify.
---------------------------------------------------------------------------]]

local function reloadFonts()
    surface.CreateFont("FRNotify_Text", { font = "Poppins", size = ScreenScale(7), weight = 500, antialias = true, extended = true })
end
reloadFonts()
hook.Add("OnScreenSizeChanged", "FRNotify_ReloadFonts", reloadFonts)

local col = {
    bg     = Color(11, 22, 39, 230),
    om     = Color(45, 170, 225),
    gold   = Color(255, 198, 64),
    white  = Color(238, 242, 248),
    red    = Color(220, 90, 90),
    dim    = Color(160, 180, 205),
    shadow = Color(0, 0, 0, 180),
}

-- accent par type (0 generic, 1 error, 2 undo, 3 hint, 4 cleanup)
local ACCENT = {
    [0] = col.om,
    [1] = col.red,
    [2] = col.dim,
    [3] = col.gold,
    [4] = col.om,
}

local active = {}

local function pushNotify(text, ntype, length)
    table.insert(active, {
        text   = tostring(text or ""),
        accent = ACCENT[tonumber(ntype) or 0] or col.om,
        born   = RealTime(),
        life   = math.Clamp(tonumber(length) or 4, 1, 30),
        anim   = 0,
        y      = 0,
    })
    while #active > 8 do table.remove(active, 1) end
end

-- Overrides
notification.AddLegacy = function(text, ntype, length) pushNotify(text, ntype, length) end
notification.AddProgress = function(...) end
notification.Kill = notification.Kill or function() end

local function overrideGM()
    if GAMEMODE then
        GAMEMODE.AddNotify = function(_, text, ntype, length) pushNotify(text, ntype, length) end
    end
end
hook.Add("Initialize", "FRNotify_OverrideGM", overrideGM)
overrideGM()

-- Rendu : bas-droite, empilé vers le haut
hook.Add("HUDPaint", "FRNotify_Draw", function()
    local ft  = FrameTime()
    local now = RealTime()

    surface.SetFont("FRNotify_Text")
    local marginR = ScreenScale(8)
    local baseY   = ScrH() - ScreenScale(64)
    local stackY  = baseY

    for i = #active, 1, -1 do
        local n = active[i]
        local elapsed = now - n.born

        -- anim in/out
        if elapsed > n.life then
            n.anim = n.anim - ft * 6
            if n.anim <= 0 then table.remove(active, i); continue end
        else
            n.anim = math.min(1, n.anim + ft * 9)
        end

        local a = math.Clamp(n.anim, 0, 1)
        local ease = 1 - math.pow(1 - a, 3)
        local alpha = ease

        -- dimensions compactes
        local tw = surface.GetTextSize(n.text)
        local boxW = tw + ScreenScale(16)
        local boxH = ScreenScale(15)
        -- ancré à droite, slide horizontal depuis la droite à l'apparition
        local xRight = ScrW() - marginR
        local x = xRight - boxW + (1 - ease) * (boxW * 0.4)

        -- position Y animée (stack vers le haut)
        n.y = (n.y == 0) and stackY or Lerp(ft * 14, n.y, stackY)
        local y = n.y

        local A = function(c, m) return Color(c.r, c.g, c.b, (c.a or 255) * alpha * (m or 1)) end

        -- fond fin
        draw.RoundedBox(3, x, y, boxW, boxH, A(col.bg))
        -- liseré accent vertical à gauche (fin)
        draw.RoundedBoxEx(3, x, y, ScreenScale(2.5), boxH, A(n.accent), true, false, true, false)
        -- texte
        draw.SimpleText(n.text, "FRNotify_Text", x + boxW/2 + ScreenScale(1), y + boxH/2, A(col.white), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        stackY = stackY - boxH - ScreenScale(3)
    end
end)

print("[fr_hud] Notifications Marseille chargées")
