local col = {
    bg      = Color(30, 30, 35, 240),
    row     = Color(40, 40, 45, 240),
    om      = Color(45, 170, 225),
    gold    = Color(255, 198, 64),
    white   = Color(238, 242, 248),
    dim     = Color(180, 180, 190),
}

local function S(val)
    return math.floor(val * math.max(1, ScrH() / 1080))
end

surface.CreateFont("FRHUD_WepSel", {
    font = "Sedgwick Ave Display",
    size = S(40),
    weight = 500,
    antialias = true
})

surface.CreateFont("FRHUD_WepSelSmall", {
    font = "Roboto",
    size = S(20),
    weight = 500,
    antialias = true
})

local WepSelect = {
    ShowTime = 0,
    SelectedSlot = 1,
    SelectedPos = 1,
    IsOpen = false,
    Alpha = 0
}

local function HideWeaponMenuInstantly()
    WepSelect.IsOpen = false
    WepSelect.Alpha = 0
    if IsValid(WepSelect.Container) then
        WepSelect.Container:SetVisible(false)
    end
end

local function GetWeaponsBySlot()
    local ply = LocalPlayer()
    if not IsValid(ply) then return {} end
    
    local weps = ply:GetWeapons()
    local slots = {}
    
    for _, w in ipairs(weps) do
        local slot = w:GetSlot() + 1
        local pos = w:GetSlotPos() + 1
        
        slots[slot] = slots[slot] or {}
        slots[slot][pos] = w
    end
    
    -- Clean up gaps in positions
    for k, v in pairs(slots) do
        local sorted = {}
        for _, w in pairs(v) do table.insert(sorted, w) end
        slots[k] = sorted
    end
    
    return slots
end

hook.Add("HUDShouldDraw", "FRHUD_HideWeaponSelection", function(name)
    if name == "CHudWeaponSelection" then return false end
end)

local function ConfirmSelection()
    local ply = LocalPlayer()
    local slots = GetWeaponsBySlot()
    if slots[WepSelect.SelectedSlot] and slots[WepSelect.SelectedSlot][WepSelect.SelectedPos] then
        local wep = slots[WepSelect.SelectedSlot][WepSelect.SelectedPos]
        if IsValid(wep) then
            input.SelectWeapon(wep)
        end
    end
    WepSelect.IsOpen = false
end

hook.Add("PlayerBindPress", "FRHUD_WeaponSelectionBind", function(ply, bind, pressed)
    if not pressed then return end
    
    if string.find(bind, "gm_show") or string.find(bind, "+menu") or string.find(bind, "+showscores") then
        HideWeaponMenuInstantly()
    end

    local slots = GetWeaponsBySlot()
    if table.Count(slots) == 0 then return end

    local function OpenMenu()
        if ply:InVehicle() then return end
        if not WepSelect.IsOpen then
            local active = ply:GetActiveWeapon()
            if IsValid(active) then
                local slot = active:GetSlot() + 1
                WepSelect.SelectedSlot = slot
                
                -- Find pos
                WepSelect.SelectedPos = 1
                if slots[slot] then
                    for k, v in ipairs(slots[slot]) do
                        if v == active then WepSelect.SelectedPos = k break end
                    end
                end
            else
                WepSelect.SelectedSlot = next(slots) or 1
                WepSelect.SelectedPos = 1
            end
            WepSelect.IsOpen = true
        end
        WepSelect.ShowTime = CurTime() + 3
    end

    local function TryFastSwitch()
        if ply:GetInfoNum("hud_fastswitch", 0) == 1 then
            ConfirmSelection()
        end
    end

    if string.find(bind, "invnext") then
        OpenMenu()
        
        WepSelect.SelectedPos = WepSelect.SelectedPos + 1
        if not slots[WepSelect.SelectedSlot] or WepSelect.SelectedPos > #slots[WepSelect.SelectedSlot] then
            WepSelect.SelectedPos = 1
            WepSelect.SelectedSlot = WepSelect.SelectedSlot + 1
            while not slots[WepSelect.SelectedSlot] do
                WepSelect.SelectedSlot = WepSelect.SelectedSlot + 1
                if WepSelect.SelectedSlot > 10 then WepSelect.SelectedSlot = 1 end
            end
        end
        TryFastSwitch()
        return true
    elseif string.find(bind, "invprev") then
        OpenMenu()
        
        WepSelect.SelectedPos = WepSelect.SelectedPos - 1
        if WepSelect.SelectedPos < 1 then
            WepSelect.SelectedSlot = WepSelect.SelectedSlot - 1
            while not slots[WepSelect.SelectedSlot] do
                WepSelect.SelectedSlot = WepSelect.SelectedSlot - 1
                if WepSelect.SelectedSlot < 1 then WepSelect.SelectedSlot = 10 end
            end
            WepSelect.SelectedPos = #slots[WepSelect.SelectedSlot]
        end
        TryFastSwitch()
        return true
    elseif string.match(bind, "slot(%d)") then
        local slot = tonumber(string.match(bind, "slot(%d)"))
        if slot == 0 then slot = 10 end
        if slots[slot] then
            if WepSelect.IsOpen and WepSelect.SelectedSlot == slot then
                WepSelect.SelectedPos = WepSelect.SelectedPos + 1
                if WepSelect.SelectedPos > #slots[slot] then WepSelect.SelectedPos = 1 end
            else
                WepSelect.SelectedSlot = slot
                WepSelect.SelectedPos = 1
            end
            OpenMenu()
            TryFastSwitch()
        end
        return true
    elseif string.find(bind, "+attack") then
        if WepSelect.IsOpen then
            ConfirmSelection()
            return true
        end
    end
end)

hook.Add("HUDPaint", "FRHUD_DrawWeaponSelection", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    if WepSelect.IsOpen and (CurTime() > WepSelect.ShowTime or ply:InVehicle()) then
        HideWeaponMenuInstantly()
    end

    WepSelect.Alpha = Lerp(FrameTime() * 15, WepSelect.Alpha, WepSelect.IsOpen and 255 or 0)
    
    if WepSelect.Alpha < 1 then 
        if IsValid(WepSelect.Container) then WepSelect.Container:SetVisible(false) end
        return 
    end

    if not IsValid(WepSelect.Container) then
        WepSelect.Container = vgui.Create("Panel")
        WepSelect.Container:SetSize(ScrW(), ScrH())
        WepSelect.Container:SetMouseInputEnabled(false)
        WepSelect.Container:SetKeyboardInputEnabled(false)
        WepSelect.ModelPanels = {}
    end
    WepSelect.Container:SetVisible(true)
    WepSelect.Container:SetAlpha(WepSelect.Alpha)

    -- Hide all model panels first
    for _, pnl in pairs(WepSelect.ModelPanels) do
        if IsValid(pnl) then pnl:SetVisible(false) end
    end

    local slots = GetWeaponsBySlot()
    if table.Count(slots) == 0 then return end

    -- Verify current selection is valid
    if not slots[WepSelect.SelectedSlot] then
        WepSelect.SelectedSlot = next(slots) or 1
        WepSelect.SelectedPos = 1
    elseif not slots[WepSelect.SelectedSlot][WepSelect.SelectedPos] then
        WepSelect.SelectedPos = 1
    end

    surface.SetAlphaMultiplier(WepSelect.Alpha / 255)

    local boxW, boxH = S(240), S(100)
    local gapX, gapY = S(15), S(10)
    
    local startY = S(50)
    
    -- Find max slots for centering
    local maxSlot = 0
    for k, _ in pairs(slots) do if k > maxSlot then maxSlot = k end end
    if maxSlot == 0 then surface.SetAlphaMultiplier(1) return end

    -- Total width based on how many slots actually exist
    local totalW = 0
    local slotOffsets = {}
    for slot = 1, maxSlot do
        if slots[slot] then
            slotOffsets[slot] = totalW
            totalW = totalW + boxW + gapX
        end
    end
    totalW = totalW - gapX -- Remove trailing gap

    local startX = (ScrW() - totalW) / 2

    for slot = 1, maxSlot do
        if not slots[slot] then continue end
        
        local colX = startX + slotOffsets[slot]

        -- Draw weapons in slot
        for pos, wep in ipairs(slots[slot]) do
            local itemY = startY + (pos - 1) * (boxH + gapY)
            local isSelected = (WepSelect.SelectedSlot == slot and WepSelect.SelectedPos == pos)
            
            draw.RoundedBox(S(6), colX, itemY, boxW, boxH, col.row)
            
            if isSelected then
                -- Gold border for selected
                draw.RoundedBox(S(6), colX, itemY, boxW, boxH, col.gold)
                draw.RoundedBox(S(6), colX + S(2), itemY + S(2), boxW - S(4), boxH - S(4), col.bg)
                
                -- Highlight strip
                draw.RoundedBoxEx(S(6), colX + S(2), itemY + S(2), S(4), boxH - S(4), col.gold, true, false, true, false)
            else
                draw.RoundedBoxEx(S(6), colX, itemY, S(4), boxH, col.om, true, false, true, false)
            end

            -- Visual (3D Model or Icon)
            local wepClass = wep:GetClass()
            local wepModel = wep:GetModel()
            
            if wepModel and wepModel ~= "" then
                if not IsValid(WepSelect.ModelPanels[wepClass]) then
                    local pnl = vgui.Create("DModelPanel", WepSelect.Container)
                    pnl:SetSize(boxW - S(20), boxH - S(30))
                    pnl:SetModel(wepModel)
                    pnl:SetFOV(45)
                    
                    if IsValid(pnl.Entity) then
                        pnl.LayoutEntity = function(self, ent)
                            local mn, mx = ent:GetRenderBounds()
                            local center = (mn + mx) * 0.5
                            local radius = mn:Distance(mx) * 0.5
                            
                            -- Calculate optimal distance to fit in FOV with padding
                            local dist = radius / math.sin(math.rad(self:GetFOV() / 2)) * 1.15
                            
                            -- Orbit the camera around the geometric center to avoid weird swinging
                            local angle = RealTime() * 80
                            local orbit = Angle(25, angle, 0):Forward() * dist
                            
                            self:SetCamPos(center + orbit)
                            self:SetLookAt(center)
                        end
                        pnl.DrawModel = function(self)
                            render.SetBlend(WepSelect.Alpha / 255)
                            if IsValid(self.Entity) then
                                self.Entity:DrawModel()
                            end
                            render.SetBlend(1)
                        end
                    end
                    WepSelect.ModelPanels[wepClass] = pnl
                end
                
                local mdl = WepSelect.ModelPanels[wepClass]
                if IsValid(mdl) then
                    mdl:SetPos(colX + S(10), itemY + S(5))
                    mdl:SetVisible(true)
                end
            elseif wep.WepSelectIcon then
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetTexture(wep.WepSelectIcon)
                surface.DrawTexturedRect(colX + boxW/2 - S(64), itemY + S(5), S(128), S(64))
            end

            local wepName = wep.GetPrintName and wep:GetPrintName() or wep:GetClass()
            wepName = language.GetPhrase(wepName)

            draw.SimpleText(wepName, "FRHUD_WepSelSmall", colX + boxW/2, itemY + boxH - S(18), isSelected and col.gold or col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    surface.SetAlphaMultiplier(1)
end)

-- Fermer immédiatement le menu de sélection d'arme lors de l'ouverture d'un menu d'interaction
hook.Add("OnContextMenuOpen", "FRHUD_WeaponSelect_HideOnC", HideWeaponMenuInstantly)
hook.Add("OnSpawnMenuOpen", "FRHUD_WeaponSelect_HideOnQ", HideWeaponMenuInstantly)
hook.Add("ShowSpare2", "FRHUD_WeaponSelect_HideOnF4", HideWeaponMenuInstantly)
hook.Add("ScoreboardShow", "FRHUD_WeaponSelect_HideOnTab", HideWeaponMenuInstantly)
