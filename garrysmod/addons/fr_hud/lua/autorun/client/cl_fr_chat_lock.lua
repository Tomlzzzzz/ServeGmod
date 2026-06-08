--[[---------------------------------------------------------------------------
    Verrouille le ChatBox EasyChat (drag/resize/settings/position).
    Force a chaque frame via Think pour ecraser tout reset d'EasyChat.
---------------------------------------------------------------------------]]

local function fixedBounds()
    local s = math.max(1, ScrH() / 1080)
    local w = math.floor(560 * s)
    local h = math.floor(280 * s)
    local x = math.floor(22 * s)
    local y = ScrH() - h - math.floor(220 * s)
    return x, y, w, h
end

-- Think permanent qui force le lock a chaque frame
hook.Add("Think", "FRChat_LockEnforce", function()
    if not (EasyChat and EasyChat.GUI) then return end
    local cb = EasyChat.GUI.ChatBox
    if not IsValid(cb) then return end

    cb:SetDraggable(false)
    cb:SetSizable(false)
    if IsValid(cb.BtnSettings) then cb.BtnSettings:SetVisible(false) end
    if IsValid(cb.BtnMaxim)    then cb.BtnMaxim:SetVisible(false)    end

    -- repositionne seulement si l'utilisateur a deplace (sinon spam SetPos chaque frame)
    local x, y, w, h = fixedBounds()
    local cx, cy = cb:GetPos()
    local cw, ch = cb:GetSize()
    if cx ~= x or cy ~= y then cb:SetPos(x, y) end
    if cw ~= w or ch ~= h then cb:SetSize(w, h) end

    -- INJECTION DE LA DA (100% fiable car executer des que la chatbox existe)
    if not cb.MarseilleDAApplied then
        cb.Paint = function(self, pw, ph)
            local px, py = 6, 0
            pw = pw - 13
            ph = ph - 5

            local ss = math.max(1, ScrH() / 1080)
            local r = math.floor(12*ss)
            
            -- OM Blue glow/border
            draw.RoundedBox(r,     px,       py,       pw,       ph,       Color(45, 170, 225, 80))
            draw.RoundedBox(r - 1, px + 2*ss, py + 2*ss, pw - 4*ss, ph - 4*ss, Color(45, 170, 225, 40))
            
            -- Night blue inner background
            draw.RoundedBox(r - 2, px + 3*ss, py + 3*ss, pw - 6*ss, ph - 6*ss, Color(11, 23, 42, 240))

            -- Divider under tabs
            surface.SetDrawColor(255, 198, 64, 150)
            surface.DrawRect(px + 4*ss, 28, pw - 8*ss, 2)
        end
        cb.MarseilleDAApplied = true
    end

    if cb.Tabs and cb.Tabs.Items then
        for _, item in pairs(cb.Tabs.Items) do
            local tab = item.Panel
            if IsValid(tab) and not tab.MarseilleDAApplied then
                if IsValid(tab.TextEntry) then
                    tab.TextEntry.Paint = function(_, pw, ph)
                        draw.RoundedBox(6, 0, 0, pw, ph, Color(0, 0, 0, 200))
                        draw.RoundedBox(0, 0, ph - 1, pw, 1, Color(45, 170, 225, 100))
                    end
                    if tab.TextEntry.SetBackgroundColor then
                        tab.TextEntry:SetBackgroundColor(Color(0, 0, 0, 200))
                        tab.TextEntry:SetBorderColor(Color(0, 0, 0, 0))
                    end
                end

                local function btn_paint(btn, pw, ph)
                    local hover = btn:IsHovered()
                    draw.RoundedBox(6, 0, 0, pw, ph, hover and Color(45, 170, 225, 120) or Color(11, 23, 42, 200))
                    draw.RoundedBox(0, 0, ph - 1, pw, 1, hover and Color(255, 198, 64, 200) or Color(45, 170, 225, 100))
                end

                if IsValid(tab.BtnSwitch) then tab.BtnSwitch.Paint = btn_paint end
                if IsValid(tab.BtnEmotePicker) then tab.BtnEmotePicker.Paint = btn_paint end
                if IsValid(tab.BtnColorPicker) then tab.BtnColorPicker.Paint = btn_paint end
                
                tab.MarseilleDAApplied = true
            end
        end
    end
end)
