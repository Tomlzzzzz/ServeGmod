--[[---------------------------------------------------------------------------
    Theme EasyChat — Marseille RP
    Force les couleurs OM/or sur le chatbox EasyChat de chaque client.
    S'execute apres le chargement d'EasyChat.
---------------------------------------------------------------------------]]

local function apply()
    -- force le strip des tags markup dans le ChatBox
    local cv = GetConVar("easychat_tags_in_chatbox")
    if cv then cv:SetInt(0) end
    -- desactive les messages join/leave EasyChat (on a notre propre "Bienvenue")
    local cvJL = GetConVar("easychat_joinleave_msg")
    if cvJL then cvJL:SetInt(0) end
    -- desactive le rechargement de l'historique au boot (evite le spam Photon des sessions precedentes)
    local cvH = GetConVar("easychat_history")
    if cvH then cvH:SetInt(0) end
    -- clean l'historique sauvegarde existant
    if file.Exists("easychat/history/global.txt", "DATA") then
        file.Delete("easychat/history/global.txt")
    end

    if not EasyChat then return false end

    -- police Poppins (deja bundlee pour le HUD)
    RunConsoleCommand("easychat_font", "Poppins")
    RunConsoleCommand("easychat_font_size", "17")

    EasyChat.FontName = "Poppins"
    EasyChat.FontSize = 17
    -- force re-creation du font et application
    surface.CreateFont("EasyChatFont", {
        font = "Poppins", extended = true, size = 17, weight = 500, antialias = true,
    })
    if EasyChat.GUI and IsValid(EasyChat.GUI.RichText) then
        EasyChat.GUI.RichText:SetFontInternal("EasyChatFont")
    end
    if EasyChat.GUI and IsValid(EasyChat.GUI.TextEntry) then
        EasyChat.GUI.TextEntry:SetFont("EasyChatFont")
    end

    -- couleurs Marseille (raccord HUD)
    EasyChat.OutlayColor        = Color(11, 23, 42, 240)   -- fond chatbox (bleu nuit)
    EasyChat.OutlayOutlineColor = Color(255, 198, 64, 220) -- liseré or
    EasyChat.TabColor           = Color(11, 23, 42, 230)
    EasyChat.TabOutlineColor    = Color(45, 170, 225, 255) -- bleu OM
    EasyChat.TextColor          = Color(238, 242, 248, 255)

    -- persistance : sauve aussi dans data/easychat/colors.txt
    -- (utilise par EasyChat au prochain demarrage)
    if file.CreateDir then file.CreateDir("easychat") end
    local payload = util.TableToJSON({
        outlay        = { r = 11,  g = 23,  b = 42,  a = 240 },
        outlayoutline = { r = 255, g = 198, b = 64,  a = 220 },
        tab           = { r = 11,  g = 23,  b = 42,  a = 230 },
        taboutline    = { r = 45,  g = 170, b = 225, a = 255 },
    })
    file.Write("easychat/colors.txt", payload)

    -- DYNAMIC VGUI OVERRIDES (Bypasses Workshop Addon Conflicts)
    -- DYNAMIC VGUI OVERRIDES (Bypasses Workshop Addon Conflicts)
    local function MarseilleChatPaint(self, w, h)
        local px, py = 6, 0
        local pw = w - 13
        local ph = h - 5

        local s = math.max(1, ScrH() / 1080)
        local r = math.floor(12*s)
        
        -- OM Blue glow/border
        draw.RoundedBox(r,     px,       py,       pw,       ph,       Color(45, 170, 225, 80))
        draw.RoundedBox(r - 1, px + 2*s, py + 2*s, pw - 4*s, ph - 4*s, Color(45, 170, 225, 40))
        
        -- Night blue inner background
        draw.RoundedBox(r - 2, px + 3*s, py + 3*s, pw - 6*s, ph - 6*s, Color(11, 23, 42, 240))

        -- Divider under tabs
        surface.SetDrawColor(255, 198, 64, 150)
        surface.DrawRect(px + 4*s, 28, pw - 8*s, 2)
    end

    local function MarseilleTextEntryPaint(_, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, 200))
        -- Liseré subtil bleu OM en bas de la zone de texte
        draw.RoundedBox(0, 0, h - 1, w, 1, Color(45, 170, 225, 100))
    end

    local function btn_paint(btn, w, h)
        local hover = btn:IsHovered()
        draw.RoundedBox(6, 0, 0, w, h, hover and Color(45, 170, 225, 120) or Color(11, 23, 42, 200))
        -- Liseré Or si survolé, sinon Bleu OM
        draw.RoundedBox(0, 0, h - 1, w, 1, hover and Color(255, 198, 64, 200) or Color(45, 170, 225, 100))
    end

    local cbTable = vgui.GetControlTable("ECChatBox")
    if cbTable then
        local oldCBInit = cbTable.Init
        cbTable.Init = function(self)
            if oldCBInit then oldCBInit(self) end
            self.Paint = MarseilleChatPaint
        end
    end

    local tabTable = vgui.GetControlTable("ECChatTab")
    if tabTable then
        local oldInit = tabTable.Init
        tabTable.Init = function(self)
            if oldInit then oldInit(self) end
            
            if IsValid(self.TextEntry) then
                self.TextEntry.Paint = MarseilleTextEntryPaint
                if self.TextEntry.SetBackgroundColor then
                    self.TextEntry:SetBackgroundColor(Color(0, 0, 0, 200))
                    self.TextEntry:SetBorderColor(Color(0, 0, 0, 0))
                end
            end
            
            if IsValid(self.BtnSwitch) then self.BtnSwitch.Paint = btn_paint end
            if IsValid(self.BtnEmotePicker) then self.BtnEmotePicker.Paint = btn_paint end
            if IsValid(self.BtnColorPicker) then self.BtnColorPicker.Paint = btn_paint end
        end
    end

    -- Force update existing chatbox if opened
    if EasyChat.GUI and IsValid(EasyChat.GUI.ChatBox) then
        local cb = EasyChat.GUI.ChatBox
        cb.Paint = MarseilleChatPaint
        
        -- Force update existing tabs
        if cb.Tabs and cb.Tabs.Items then
            for _, item in pairs(cb.Tabs.Items) do
                local tab = item.Panel
                if IsValid(tab) then
                    if IsValid(tab.TextEntry) then
                        tab.TextEntry.Paint = MarseilleTextEntryPaint
                        if tab.TextEntry.SetBackgroundColor then
                            tab.TextEntry:SetBackgroundColor(Color(0, 0, 0, 200))
                            tab.TextEntry:SetBorderColor(Color(0, 0, 0, 0))
                        end
                    end
                    if IsValid(tab.BtnSwitch) then tab.BtnSwitch.Paint = btn_paint end
                    if IsValid(tab.BtnEmotePicker) then tab.BtnEmotePicker.Paint = btn_paint end
                    if IsValid(tab.BtnColorPicker) then tab.BtnColorPicker.Paint = btn_paint end
                end
            end
        end
    end

    return true
end

-- filets : EasyChat peut etre charge avant ou apres cet addon
hook.Add("ECInitialized", "FRTheme_EasyChat", apply)
hook.Add("InitPostEntity", "FRTheme_EasyChat_IPE", function()
    timer.Simple(1, apply)
end)
apply()
