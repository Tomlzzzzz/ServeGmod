--[[---------------------------------------------------------------------------
    Concession Marseille RP — client (Phase 3 : UI fullscreen)
    Fullscreen 16:9 adaptatif (ultrawide → blur sides) avec cards 3D rotatives.
---------------------------------------------------------------------------]]

-- ============================================================================
-- 1. FONTES (re-créées au changement de résolution)
-- ============================================================================
local function reloadFonts()
    surface.CreateFont("FRConcess_Display",   { font = "Poppins", size = ScreenScale(20), weight = 900, antialias = true, extended = true })
    surface.CreateFont("FRConcess_TitleXL",   { font = "Poppins", size = ScreenScale(14), weight = 800, antialias = true, extended = true })
    surface.CreateFont("FRConcess_TitleL",    { font = "Poppins", size = ScreenScale(12), weight = 700, antialias = true, extended = true })
    surface.CreateFont("FRConcess_H1",        { font = "Poppins", size = ScreenScale(10), weight = 700, antialias = true, extended = true })
    surface.CreateFont("FRConcess_H2",        { font = "Poppins", size = ScreenScale(9),  weight = 700, antialias = true, extended = true })
    surface.CreateFont("FRConcess_Body",      { font = "Poppins", size = ScreenScale(8),  weight = 600, antialias = true, extended = true })
    surface.CreateFont("FRConcess_BodySm",    { font = "Poppins", size = ScreenScale(7),  weight = 500, antialias = true, extended = true })
    surface.CreateFont("FRConcess_Tiny",      { font = "Poppins", size = ScreenScale(6),  weight = 600, antialias = true, extended = true })
    surface.CreateFont("FRConcess_Btn",       { font = "Poppins", size = ScreenScale(8),  weight = 800, antialias = true, extended = true })
    surface.CreateFont("FRConcess_Money",     { font = "Poppins", size = ScreenScale(11), weight = 800, antialias = true, extended = true })
    surface.CreateFont("FRConcess_Price",     { font = "Poppins", size = ScreenScale(10), weight = 800, antialias = true, extended = true })
    surface.CreateFont("FRConcess_PriceLg",   { font = "Poppins", size = ScreenScale(13), weight = 800, antialias = true, extended = true })
end
reloadFonts()
hook.Add("OnScreenSizeChanged", "FRConcess_ReloadFonts", reloadFonts)

-- ============================================================================
-- 2. PALETTE MARSEILLE
-- ============================================================================
local col = {
    bg_dark    = Color(7,   14,  26),
    bg_med     = Color(11,  22,  39),
    bg_panel   = Color(14,  28,  48),
    bg_card    = Color(20,  38,  62, 245),
    bg_card_h  = Color(32,  58,  92, 250),
    bg_card_v  = Color(48,  36,  14, 245),
    bg_card_vh = Color(75,  58,  22, 250),
    bg_btn     = Color(22,  38,  60),
    bg_btn_h   = Color(34,  56,  86),
    bg_input   = Color(11,  22,  39),
    om         = Color(45,  170, 225),
    om_dim     = Color(28,  110, 150),
    om_glow    = Color(45,  170, 225, 60),
    gold       = Color(255, 198, 64),
    gold_dim   = Color(170, 130, 38),
    gold_glow  = Color(255, 198, 64, 50),
    white      = Color(238, 242, 248),
    dim        = Color(150, 170, 195),
    dim2       = Color(105, 125, 150),
    dim3       = Color(75,  95,  120),
    danger     = Color(220, 70,  70),
    danger_dim = Color(130, 35,  35),
    success    = Color(80,  200, 100),
    success_d  = Color(40,  110, 55),
    pound      = Color(220, 130, 30),
    pound_dim  = Color(130, 75,  18),
    border     = Color(255, 255, 255, 20),
    border_g   = Color(255, 198, 64,  90),
    shadow     = Color(0,   0,   0,   200),
    overlay    = Color(0,   0,   0,   180),
}

-- ============================================================================
-- 3. ÉTAT GLOBAL + CACHE
-- ============================================================================
local current    = nil  -- frame VGUI
local activeTab  = "buy"
local activeCat  = "TOUS"
local searchText = ""
local activeSort = "price_asc"  -- default | name_asc | name_desc | price_asc | price_desc
local cache     = {
    vehicles    = {},
    owned       = {},
    states      = {},
    money       = 0,
    active      = nil,
    pound_ratio = 0.10,
    pound_min   = 500,
    pound_delay = 600,
    sell_ratio  = 0.5,
    server_time = 0,
    is_vip      = false,
}
local displayedMoney = 0  -- pour lerp animation

-- ============================================================================
-- 4. HELPERS
-- ============================================================================
local function fmtPrice(n)
    local s = tostring(math.floor(n or 0))
    local rev = s:reverse():gsub("(%d%d%d)", "%1 "):reverse()
    return (rev:gsub("^ ", "")) .. " €"
end

local function isOwned(class)
    for _, c in ipairs(cache.owned or {}) do if c == class then return true end end
    return false
end

local function getState(class)
    local s = (cache.states or {})[class]
    return s and s.state or "garage"
end

local function computePoundFee(price)
    return math.max(cache.pound_min or 500, math.floor((price or 0) * (cache.pound_ratio or 0.10)))
end

-- Lerp color helper
local function lerpCol(t, a, b)
    return Color(
        Lerp(t, a.r, b.r),
        Lerp(t, a.g, b.g),
        Lerp(t, a.b, b.b),
        Lerp(t, a.a or 255, b.a or 255)
    )
end

-- Boîte 16:9 adaptative centrée
local function getDesignBox()
    local sw, sh = ScrW(), ScrH()
    local target = 16 / 9
    local actual = sw / sh
    if actual > target + 0.02 then
        local boxH = sh
        local boxW = boxH * target
        return (sw - boxW) / 2, 0, boxW, boxH
    elseif actual < target - 0.02 then
        local boxW = sw
        local boxH = boxW / target
        return 0, (sh - boxH) / 2, boxW, boxH
    end
    return 0, 0, sw, sh
end

-- Blur de l'arrière-plan
local matBlur     = Material("pp/blurscreen")
local matGradUp   = Material("gui/gradient_up")
local matGradDown = Material("gui/gradient_down")
local function drawBlurBg(panel, density, dark)
    surface.SetMaterial(matBlur)
    surface.SetDrawColor(255, 255, 255, 255)
    for i = 1, 4 do
        matBlur:SetFloat("$blur", (i / 4) * (density or 6))
        matBlur:Recompute()
        render.UpdateScreenEffectTexture()
        local x, y = panel:LocalToScreen(0, 0)
        surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
    end
    surface.SetDrawColor(col.bg_dark.r, col.bg_dark.g, col.bg_dark.b, dark or 180)
    local x, y = panel:LocalToScreen(0, 0)
    surface.DrawRect(-x, -y, ScrW(), ScrH())
end

local function getCategories()
    local seen, cats = {}, { "TOUS" }
    for _, v in ipairs(cache.vehicles or {}) do
        local c = v.category or "Divers"
        if not seen[c] then
            seen[c] = true
            table.insert(cats, c)
        end
    end
    return cats
end

local function getFilteredVehicles(mode)
    local out = {}
    local s = (searchText or ""):lower()
    for _, v in ipairs(cache.vehicles or {}) do
        local searchOk = (#s == 0 or (v.name or ""):lower():find(s, 1, true) ~= nil)
        local modeOk = true
        if mode == "garage" then
            modeOk = isOwned(v.class)
        elseif mode == "vip" then
            modeOk = (v.vip == true)
        elseif mode == "buy" then
            -- ACHETER : exclut les VIP (ils sont dans leur propre onglet)
            modeOk = (v.vip ~= true)
        end
        if searchOk and modeOk then
            table.insert(out, v)
        end
    end
    -- Tri
    if activeSort == "name_asc" then
        table.sort(out, function(a, b) return (a.name or "") < (b.name or "") end)
    elseif activeSort == "name_desc" then
        table.sort(out, function(a, b) return (a.name or "") > (b.name or "") end)
    elseif activeSort == "price_asc" then
        table.sort(out, function(a, b) return (a.price or 0) < (b.price or 0) end)
    elseif activeSort == "price_desc" then
        table.sort(out, function(a, b) return (a.price or 0) > (b.price or 0) end)
    end
    -- default = ordre config (déjà respecté)
    return out
end

local SORT_LABELS = {
    default    = "Ordre config",
    name_asc   = "Nom A→Z",
    name_desc  = "Nom Z→A",
    price_asc  = "Prix ↑",
    price_desc = "Prix ↓",
}
local SORT_ORDER = { "default", "name_asc", "name_desc", "price_asc", "price_desc" }

-- Patrimoine total des véhicules possédés
local function computePatrimoine()
    local total, count = 0, 0
    for _, v in ipairs(cache.vehicles or {}) do
        if isOwned(v.class) then
            total = total + (v.price or 0)
            count = count + 1
        end
    end
    return total, count
end

-- ============================================================================
-- 5. COMPONENT : CARD VÉHICULE
-- ============================================================================

local function buildCard(parent, v, mode, w, h)
    local isVipV    = v.vip == true
    local owned     = isOwned(v.class)
    local state     = getState(v.class)
    local isActive  = (cache.active == v.class)
    local isPound   = (state == "pound")
    local poundFee  = computePoundFee(v.price)

    local card = vgui.Create("DPanel", parent)
    card:SetSize(w, h)
    card.hoverLerp = 0
    card.glowLerp  = 0

    -- 3D preview en haut
    local previewH = math.floor(h * 0.58)
    local mp
    local vdata = (list.Get("Vehicles") or {})[v.class]
    -- Backdrop gradient derrière le 3D
    local backdrop = vgui.Create("DPanel", card)
    backdrop:SetPos(0, 0)
    backdrop:SetSize(w, math.floor(h * 0.58))
    backdrop.Paint = function(_, bw, bh)
        -- bg solide bleu nuit
        surface.SetDrawColor(col.bg_dark)
        surface.DrawRect(0, 0, bw, bh)
        -- gradient smooth via material gui/gradient_up (top → transparent en bas)
        surface.SetDrawColor(col.om.r, col.om.g, col.om.b, isVipV and 30 or 60)
        surface.SetMaterial(matGradUp)
        surface.DrawTexturedRect(0, 0, bw, bh)
        -- gradient inverse pour fade en bas
        surface.SetDrawColor(col.bg_dark.r, col.bg_dark.g, col.bg_dark.b, 150)
        surface.SetMaterial(matGradDown)
        surface.DrawTexturedRect(0, 0, bw, bh)
        if isVipV then
            -- VIP : tint gold supplémentaire via gradient
            surface.SetDrawColor(col.gold.r, col.gold.g, col.gold.b, 50)
            surface.SetMaterial(matGradUp)
            surface.DrawTexturedRect(0, 0, bw, bh)
        end
    end

    if vdata and vdata.Model and vdata.Model ~= "" then
        mp = vgui.Create("DModelPanel", card)
        mp:SetPos(0, 0)
        mp:SetSize(w, previewH)
        mp:SetModel(vdata.Model)
        mp:SetMouseInputEnabled(false)
        mp:SetFOV(45)
        mp:SetAmbientLight(Color(110, 125, 150))
        mp:SetDirectionalLight(BOX_TOP,    Color(255, 240, 220))
        mp:SetDirectionalLight(BOX_FRONT,  Color(180, 195, 220))
        mp:SetDirectionalLight(BOX_RIGHT,  Color(255, 198, 64))
        local ent = mp:GetEntity()
        if IsValid(ent) then
            local mins, maxs = ent:GetRenderBounds()
            local center = (mins + maxs) * 0.5
            local size = math.max(maxs.x - mins.x, maxs.y - mins.y, maxs.z - mins.z)
            -- Vue 3/4 standard, caméra à hauteur d'épaule
            mp:SetCamPos(center + Vector(size * 1.3, size * 1.1, size * 0.55))
            mp:SetLookAt(center)
        end
        function mp:LayoutEntity(e)
            e:SetAngles(Angle(0, RealTime() * 20, 0))
        end
    else
        -- placeholder visuel quand pas de modèle
        local ph = vgui.Create("DPanel", card)
        ph:SetPos(0, 0)
        ph:SetSize(w, previewH)
        ph.Paint = function(_, pw, ph_)
            -- bg gradient
            surface.SetDrawColor(col.bg_med)
            surface.DrawRect(0, 0, pw, ph_)
            -- icône voiture stylisée (cercle + triangle)
            local cx, cy = pw / 2, ph_ / 2
            local r = math.min(pw, ph_) * 0.18
            surface.SetDrawColor(col.dim3)
            surface.DrawOutlinedRect(cx - r, cy - r * 0.6, r * 2, r * 1.2)
            surface.SetDrawColor(col.dim3.r, col.dim3.g, col.dim3.b, 150)
            draw.NoTexture()
            surface.DrawPoly({
                { x = cx - r * 0.6, y = cy - r * 0.1 },
                { x = cx + r * 0.6, y = cy - r * 0.1 },
                { x = cx + r * 0.3, y = cy - r * 0.5 },
                { x = cx - r * 0.3, y = cy - r * 0.5 },
            })
            draw.SimpleText("Aperçu indisponible", "FRConcess_Tiny", cx, cy + r, col.dim2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    -- Card paint
    card.Paint = function(self, cw, ch)
        local hovered = card:IsHovered() or (mp and mp:IsHovered()) or false
        -- propagate hover from children
        for _, child in ipairs(self:GetChildren()) do
            if child:IsHovered() then hovered = true; break end
        end
        local target = hovered and 1 or 0
        self.hoverLerp = Lerp(FrameTime() * 9, self.hoverLerp, target)
        self.glowLerp  = Lerp(FrameTime() * 4, self.glowLerp,  target)

        -- ombre
        local sy = 6 + self.hoverLerp * 5
        draw.RoundedBox(10, 3, sy, cw - 6, ch - sy + 6, col.shadow)

        -- bg
        local bg  = isVipV and col.bg_card_v  or col.bg_card
        local bgh = isVipV and col.bg_card_vh or col.bg_card_h
        local cur = lerpCol(self.hoverLerp, bg, bgh)
        draw.RoundedBox(10, 0, 0, cw, ch, cur)

        -- Border gold glow on hover (multiple passes for glow)
        if self.glowLerp > 0.02 then
            local a = math.floor(self.glowLerp * 120)
            surface.SetDrawColor(col.gold.r, col.gold.g, col.gold.b, a)
            for i = 0, 1 do
                surface.DrawOutlinedRect(i, i, cw - i*2, ch - i*2)
            end
        end

        -- Top accent bar (gold for VIP, om for normal)
        local accentCol = isVipV and col.gold or col.om
        surface.SetDrawColor(accentCol)
        surface.DrawRect(0, 0, cw, 2)

        -- Divider sous le preview 3D
        if mp then
            surface.SetDrawColor(col.border)
            surface.DrawRect(12, previewH, cw - 24, 1)
        end

        -- VIP badge top-right
        if isVipV then
            local bw, bh = ScreenScale(34), ScreenScale(16)
            draw.RoundedBox(3, cw - bw - 8, 8, bw, bh, col.gold)
            draw.SimpleText("VIP", "FRConcess_Tiny", cw - bw/2 - 8, 8 + bh/2, col.bg_dark, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- Owned badge top-left (en mode ACHETER ou VIP)
        if (mode == "buy" or mode == "vip") and owned then
            local bw, bh = ScreenScale(46), ScreenScale(16)
            draw.RoundedBox(3, 8, 8, bw, bh, col.success_d)
            draw.SimpleText("POSSÉDÉ", "FRConcess_Tiny", 8 + bw/2, 8 + bh/2, col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- Info zone
        local infoY = previewH + ScreenScale(8)
        local nameMaxW = cw - ScreenScale(20)
        -- Truncate long names
        local displayName = v.name or v.class or "?"
        surface.SetFont("FRConcess_H1")
        local tw = surface.GetTextSize(displayName)
        if tw > nameMaxW then
            while tw > nameMaxW and #displayName > 4 do
                displayName = displayName:sub(1, -2)
                tw = surface.GetTextSize(displayName .. "…")
            end
            displayName = displayName .. "…"
        end
        draw.SimpleText(displayName, "FRConcess_H1", ScreenScale(10), infoY, col.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        -- Bottom-right : prix (mode buy/vip) ou tag (mode garage)
        local bRowY = ch - ScreenScale(38)
        if mode == "buy" or mode == "vip" then
            draw.SimpleText(fmtPrice(v.price), "FRConcess_Price", cw - ScreenScale(10), bRowY, col.gold, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        elseif mode == "garage" then
            local tag, tagCol
            if isActive then tag, tagCol = "EN UTILISATION", col.danger
            elseif isPound then tag, tagCol = "FOURRIÈRE", col.pound
            else tag, tagCol = "AU GARAGE", col.dim end
            draw.SimpleText(tag, "FRConcess_BodySm", cw - ScreenScale(10), bRowY, tagCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end
    end

    -- Button d'action en bas
    local btnH = ScreenScale(22)
    local btn = vgui.Create("DButton", card)
    btn:SetPos(ScreenScale(8), h - btnH - ScreenScale(8))
    btn:SetSize(w - ScreenScale(16), btnH)
    btn:SetText("")
    btn.hL = 0

    local function paintBtn(bg, label)
        return function(self, bw, bh)
            local h = self:IsHovered() and 1 or 0
            self.hL = Lerp(FrameTime() * 12, self.hL, h)
            draw.RoundedBox(5, 0, 0, bw, bh, bg(self.hL))
            draw.SimpleText(label, "FRConcess_Btn", bw/2, bh/2, col.bg_dark, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local function paintBtnWhite(bg, label)
        return function(self, bw, bh)
            local h = self:IsHovered() and 1 or 0
            self.hL = Lerp(FrameTime() * 12, self.hL, h)
            draw.RoundedBox(5, 0, 0, bw, bh, bg(self.hL))
            draw.SimpleText(label, "FRConcess_Btn", bw/2, bh/2, col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    if mode == "buy" or mode == "vip" then
        if owned then
            btn:SetDisabled(true)
            btn.Paint = function(_, bw, bh)
                draw.RoundedBox(5, 0, 0, bw, bh, col.success_d)
                draw.SimpleText("DÉJÀ ACHETÉ", "FRConcess_Btn", bw/2, bh/2, col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        else
            local needVip = isVipV and not cache.is_vip
            local canAfford = (cache.money or 0) >= (v.price or 0)
            if needVip then
                btn.Paint = paintBtnWhite(function(t) return lerpCol(t, col.danger_dim, col.danger) end, "VIP REQUIS")
                btn.DoClick = function()
                    surface.PlaySound("buttons/button10.wav")
                    chat.AddText(col.danger, "[Concession] ", col.white, "Réservé aux VIP.")
                end
            elseif not canAfford then
                btn.Paint = paintBtnWhite(function(t) return lerpCol(t, col.danger_dim, col.danger) end, "TROP CHER")
                btn.DoClick = function()
                    surface.PlaySound("buttons/button10.wav")
                    chat.AddText(col.danger, "[Concession] ", col.white, "Pas assez d'argent.")
                end
            else
                btn.Paint = paintBtn(function(t) return lerpCol(t, col.gold_dim, col.gold) end, "ACHETER")
                btn.DoClick = function()
                    surface.PlaySound("buttons/button14.wav")
                    net.Start("FRConcess_Buy")
                        net.WriteString(v.class)
                    net.SendToServer()
                end
            end
        end
    else  -- garage
        -- Split bottom : 65% main action + 35% VENDRE
        local mainW = math.floor((w - ScreenScale(16)) * 0.65)
        local sellW = (w - ScreenScale(16)) - mainW - ScreenScale(4)
        btn:SetSize(mainW, btnH)

        if isActive then
            btn.Paint = paintBtnWhite(function(t) return lerpCol(t, col.danger_dim, col.danger) end, "RANGER")
            btn.DoClick = function()
                surface.PlaySound("buttons/button14.wav")
                net.Start("FRConcess_Store")
                net.SendToServer()
            end
        elseif isPound then
            local canAfford = (cache.money or 0) >= poundFee
            if canAfford then
                btn.Paint = paintBtnWhite(function(t) return lerpCol(t, col.pound_dim, col.pound) end, "PAYER " .. fmtPrice(poundFee))
                btn.DoClick = function()
                    surface.PlaySound("buttons/button14.wav")
                    net.Start("FRConcess_PayPound")
                        net.WriteString(v.class)
                    net.SendToServer()
                end
            else
                btn.Paint = paintBtnWhite(function(t) return lerpCol(t, col.danger_dim, col.danger) end, "FOURRIÈRE TROP CHÈRE")
                btn.DoClick = function()
                    surface.PlaySound("buttons/button10.wav")
                    chat.AddText(col.danger, "[Concession] ", col.white, "Pas assez : " .. fmtPrice(poundFee) .. " requis.")
                end
            end
        else
            btn.Paint = paintBtnWhite(function(t) return lerpCol(t, col.success_d, col.success) end, "SORTIR")
            btn.DoClick = function()
                surface.PlaySound("buttons/button14.wav")
                net.Start("FRConcess_Spawn")
                    net.WriteString(v.class)
                net.SendToServer()
                if IsValid(current) then current:Remove() end
            end
        end

        -- 2nd button : VENDRE
        local sellPrice = math.floor((v.price or 0) * (cache.sell_ratio or 0.5))
        local sellBtn = vgui.Create("DButton", card)
        sellBtn:SetPos(ScreenScale(8) + mainW + ScreenScale(4), h - btnH - ScreenScale(8))
        sellBtn:SetSize(sellW, btnH)
        sellBtn:SetText("")
        sellBtn.hL = 0
        sellBtn.Paint = function(self, bw, bh)
            local hov = self:IsHovered() and 1 or 0
            self.hL = Lerp(FrameTime() * 12, self.hL, hov)
            -- bg : dark gold/brown au repos, gold au hover
            local bg
            if isPound then
                bg = Color(50, 50, 50, 200)  -- désactivé
            else
                bg = lerpCol(self.hL, Color(60, 45, 18), col.gold)
            end
            draw.RoundedBox(5, 0, 0, bw, bh, bg)
            local txt = self.hL > 0.5 and col.bg_dark or col.gold
            draw.SimpleText("VENDRE", "FRConcess_BodySm", bw/2, bh/2 - ScreenScale(4), isPound and col.dim or txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(fmtPrice(sellPrice), "FRConcess_Tiny", bw/2, bh/2 + ScreenScale(6), isPound and col.dim or txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        sellBtn.DoClick = function()
            if isPound then
                surface.PlaySound("buttons/button10.wav")
                chat.AddText(col.danger, "[Concession] ", col.white, "Récupère ce véhicule de la fourrière d'abord.")
                return
            end
            -- Custom confirm popup style Marseille (au-dessus du menu)
            local cf = vgui.Create("DFrame")
            local cfw, cfh = 680, 300
            cf:SetSize(cfw, cfh)
            cf:Center()
            cf:MakePopup()
            cf:SetTitle("")
            cf:ShowCloseButton(false)
            cf:SetDraggable(false)
            cf:SetZPos(99999)
            cf:MoveToFront()
            function cf:Think() self:MoveToFront() end
            cf.Paint = function(_, w, h)
                draw.RoundedBox(10, 0, 0, w, h, col.om)
                draw.RoundedBox(8, 2, 2, w-4, h-4, col.gold)
                draw.RoundedBox(6, 4, 4, w-8, h-8, col.bg_panel)
                draw.RoundedBoxEx(6, 4, 4, w-8, 48, col.bg_dark, true, true, false, false)
                draw.SimpleText("VENTE DU VÉHICULE", "FRConcess_H1", w/2, 24, col.gold, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                -- corps
                draw.SimpleText(v.name or v.class, "FRConcess_H1", w/2, 95, col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("sera vendu pour", "FRConcess_BodySm", w/2, 130, col.dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(fmtPrice(sellPrice), "FRConcess_TitleL", w/2, 170, col.gold, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("Cette action est définitive.", "FRConcess_Tiny", w/2, 210, col.dim2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            -- Boutons en bas
            local btnY, btnH = cfh - 60, 40
            local btnW = (cfw - 80) / 2
            local cancelBtn = vgui.Create("DButton", cf)
            cancelBtn:SetPos(28, btnY)
            cancelBtn:SetSize(btnW, btnH)
            cancelBtn:SetText("")
            cancelBtn.hL = 0
            cancelBtn.Paint = function(self, bw, bh)
                local h = self:IsHovered() and 1 or 0
                self.hL = Lerp(FrameTime() * 12, self.hL, h)
                draw.RoundedBox(6, 0, 0, bw, bh, lerpCol(self.hL, col.bg_btn, col.bg_btn_h))
                draw.SimpleText("ANNULER", "FRConcess_Body", bw/2, bh/2, col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            cancelBtn.DoClick = function()
                surface.PlaySound("ui/buttonclick.wav")
                cf:Remove()
            end
            local okBtn = vgui.Create("DButton", cf)
            okBtn:SetPos(28 + btnW + 24, btnY)
            okBtn:SetSize(btnW, btnH)
            okBtn:SetText("")
            okBtn.hL = 0
            okBtn.Paint = function(self, bw, bh)
                local h = self:IsHovered() and 1 or 0
                self.hL = Lerp(FrameTime() * 12, self.hL, h)
                draw.RoundedBox(6, 0, 0, bw, bh, lerpCol(self.hL, col.danger_dim, col.danger))
                draw.SimpleText("CONFIRMER LA VENTE", "FRConcess_Body", bw/2, bh/2, col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            okBtn.DoClick = function()
                surface.PlaySound("buttons/button14.wav")
                net.Start("FRConcess_Sell")
                    net.WriteString(v.class)
                net.SendToServer()
                cf:Remove()
            end
        end
    end

    return card
end

-- ============================================================================
-- 6. RECONSTRUCTION DU CONTENU (grid)
-- ============================================================================
local scrollContent  -- forward decl (carousel container)

local function rebuildContent()
    if not IsValid(scrollContent) then return end
    scrollContent:Clear()

    local vehicles = getFilteredVehicles(activeTab)

    if #vehicles == 0 then
        local lbl = vgui.Create("DLabel", scrollContent)
        lbl:SetPos(0, ScreenScale(20))
        lbl:SetSize(scrollContent:GetWide(), ScreenScale(40))
        lbl:SetFont("FRConcess_H1")
        lbl:SetTextColor(col.dim)
        lbl:SetContentAlignment(5)
        if activeTab == "garage" then
            lbl:SetText("Aucun véhicule possédé.")
        elseif #searchText > 0 then
            lbl:SetText("Aucun véhicule ne correspond à \"" .. searchText .. "\".")
        else
            lbl:SetText("Aucun véhicule disponible.")
        end
        return
    end

    -- Carousel horizontal : 1 ligne de cards, scroll mouse wheel
    -- Cards LANDSCAPE (plus larges que hautes) → preview 3D plus grande
    local cardH = scrollContent:GetTall() - ScreenScale(8)
    local cardW = math.floor(cardH * 1.18)  -- landscape, vehicule s'affiche bien
    local pad   = ScreenScale(8)

    -- Inner container plus large que la fenêtre, pour scroll horizontal
    local totalW = (cardW + pad) * #vehicles + pad
    local inner = vgui.Create("DPanel", scrollContent)
    inner:SetPos(0, ScreenScale(4))
    inner:SetSize(totalW, cardH)
    inner.Paint = function() end
    inner.scrollX = 0
    inner.targetX = 0
    inner.maxX    = 0  -- min x position (négatif)
    function inner:Think()
        self.maxX = -math.max(0, totalW - scrollContent:GetWide())
        self.targetX = math.Clamp(self.targetX, self.maxX, 0)
        self.scrollX = Lerp(FrameTime() * 12, self.scrollX, self.targetX)
        if math.abs(self.scrollX - self.targetX) < 0.5 then self.scrollX = self.targetX end
        self:SetPos(math.Round(self.scrollX), ScreenScale(4))
    end

    -- Wheel scroll capturé sur scrollContent
    scrollContent.OnMouseWheeled = function(_, delta)
        inner.targetX = inner.targetX + delta * (cardW + pad)
    end

    -- Cards
    for i, v in ipairs(vehicles) do
        local card = buildCard(inner, v, activeTab, cardW, cardH)
        card:SetPos(pad + (cardW + pad) * (i - 1), 0)
    end

    -- Boutons arrows gauche/droite (overlay sur scrollContent)
    local arrowW = ScreenScale(24)
    local arrowH = ScreenScale(36)
    local leftA = vgui.Create("DButton", scrollContent)
    leftA:SetPos(ScreenScale(2), (scrollContent:GetTall() - arrowH) / 2)
    leftA:SetSize(arrowW, arrowH)
    leftA:SetText("")
    leftA.hL = 0
    leftA.Paint = function(self, w, h)
        local hov = self:IsHovered() and 1 or 0
        self.hL = Lerp(FrameTime() * 12, self.hL, hov)
        draw.RoundedBox(6, 0, 0, w, h, lerpCol(self.hL, Color(0,0,0,150), col.gold))
        draw.SimpleText("◀", "FRConcess_H1", w/2, h/2, lerpCol(self.hL, col.gold, col.bg_dark), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    leftA.DoClick = function() inner.targetX = inner.targetX + (cardW + pad) * 3 end

    local rightA = vgui.Create("DButton", scrollContent)
    rightA:SetPos(scrollContent:GetWide() - arrowW - ScreenScale(2), (scrollContent:GetTall() - arrowH) / 2)
    rightA:SetSize(arrowW, arrowH)
    rightA:SetText("")
    rightA.hL = 0
    rightA.Paint = function(self, w, h)
        local hov = self:IsHovered() and 1 or 0
        self.hL = Lerp(FrameTime() * 12, self.hL, hov)
        draw.RoundedBox(6, 0, 0, w, h, lerpCol(self.hL, Color(0,0,0,150), col.gold))
        draw.SimpleText("▶", "FRConcess_H1", w/2, h/2, lerpCol(self.hL, col.gold, col.bg_dark), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    rightA.DoClick = function() inner.targetX = inner.targetX - (cardW + pad) * 3 end
end

-- ============================================================================
-- 7. CONSTRUCTION DU MENU (FULLSCREEN)
-- ============================================================================
local function buildMenu()
    if IsValid(current) then current:Remove() end

    local bx, by, bw, bh = getDesignBox()
    local needBlurSides = (bw < ScrW() or bh < ScrH())

    -- Frame fullscreen
    current = vgui.Create("DFrame")
    current:SetSize(ScrW(), ScrH())
    current:SetPos(0, 0)
    current:SetTitle("")
    current:ShowCloseButton(false)
    current:SetDraggable(false)
    current:MakePopup()
    current.openLerp = 0

    current.Paint = function(self, w, h)
        self.openLerp = math.min(1, self.openLerp + FrameTime() * 6)
        -- blur tout l'écran
        drawBlurBg(self, 6, 200)
    end
    -- ESC ferme le menu
    current.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            surface.PlaySound("ui/buttonclick.wav")
            self:Remove()
        end
    end
    current:SetKeyboardInputEnabled(true)

    -- Inner 16:9 panel
    local panel = vgui.Create("DPanel", current)
    panel:SetPos(bx, by)
    panel:SetSize(bw, bh)
    panel.Paint = function(self, w, h)
        -- bg base
        surface.SetDrawColor(col.bg_med)
        surface.DrawRect(0, 0, w, h)
        -- pattern diagonal subtil (lignes OM low alpha)
        surface.SetDrawColor(col.om.r, col.om.g, col.om.b, 6)
        local step = ScreenScale(48)
        for x = -h, w + h, step do
            surface.DrawLine(x, 0, x + h, h)
        end
        -- accent gold lines tout en bas
        surface.SetDrawColor(col.gold.r, col.gold.g, col.gold.b, 4)
        for x = -h, w + h, step * 1.5 do
            surface.DrawLine(x + step / 3, 0, x + h + step / 3, h)
        end
        -- vignette top + bottom
        surface.SetDrawColor(col.bg_dark)
        surface.DrawRect(0, 0, w, 4)
        surface.DrawRect(0, h - 4, w, 4)
    end

    -- ===== Header band =====
    local headerH = ScreenScale(50)
    local header = vgui.Create("DPanel", panel)
    header:SetPos(0, 0)
    header:SetSize(bw, headerH)
    header.Paint = function(self, w, h)
        -- lerp argent affiché (animation smooth)
        displayedMoney = Lerp(FrameTime() * 4, displayedMoney, cache.money or 0)
        if math.abs(displayedMoney - (cache.money or 0)) < 1 then displayedMoney = cache.money or 0 end

        -- bg solide noir bleuté
        surface.SetDrawColor(col.bg_dark)
        surface.DrawRect(0, 0, w, h)

        -- Bandes drapeau Marseille (bleu + or) en bas du header
        surface.SetDrawColor(col.om)
        surface.DrawRect(0, h - 5, w, 2)
        surface.SetDrawColor(col.gold)
        surface.DrawRect(0, h - 3, w, 3)

        -- Bloc accent vertical "drapeau" à gauche (bleu/blanc/bleu vertical)
        local flagX, flagY = ScreenScale(16), h * 0.18
        local flagW, flagH = ScreenScale(4), h * 0.64
        surface.SetDrawColor(col.om)
        surface.DrawRect(flagX, flagY, flagW, flagH / 3)
        surface.SetDrawColor(col.white)
        surface.DrawRect(flagX, flagY + flagH / 3, flagW, flagH / 3)
        surface.SetDrawColor(col.om)
        surface.DrawRect(flagX, flagY + flagH * 2 / 3, flagW, flagH / 3)

        -- Logo / titre principal
        local tx = ScreenScale(32)
        draw.SimpleText("CONCESSION", "FRConcess_TitleXL", tx, h/2 - ScreenScale(2), col.gold, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetFont("FRConcess_TitleXL")
        local tw1 = surface.GetTextSize("CONCESSION")
        draw.SimpleText("MARSEILLE", "FRConcess_TitleXL", tx + tw1 + ScreenScale(10), h/2 - ScreenScale(2), col.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        -- Sous-titre
        draw.SimpleText("VÉHICULES • LOCATION • LUXE", "FRConcess_Tiny", tx, h/2 + ScreenScale(12), col.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Portefeuille à droite (bloc encadré)
        local moneyW   = ScreenScale(180)
        local moneyX   = w - ScreenScale(60) - moneyW
        local moneyY   = (h - ScreenScale(38)) / 2
        draw.RoundedBox(6, moneyX, moneyY, moneyW, ScreenScale(38), col.bg_med)
        surface.SetDrawColor(col.gold_glow)
        surface.DrawOutlinedRect(moneyX, moneyY, moneyW, ScreenScale(38))
        -- icône € à gauche du bloc
        draw.RoundedBox(4, moneyX + ScreenScale(6), moneyY + ScreenScale(6), ScreenScale(26), ScreenScale(26), col.gold)
        draw.SimpleText("€", "FRConcess_TitleL", moneyX + ScreenScale(6) + ScreenScale(13), moneyY + ScreenScale(19), col.bg_dark, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        -- libellé + montant
        draw.SimpleText("PORTEFEUILLE", "FRConcess_Tiny", moneyX + ScreenScale(38), moneyY + ScreenScale(8), col.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(fmtPrice(displayedMoney), "FRConcess_Money", moneyX + ScreenScale(38), moneyY + ScreenScale(22), col.gold, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    -- Close button
    local btnClose = vgui.Create("DButton", header)
    local btnSize = ScreenScale(24)
    btnClose:SetSize(btnSize, btnSize)
    btnClose:SetPos(bw - btnSize - ScreenScale(10), (headerH - btnSize) / 2)
    btnClose:SetText("")
    btnClose.hL = 0
    btnClose.Paint = function(self, w, h)
        local hov = self:IsHovered() and 1 or 0
        self.hL = Lerp(FrameTime() * 12, self.hL, hov)
        draw.RoundedBox(6, 0, 0, w, h, lerpCol(self.hL, col.danger_dim, col.danger))
        draw.SimpleText("✕", "FRConcess_TitleL", w/2, h/2, col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    btnClose.DoClick = function()
        surface.PlaySound("ui/buttonclick.wav")
        if IsValid(current) then current:Remove() end
    end

    -- ===== Toolbar (tabs + search) =====
    local toolbarY = headerH + ScreenScale(8)
    local toolbarH = ScreenScale(26)
    local toolbar = vgui.Create("DPanel", panel)
    toolbar:SetPos(ScreenScale(20), toolbarY)
    toolbar:SetSize(bw - ScreenScale(40), toolbarH)
    toolbar.Paint = function() end

    -- Tabs
    local function mkTab(x, w, key, label)
        local b = vgui.Create("DButton", toolbar)
        b:SetPos(x, 0)
        b:SetSize(w, toolbarH)
        b:SetText("")
        b.hL = 0
        b.actLerp = (activeTab == key) and 1 or 0
        b.Paint = function(self, ww, hh)
            local act = (activeTab == key)
            local h = self:IsHovered() and 1 or 0
            self.hL = Lerp(FrameTime() * 12, self.hL, h)
            self.actLerp = Lerp(FrameTime() * 10, self.actLerp, act and 1 or 0)
            local bg = act and col.bg_panel or lerpCol(self.hL, col.bg_btn, col.bg_btn_h)
            draw.RoundedBoxEx(8, 0, 0, ww, hh, bg, true, true, false, false)
            -- underline gold animée
            local uw = ww * self.actLerp
            draw.RoundedBox(0, (ww - uw) / 2, hh - 3, uw, 3, col.gold)
            local txt = act and col.gold or col.dim
            draw.SimpleText(label, "FRConcess_H1", ww/2, hh/2, txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        b.DoClick = function()
            if activeTab == key then return end
            activeTab = key
            surface.PlaySound("ui/buttonrollover.wav")
            rebuildContent()
        end
    end
    local tabW1 = ScreenScale(95)   -- ACHETER
    local tabW2 = ScreenScale(135)  -- MES VEHICULES
    local tabW3 = ScreenScale(85)   -- VIP
    local gap   = ScreenScale(4)

    -- ACHETER
    mkTab(0, tabW1, "buy", "ACHETER")
    -- MES VEHICULES
    mkTab(tabW1 + gap, tabW2, "garage", "MES VÉHICULES (" .. #(cache.owned or {}) .. ")")
    -- VIP (tab gold special)
    local vipTab = vgui.Create("DButton", toolbar)
    vipTab:SetPos(tabW1 + tabW2 + gap * 2, 0)
    vipTab:SetSize(tabW3, toolbarH)
    vipTab:SetText("")
    vipTab.hL = 0
    vipTab.actLerp = (activeTab == "vip") and 1 or 0
    vipTab.Paint = function(self, ww, hh)
        local act = (activeTab == "vip")
        local h = self:IsHovered() and 1 or 0
        self.hL = Lerp(FrameTime() * 12, self.hL, h)
        self.actLerp = Lerp(FrameTime() * 10, self.actLerp, act and 1 or 0)
        -- Pulsation luminosité gold (brighter ↔ darker)
        local pulse = 0.5 + 0.5 * math.sin(RealTime() * 2)
        local goldR = math.floor(Lerp(pulse, col.gold_dim.r, col.gold.r))
        local goldG = math.floor(Lerp(pulse, col.gold_dim.g, col.gold.g))
        local goldB = math.floor(Lerp(pulse, col.gold_dim.b, col.gold.b))
        local goldBright = Color(goldR, goldG, goldB)
        local bg = act and col.gold or (self:IsHovered() and col.gold or goldBright)
        draw.RoundedBoxEx(8, 0, 0, ww, hh, bg, true, true, false, false)
        -- Sweep "shine" qui traverse le tab horizontalement (clippé dans le tab)
        local sweepX = ((RealTime() * 80) % (ww + ScreenScale(60))) - ScreenScale(30)
        for i = -ScreenScale(15), ScreenScale(15), 1 do
            local px = sweepX + i
            if px >= 0 and px <= ww then
                local a = math.max(0, 60 * (1 - math.abs(i) / ScreenScale(15)))
                surface.SetDrawColor(255, 255, 255, a)
                surface.DrawRect(px, 0, 1, hh)
            end
        end
        -- underline OM en bas
        local uw = ww * self.actLerp
        draw.RoundedBox(0, (ww - uw) / 2, hh - 3, uw, 3, col.om)
        -- étoile + texte VIP
        draw.SimpleText("★ VIP", "FRConcess_H1", ww/2, hh/2, col.bg_dark, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    vipTab.DoClick = function()
        if activeTab == "vip" then return end
        activeTab = "vip"
        surface.PlaySound("ui/buttonrollover.wav")
        rebuildContent()
    end

    -- Search bar (droite) — taille calculée pour ne pas chevaucher les tabs
    local tabsTotalW = tabW1 + tabW2 + tabW3 + gap * 3
    local searchW    = math.min(ScreenScale(220), toolbar:GetWide() - tabsTotalW - ScreenScale(20))
    local rightX     = toolbar:GetWide() - searchW

    local searchPanel = vgui.Create("DPanel", toolbar)
    searchPanel:SetPos(rightX, 0)
    searchPanel:SetSize(searchW, toolbarH)
    searchPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, col.bg_input)
        surface.SetDrawColor(col.border)
        surface.DrawOutlinedRect(0, 0, w, h)
        draw.SimpleText("⌕", "FRConcess_H1", ScreenScale(12), h/2, col.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local searchEntry = vgui.Create("DTextEntry", searchPanel)
    searchEntry:SetPos(ScreenScale(28), 0)
    searchEntry:SetSize(searchW - ScreenScale(36), toolbarH)
    searchEntry:SetFont("FRConcess_Body")
    searchEntry:SetText(searchText)
    if searchEntry.SetPlaceholderText then searchEntry:SetPlaceholderText("Rechercher...") end
    if searchEntry.SetPlaceholderColor then searchEntry:SetPlaceholderColor(col.dim3) end
    searchEntry:SetTextColor(col.white)
    searchEntry:SetDrawBackground(false)
    searchEntry:SetUpdateOnType(true)
    searchEntry.OnValueChange = function(_, val)
        searchText = val or ""
        timer.Remove("FRConcess_SearchDebounce")
        timer.Create("FRConcess_SearchDebounce", 0.15, 1, function()
            if IsValid(scrollContent) then rebuildContent() end
        end)
    end

    -- ===== Footer stats (compact) =====
    local footerH = ScreenScale(20)
    local footer = vgui.Create("DPanel", panel)
    footer:SetPos(0, bh - footerH)
    footer:SetSize(bw, footerH)
    footer.Paint = function(self, w, h)
        surface.SetDrawColor(col.bg_dark)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(col.border)
        surface.DrawRect(0, 0, w, 1)

        local total = #getFilteredVehicles(activeTab)
        local lib
        if activeTab == "garage" then lib = "véhicule(s) au garage"
        elseif activeTab == "vip" then lib = "véhicule(s) VIP"
        else lib = "véhicule(s) en catalogue" end
        draw.SimpleText(total .. " " .. lib, "FRConcess_BodySm", ScreenScale(20), h/2, col.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        if activeTab == "garage" then
            local pat, count = computePatrimoine()
            local txt = "Patrimoine : " .. fmtPrice(pat) .. "  •  " .. count .. " véhicule(s)"
            draw.SimpleText(txt, "FRConcess_BodySm", bw/2, h/2, col.gold, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        draw.SimpleText("Molette : naviguer  •  ESC : fermer", "FRConcess_BodySm", bw - ScreenScale(20), h/2, col.om, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    -- ===== Carousel content (entre toolbar et footer) =====
    local contentY = toolbarY + toolbarH + ScreenScale(10)
    local contentH = bh - contentY - footerH - ScreenScale(8)
    scrollContent = vgui.Create("DPanel", panel)
    scrollContent:SetPos(ScreenScale(20), contentY)
    scrollContent:SetSize(bw - ScreenScale(40), contentH)
    scrollContent.Paint = function() end

    -- Render content
    timer.Simple(0.01, function()
        if IsValid(scrollContent) then rebuildContent() end
    end)

    surface.PlaySound("ui/buttonclick.wav")
end

-- ============================================================================
-- 8. NET HANDLER
-- ============================================================================
net.Receive("FRConcess_VehiclesList", function()
    local len  = net.ReadUInt(32)
    local json = net.ReadData(len)
    local data = util.JSONToTable(json) or {}
    local shouldOpen = data.should_open == true
    cache.vehicles    = data.vehicles    or {}
    cache.owned       = data.owned       or {}
    cache.states      = data.states      or {}
    cache.money       = data.money       or 0
    cache.active      = data.active
    cache.pound_ratio = data.pound_ratio or 0.10
    cache.pound_min   = data.pound_min   or 500
    cache.pound_delay = data.pound_delay or 600
    cache.sell_ratio  = data.sell_ratio  or 0.5
    cache.server_time = data.server_time or 0
    cache.is_vip      = data.is_vip      == true

    if IsValid(current) then
        -- menu déjà ouvert : refresh content seulement (smooth)
        if IsValid(scrollContent) then rebuildContent() end
    elseif shouldOpen then
        -- ouverture uniquement si demandée (E sur NPC), jamais sur un refresh post-action
        buildMenu()
    end
end)

-- ============================================================================
-- 9. HOOKS DARKRP KEYS (HIDE HUD + BLOCK MENU)
-- ============================================================================
-- Animation overlay : dessiné via DrawOverlay (au-dessus de TOUT le VGUI)
local activeOverlay = nil  -- { action, vname, amount, spawnT, life, scale }

local function showActionOverlay(action, vname, amount)
    activeOverlay = {
        action = action,
        vname  = vname or "",
        amount = amount or 0,
        spawnT = RealTime(),
        life   = 2.6,
        scale  = 0.6,
    }
end

hook.Add("DrawOverlay", "FRConcess_DrawActionOverlay", function()
    if not activeOverlay then return end
    local ov = activeOverlay
    local elapsed = RealTime() - ov.spawnT
    if elapsed > ov.life then activeOverlay = nil; return end

    -- alpha fade
    local a
    if elapsed < 0.25 then a = elapsed / 0.25
    elseif elapsed > ov.life - 0.5 then a = (ov.life - elapsed) / 0.5
    else a = 1 end
    a = math.Clamp(a, 0, 1)

    -- scale bounce in
    ov.scale = Lerp(FrameTime() * 12, ov.scale, 1)

    local w, h = ScreenScale(320), ScreenScale(110)
    local sw, sh = w * ov.scale, h * ov.scale
    local sx, sy = (ScrW() - sw) / 2, ScrH() * 0.32 + (h - sh) / 2

    local isBuy = (ov.action == "buy")
    local accentCol = isBuy and col.success or col.gold
    accentCol = Color(accentCol.r, accentCol.g, accentCol.b, 255 * a)
    local bgCol = Color(col.bg_dark.r, col.bg_dark.g, col.bg_dark.b, 240 * a)

    -- shadow
    draw.RoundedBox(12, sx + 3, sy + 6, sw, sh, Color(0, 0, 0, 200 * a))
    -- bg
    draw.RoundedBox(12, sx, sy, sw, sh, bgCol)
    -- accents top + bottom
    draw.RoundedBoxEx(12, sx, sy, sw, ScreenScale(4), accentCol, true, true, false, false)
    draw.RoundedBoxEx(12, sx, sy + sh - ScreenScale(4), sw, ScreenScale(4), accentCol, false, false, true, true)

    -- icone €
    local icx = sx + ScreenScale(32)
    local icy = sy + sh / 2
    local iconR = ScreenScale(20)
    draw.NoTexture()
    draw.RoundedBox(iconR, icx - iconR, icy - iconR, iconR * 2, iconR * 2, accentCol)
    draw.SimpleText(isBuy and "−€" or "+€", "FRConcess_TitleL", icx, icy, Color(col.bg_dark.r, col.bg_dark.g, col.bg_dark.b, 255 * a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- texte label + montant
    local tx = sx + ScreenScale(64)
    local label = isBuy and "ACHAT RÉUSSI" or "VENTE RÉUSSIE"
    draw.SimpleText(label, "FRConcess_H1", tx, sy + sh / 2 - ScreenScale(14), Color(col.white.r, col.white.g, col.white.b, 255 * a), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    local sign = isBuy and "−" or "+"
    local amtCol = isBuy and Color(255, 110, 110, 255 * a) or Color(120, 230, 140, 255 * a)
    draw.SimpleText(sign .. " " .. fmtPrice(ov.amount), "FRConcess_TitleL", tx, sy + sh / 2 + ScreenScale(10), amtCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    if ov.vname and #ov.vname > 0 then
        draw.SimpleText(ov.vname, "FRConcess_Tiny", sx + sw - ScreenScale(12), sy + sh - ScreenScale(12), Color(col.dim.r, col.dim.g, col.dim.b, 255 * a), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end
end)


net.Receive("FRConcess_ActionSuccess", function()
    local action = net.ReadString()
    local class  = net.ReadString()
    local amount = net.ReadUInt(32)
    -- Trouve le nom du vehicule
    local vname = class
    for _, v in ipairs(cache.vehicles or {}) do
        if v.class == class then vname = v.name or class; break end
    end
    -- Son cash register / coin drop
    LocalPlayer():EmitSound("ambient/levels/labs/coinslot1.wav", 75, 100, 1, CHAN_AUTO)
    -- Animation overlay
    showActionOverlay(action, vname, amount)
end)


hook.Add("HUDDrawDoorData", "FRConcess_HideKeysHUD", function(ent)
    if IsValid(ent) and ent:GetNWBool("FRConcess_IsManaged", false) then
        return true
    end
end)

-- [Plate 3D rendering retiré : VCMod ou équivalent à venir]

hook.Add("onKeysMenuOpened", "FRConcess_BlockKeysMenu", function(ent, frame)
    if IsValid(ent) and ent:GetNWBool("FRConcess_IsManaged", false) and IsValid(frame) then
        frame:SetVisible(false)
        frame:Close()
    end
end)
