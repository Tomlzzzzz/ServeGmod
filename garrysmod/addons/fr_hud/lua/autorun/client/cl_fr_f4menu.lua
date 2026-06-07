--[[-------------------------------------------------------------------------
    MENU F4 (MÉTIERS ETC) - STYLE "FR HUD"
---------------------------------------------------------------------------]]

local s = ScrH() / 1080
local function S(val) return math.floor(val * s) end

-- On recrée les polices spécifiques au F4 pour être sûr qu'elles existent
surface.CreateFont("FRF4_Title", { font = "Sedgwick Ave Display", size = S(50), weight = 500, antialias = true })
surface.CreateFont("FRF4_Tab", { font = "Sedgwick Ave Display", size = S(50), weight = 500, antialias = true })
surface.CreateFont("FRF4_JobTitle", { font = "Sedgwick Ave Display", size = S(60), weight = 500, antialias = true })
surface.CreateFont("FRF4_Price", { font = "Roboto", size = S(24), weight = 800, antialias = true })
surface.CreateFont("FRF4_Text", { font = "Roboto", size = S(20), weight = 500, antialias = true })
surface.CreateFont("FRF4_TextBold", { font = "Roboto", size = S(20), weight = 800, antialias = true })
surface.CreateFont("FRF4_Button", { font = "Sedgwick Ave Display", size = S(35), weight = 500, antialias = true })

local col = {
    bg      = Color(50, 50, 55, 100),
    om      = Color(45, 170, 225),
    gold    = Color(255, 198, 64),
    white   = Color(238, 242, 248),
    dim     = Color(155, 180, 205),
    row     = Color(30, 30, 35, 150),
    rowAlt  = Color(40, 40, 45, 150),
    btn     = Color(30, 30, 35, 200),
    btnHover= Color(45, 170, 225, 150),
    btnGold = Color(255, 198, 64, 150)
}

local matGrad = Material("vgui/gradient-d")
local logo = Material("fr_hud/logo_marseille_final.png", "smooth mips")
local hasLogo = logo and not logo:IsError()

local f4Panel

local function PopulateJobs(parent, w, h)
    local ShowJobList
    local ShowJobDetails

    ShowJobDetails = function(job, teamId)
        parent:Clear()
        if IsValid(f4Panel.searchBar) then f4Panel.searchBar:SetVisible(false) end

        local models = type(job.model) == "table" and job.model or {job.model}
        local currentModelIndex = 1

        local btnBack = vgui.Create("DButton", parent)
        btnBack:SetPos(0, 0)
        btnBack:SetSize(S(150), S(45))
        btnBack:SetText("")
        btnBack.Paint = function(self, pw, ph)
            local hover = self:IsHovered()
            draw.RoundedBox(S(6), 0, 0, pw, ph, hover and col.btnGold or col.btn)
            draw.RoundedBox(S(6), S(2), S(2), pw - S(4), ph - S(4), col.bg)
            draw.SimpleText("◄  RETOUR", "FRF4_TextBold", pw/2, ph/2, col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        btnBack.DoClick = function()
            ShowJobList(IsValid(f4Panel.searchBar) and f4Panel.searchBar:GetValue() or "")
        end

        local mdl = vgui.Create("DModelPanel", parent)
        mdl:SetPos(0, S(60))
        mdl:SetSize(S(350), h - S(140))
        mdl:SetModel(models[currentModelIndex] or "models/error.mdl")
        mdl:SetFOV(35)
        
        local camZ = 35
        local isDragging = false
        local dragX = 0
        local curAngle = 0
        
        mdl.OnMousePressed = function(self, key)
            if key == MOUSE_LEFT then
                isDragging = true
                dragX = gui.MousePos()
                self:MouseCapture(true)
            end
        end
        mdl.OnMouseReleased = function(self, key)
            if key == MOUSE_LEFT then
                isDragging = false
                self:MouseCapture(false)
            end
        end

        mdl:SetCamPos(Vector(110, 0, camZ))
        mdl:SetLookAt(Vector(0, 0, camZ))
        
        mdl.LayoutEntity = function(self, ent)
            if isDragging then
                local mx = gui.MousePos()
                curAngle = curAngle + (mx - dragX) * 0.5
                dragX = mx
            else
                curAngle = curAngle + FrameTime() * 20
            end
            ent:SetAngles(Angle(0, curAngle, 0))
        end

        if #models > 1 then
            local btnPrev = vgui.Create("DButton", parent)
            btnPrev:SetPos(S(20), h - S(60))
            btnPrev:SetSize(S(140), S(45))
            btnPrev:SetText("")
            btnPrev.Paint = function(self, pw, ph)
                local hover = self:IsHovered()
                draw.RoundedBox(S(6), 0, 0, pw, ph, hover and col.btnGold or col.btn)
                draw.RoundedBox(S(6), S(2), S(2), pw - S(4), ph - S(4), col.bg)
                draw.SimpleText("◄  SKIN", "FRF4_TextBold", pw/2, ph/2, col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            btnPrev.DoClick = function()
                currentModelIndex = currentModelIndex - 1
                if currentModelIndex < 1 then currentModelIndex = #models end
                mdl:SetModel(models[currentModelIndex])
            end

            local btnNext = vgui.Create("DButton", parent)
            btnNext:SetPos(S(190), h - S(60))
            btnNext:SetSize(S(140), S(45))
            btnNext:SetText("")
            btnNext.Paint = function(self, pw, ph)
                local hover = self:IsHovered()
                draw.RoundedBox(S(6), 0, 0, pw, ph, hover and col.btnGold or col.btn)
                draw.RoundedBox(S(6), S(2), S(2), pw - S(4), ph - S(4), col.bg)
                draw.SimpleText("SKIN  ►", "FRF4_TextBold", pw/2, ph/2, col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            btnNext.DoClick = function()
                currentModelIndex = currentModelIndex + 1
                if currentModelIndex > #models then currentModelIndex = 1 end
                mdl:SetModel(models[currentModelIndex])
            end
        end

        local infoX = S(380)
        local infoW = w - infoX

        local pnlInfo = vgui.Create("DPanel", parent)
        pnlInfo:SetPos(infoX, 0)
        pnlInfo:SetSize(infoW, h - S(80))
        pnlInfo.Paint = function(self, pw, ph)
            draw.RoundedBox(S(8), 0, 0, pw, ph, col.row)
            draw.RoundedBoxEx(S(8), 0, 0, S(6), ph, col.gold, true, false, true, false)

            draw.SimpleText(job.name, "FRF4_JobTitle", S(20), S(10), col.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            
            draw.SimpleText("Salaire : " .. (job.salary or 0) .. " €", "FRF4_TextBold", S(20), S(75), col.gold, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local limit = job.max == 0 and "Illimité" or job.max
            local current = team.NumPlayers(teamId)
            draw.SimpleText("Places : " .. current .. " / " .. limit, "FRF4_TextBold", S(200), S(75), col.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            draw.RoundedBox(0, S(20), S(110), pw - S(40), S(2), Color(255,255,255,10))
            
            draw.SimpleText("Armes fournies :", "FRF4_TextBold", S(20), S(130), col.om, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local weapStr = "Aucune"
        if job.weapons and #job.weapons > 0 then
            local weaps = {}
            for _, v in ipairs(job.weapons) do
                local wepTable = weapons.Get(v)
                table.insert(weaps, wepTable and wepTable.PrintName or v)
            end
            weapStr = table.concat(weaps, ", ")
        end

        local weapLbl = vgui.Create("DLabel", pnlInfo)
        weapLbl:SetPos(S(20), S(160))
        weapLbl:SetSize(infoW - S(40), S(40))
        weapLbl:SetFont("FRF4_Text")
        weapLbl:SetTextColor(col.white)
        weapLbl:SetWrap(true)
        weapLbl:SetText(weapStr)

        local descLblHeader = vgui.Create("DLabel", pnlInfo)
        descLblHeader:SetPos(S(20), S(210))
        descLblHeader:SetFont("FRF4_TextBold")
        descLblHeader:SetTextColor(col.om)
        descLblHeader:SetText("Description & Règles :")
        descLblHeader:SizeToContents()

        local scrollDesc = vgui.Create("DScrollPanel", pnlInfo)
        scrollDesc:SetPos(S(20), S(240))
        scrollDesc:SetSize(infoW - S(40), pnlInfo:GetTall() - S(260))
        
        local sbarD = scrollDesc:GetVBar()
        sbarD:SetWide(S(6))
        sbarD:SetHideButtons(true)
        sbarD.Paint = function(self, bw, bh) draw.RoundedBox(S(3), 0, 0, bw, bh, Color(0,0,0,50)) end
        sbarD.btnGrip.Paint = function(self, bw, bh) draw.RoundedBox(S(3), 0, 0, bw, bh, col.om) end

        local descText = vgui.Create("DLabel", scrollDesc)
        descText:SetFont("FRF4_Text")
        descText:SetTextColor(col.white)
        descText:SetWrap(true)
        descText:SetAutoStretchVertical(true)
        descText:SetText(job.description or "Aucune description disponible pour ce métier.")
        descText:SetWidth(scrollDesc:GetWide() - S(15))

        local btnChoose = vgui.Create("DButton", parent)
        btnChoose:SetPos(infoX, h - S(60))
        btnChoose:SetSize(infoW, S(60))
        btnChoose:SetText("")
        btnChoose.Paint = function(self, pw, ph)
            local hover = self:IsHovered()
            draw.RoundedBox(S(8), 0, 0, pw, ph, hover and col.btnGold or col.btnHover)
            draw.RoundedBox(S(8), S(2), S(2), pw - S(4), ph - S(4), col.bg)
            draw.SimpleText("POSTULER", "FRF4_JobTitle", pw/2, ph/2 - S(5), col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        btnChoose.DoClick = function()
            if DarkRP and DarkRP.setPreferredJobModel then
                DarkRP.setPreferredJobModel(teamId, models[currentModelIndex])
            end
            RunConsoleCommand("darkrp", job.command)
            if IsValid(f4Panel) then f4Panel:Remove() end
        end
    end

    ShowJobList = function(filter)
        parent:Clear()
        if IsValid(f4Panel.searchBar) then f4Panel.searchBar:SetVisible(true) end

        local scroll = vgui.Create("DScrollPanel", parent)
        scroll:SetPos(0, 0)
        scroll:SetSize(w, h)

        local sbar = scroll:GetVBar()
        sbar:SetWide(S(8))
        sbar:SetHideButtons(true)
        sbar.Paint = function(self, bw, bh) draw.RoundedBox(S(4), 0, 0, bw, bh, Color(0,0,0,50)) end
        sbar.btnGrip.Paint = function(self, bw, bh) draw.RoundedBox(S(4), 0, 0, bw, bh, col.om) end

        local layout = vgui.Create("DIconLayout", scroll)
        layout:Dock(FILL)
        layout:SetSpaceX(S(15))
        layout:SetSpaceY(S(15))

        filter = filter and string.lower(filter) or ""

        local jobList = RPExtraTeams or {}
        local sortedJobs = {}
        for k, v in pairs(jobList) do
            table.insert(sortedJobs, {id = k, job = v})
        end
        table.sort(sortedJobs, function(a, b)
            local catA = a.job.category or "Autres"
            local catB = b.job.category or "Autres"
            if catA == catB then return a.job.name < b.job.name end
            return catA < catB
        end)

        local itemW = w - S(30)
        local currentCat = nil

        for _, v in ipairs(sortedJobs) do
            local job = v.job
            if job.customCheck and not job.customCheck(LocalPlayer()) then continue end
            if filter ~= "" and not string.find(string.lower(job.name), filter, 1, true) then continue end

            local catName = job.category or "Autres"
            if catName ~= currentCat then
                currentCat = catName
                
                local catHeader = layout:Add("DPanel")
                catHeader:SetSize(w - S(30), S(60))
                catHeader.Paint = function(self, pw, ph)
                    draw.SimpleText(string.upper(catName), "FRF4_JobTitle", S(10), ph/2 - S(5), col.gold, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.RoundedBox(0, 0, ph - S(2), pw, S(2), Color(255, 198, 64, 100))
                end
            end

            local pnl = layout:Add("DPanel")
            pnl:SetSize(itemW, S(120))
            pnl.Paint = function(self, pw, ph)
                draw.RoundedBox(S(8), 0, 0, pw, ph, col.row)
                
                -- Liseré à gauche (toujours or)
                draw.RoundedBoxEx(S(8), 0, 0, S(6), ph, col.gold, true, false, true, false)

                draw.SimpleText(job.name, "FRF4_JobTitle", S(95), S(10), col.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText("Salaire: " .. (job.salary or 0) .. " €", "FRF4_Text", S(95), S(60), col.gold, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                
                local limit = job.max == 0 and "Illimité" or job.max
                local current = team.NumPlayers(v.id)
                draw.SimpleText("Places: " .. current .. " / " .. limit, "FRF4_Text", S(95), S(85), col.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end

            local mdl = vgui.Create("DModelPanel", pnl)
            mdl:SetPos(S(15), S(10))
            mdl:SetSize(S(70), S(100))
            local modelName = type(job.model) == "table" and job.model[1] or job.model
            mdl:SetModel(modelName or "models/player/Group01/male_01.mdl")
            
            if IsValid(mdl.Entity) then
                local head = mdl.Entity:LookupBone("ValveBiped.Bip01_Head1")
                if head then
                    local headpos = mdl.Entity:GetBonePosition(head)
                    mdl:SetLookAt(headpos)
                    mdl:SetCamPos(headpos - Vector(-20, 0, 0))
                else
                    mdl:SetCamPos(Vector(20, 0, 60))
                    mdl:SetLookAt(Vector(0, 0, 60))
                end
            end
            function mdl:LayoutEntity(ent) return end

            local btnDetail = vgui.Create("DButton", pnl)
            btnDetail:SetPos(itemW - S(330), S(30))
            btnDetail:SetSize(S(150), S(60))
            btnDetail:SetText("")
            btnDetail.Paint = function(self, pw, ph)
                local isHovered = self:IsHovered()
                draw.RoundedBox(S(6), 0, 0, pw, ph, isHovered and col.btnGold or col.btn)
                draw.RoundedBox(S(6), S(2), S(2), pw - S(4), ph - S(4), col.bg)
                draw.SimpleText("INFOS", "FRF4_JobTitle", pw/2, ph/2 - S(5), col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            btnDetail.DoClick = function()
                ShowJobDetails(job, v.id)
            end

            local btnChoose = vgui.Create("DButton", pnl)
            btnChoose:SetPos(itemW - S(170), S(30))
            btnChoose:SetSize(S(150), S(60))
            btnChoose:SetText("")
            btnChoose.Paint = function(self, pw, ph)
                local isHovered = self:IsHovered()
                draw.RoundedBox(S(6), 0, 0, pw, ph, isHovered and col.btnGold or col.btnHover)
                draw.RoundedBox(S(6), S(2), S(2), pw - S(4), ph - S(4), col.bg)
                draw.SimpleText("POSTULER", "FRF4_JobTitle", pw/2, ph/2 - S(5), col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            btnChoose.DoClick = function()
                RunConsoleCommand("darkrp", job.command)
                if IsValid(f4Panel) then f4Panel:Remove() end
            end
        end
    end

    if IsValid(f4Panel) and IsValid(f4Panel.searchBar) then
        f4Panel.searchBar.OnChange = function(self)
            ShowJobList(self:GetValue())
        end
        ShowJobList(f4Panel.searchBar:GetValue())
    else
        ShowJobList("")
    end
end

local function PopulateEntities(parent, w, h, listData, isWeapon)
    local scroll = vgui.Create("DScrollPanel", parent)
    scroll:SetPos(0, 0)
    scroll:SetSize(w, h)

    local sbar = scroll:GetVBar()
    sbar:SetWide(S(8))
    sbar:SetHideButtons(true)
    sbar.Paint = function(self, bw, bh) draw.RoundedBox(S(4), 0, 0, bw, bh, Color(0,0,0,50)) end
    sbar.btnGrip.Paint = function(self, bw, bh) draw.RoundedBox(S(4), 0, 0, bw, bh, col.om) end

    local layout = vgui.Create("DIconLayout", scroll)
    layout:Dock(FILL)
    layout:SetSpaceX(S(15))
    layout:SetSpaceY(S(15))

    local function LoadItems(filter)
        layout:Clear()
        filter = filter and string.lower(filter) or ""

        local itemW = (w - S(45)) / 4

        local sortedItems = {}
        for _, ent in ipairs(listData or {}) do
            table.insert(sortedItems, ent)
        end
        table.sort(sortedItems, function(a, b)
            local catA = a.category or "Autres"
            local catB = b.category or "Autres"
            if catA == catB then return a.name < b.name end
            return catA < catB
        end)

        local currentCat = nil

        for _, ent in ipairs(sortedItems) do
            if ent.allowed and not table.HasValue(ent.allowed, LocalPlayer():Team()) then continue end
            if ent.customCheck and not ent.customCheck(LocalPlayer()) then continue end
            if filter ~= "" and not string.find(string.lower(ent.name), filter, 1, true) then continue end

            local catName = ent.category or "Autres"
            if catName ~= currentCat then
                currentCat = catName
                
                local catHeader = layout:Add("DPanel")
                catHeader:SetSize(w - S(30), S(60))
                catHeader.Paint = function(self, pw, ph)
                    draw.SimpleText(string.upper(catName), "FRF4_JobTitle", S(10), ph/2 - S(5), col.gold, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.RoundedBox(0, 0, ph - S(2), pw, S(2), Color(255, 198, 64, 100))
                end
            end

            local pnl = layout:Add("DPanel")
            pnl:SetSize(itemW, S(160))
            pnl.Paint = function(self, pw, ph)
                draw.RoundedBox(S(8), 0, 0, pw, ph, col.row)
                
                local displayName = ent.name
                if ent.isShipment and ent.amount and ent.amount > 1 then
                    displayName = displayName .. " [x" .. ent.amount .. "]"
                end
                
                local dPrice = ent.price or 0
                if type(ent.getPrice) == "function" then
                    dPrice = ent.getPrice(LocalPlayer(), dPrice)
                end
                
                draw.SimpleText(displayName, "FRF4_TextBold", pw/2, S(10), col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText(dPrice .. " €", "FRF4_Price", pw/2, ph - S(45), col.gold, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end

            local icon = vgui.Create("SpawnIcon", pnl)
            icon:SetPos(itemW/2 - S(32), S(35))
            icon:SetSize(S(64), S(64))
            icon:SetModel(ent.model or "models/error.mdl")
            icon:SetTooltip(ent.name)
            
            local btn = vgui.Create("DButton", pnl)
            btn:SetPos(0, 0)
            btn:SetSize(itemW, S(160))
            btn:SetText("")
            btn.Paint = function(self, pw, ph)
                if self:IsHovered() then
                    draw.RoundedBox(S(8), 0, 0, pw, ph, Color(255, 198, 64, 15)) -- Highlight jaune/or très transparent
                end
            end
            btn.DoClick = function()
                if ent.buyCmd == "buy" or ent.buyCmd == "buyshipment" then
                    RunConsoleCommand("darkrp", ent.buyCmd, ent.name)
                elseif ent.buyCmd then
                    RunConsoleCommand("darkrp", ent.buyCmd)
                elseif ent.cmd then
                    RunConsoleCommand("darkrp", ent.cmd)
                else
                    RunConsoleCommand("darkrp", "buy", ent.name)
                end
            end
        end
    end

    if IsValid(f4Panel) and IsValid(f4Panel.searchBar) then
        f4Panel.searchBar.OnChange = function(self)
            LoadItems(self:GetValue())
        end
        LoadItems(f4Panel.searchBar:GetValue())
    else
        LoadItems("")
    end
end

local function CreateF4Menu()
    if IsValid(f4Panel) then f4Panel:Remove() end

    local w, h = S(1200), S(700)
    
    f4Panel = vgui.Create("EditablePanel")
    f4Panel:SetSize(w, h)
    f4Panel:Center()
    f4Panel:MakePopup()
    f4Panel:SetKeyboardInputEnabled(true)

    f4Panel:SetAlpha(0)
    f4Panel:AlphaTo(255, 0.2, 0)

    -- On récupère la touche assignée à gm_showspare2 (F4 par défaut, ou M par ex)
    local bindKey = KEY_F4
    local bindStr = input.LookupBinding("gm_showspare2")
    if bindStr then
        local code = input.GetKeyCode(bindStr)
        if code and code > 0 then
            bindKey = code
        end
    end

    f4Panel.BindWasDown = true
    f4Panel.Think = function(self)
        if not input.IsKeyDown(bindKey) then
            self.BindWasDown = false
        end

        if input.IsKeyDown(bindKey) and not self.BindWasDown then
            self.BindWasDown = true
            self:Remove()
        end
    end

    f4Panel.Paint = function(self, pw, ph)
        local r = S(12)
        
        draw.RoundedBox(r, 0, 0, pw, ph, Color(col.om.r, col.om.g, col.om.b, 80))
        draw.RoundedBox(r - 1, S(2), S(2), pw - S(4), ph - S(4), Color(col.om.r, col.om.g, col.om.b, 40))
        
        draw.RoundedBox(r - 2, S(3), S(3), pw - S(6), ph - S(6), col.bg)
        
        render.ClearStencil()
        render.SetStencilEnable(true)
        render.SetStencilWriteMask(1)
        render.SetStencilTestMask(1)
        render.SetStencilReferenceValue(1)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        
        render.OverrideColorWriteEnable(true, false)
        draw.RoundedBox(r - 2, S(3), S(3), pw - S(6), ph - S(6), color_white)
        render.OverrideColorWriteEnable(false, false)
        
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation(STENCIL_KEEP)
        
        surface.SetMaterial(matGrad)
        surface.SetDrawColor(100, 200, 255, 25)
        surface.DrawTexturedRect(S(3), S(3), pw - S(6), ph - S(6))
        
        render.SetStencilEnable(false)
        render.ClearStencil()

        draw.SimpleText("MARSEILLE RP", "FRF4_Title", S(30), S(20), col.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Menu d'interactions", "FRF4_Text", S(32), S(75), col.gold, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        draw.RoundedBox(0, S(20), S(120), pw - S(40), S(2), Color(col.gold.r, col.gold.g, col.gold.b, 150))

        if hasLogo then
            local lSize = S(110)
            local lcx = pw - S(15)
            local lcy = S(10)
            local angle = -15

            DisableClipping(true)
            surface.SetMaterial(logo)
            surface.SetDrawColor(0, 0, 0, 110)
            surface.DrawTexturedRectRotated(lcx + 2, lcy + 2, lSize, lSize, angle)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRectRotated(lcx, lcy, lSize, lSize, angle)
            DisableClipping(false)
        end
    end

    local searchBar = vgui.Create("DTextEntry", f4Panel)
    searchBar:SetPos(w - S(330), S(70))
    searchBar:SetSize(S(250), S(40))
    searchBar:SetPlaceholderText("Rechercher...")
    searchBar:SetFont("FRF4_Text")
    searchBar:SetDrawLanguageID(false)
    searchBar.Paint = function(self, pw, ph)
        draw.RoundedBox(S(6), 0, 0, pw, ph, Color(30, 30, 35, 200))
        draw.RoundedBox(S(6), S(1), S(1), pw - S(2), ph - S(2), Color(50, 50, 55, 200))
        self:DrawTextEntryText(col.white, col.om, col.white)
        if self:GetValue() == "" and not self:HasFocus() then
            draw.SimpleText("Rechercher...", "FRF4_Text", S(10), ph/2, col.dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
    f4Panel.searchBar = searchBar

    local contentPanel = vgui.Create("DPanel", f4Panel)
    contentPanel:SetPos(S(250), S(140))
    contentPanel:SetSize(w - S(270), h - S(160))
    contentPanel.Paint = function() end

    local activeTabBtn = nil

    local function SwitchTab(btn, pnlFunc, data, isWeapon)
        if IsValid(activeTabBtn) then
            activeTabBtn.isActive = false
        end
        btn.isActive = true
        activeTabBtn = btn

        if IsValid(f4Panel.searchBar) then
            f4Panel.searchBar:SetValue("")
        end

        contentPanel:Clear()
        pnlFunc(contentPanel, contentPanel:GetWide(), contentPanel:GetTall(), data, isWeapon)
    end

    local navY = S(140)
    local function AddTab(name, iconChar, func, data, isWeapon)
        local btn = vgui.Create("DButton", f4Panel)
        btn:SetPos(S(20), navY)
        btn:SetSize(S(210), S(60))
        btn:SetText("")
        btn.isActive = false
        btn.Paint = function(self, pw, ph)
            local hover = self:IsHovered()
            local active = self.isActive

            if active or hover then
                draw.RoundedBox(S(6), 0, 0, pw, ph, col.rowAlt)
                draw.RoundedBoxEx(S(6), 0, 0, S(4), ph, col.om, true, false, true, false)
            end

            draw.SimpleText(name, "FRF4_Tab", S(20), ph/2, col.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        btn.DoClick = function()
            SwitchTab(btn, func, data, isWeapon)
        end

        if not activeTabBtn then
            SwitchTab(btn, func, data, isWeapon)
        end

        navY = navY + S(70)
        return btn
    end

    local function GetCombinedWeapons()
        local merged = {}
        for _, w in ipairs(CustomWeapons or {}) do 
            local item = {}
            for k,v in pairs(w) do item[k] = v end
            
            if item.pricesep then item.price = item.pricesep end
            item.amount = 1 
            item.isSingleWeapon = true
            item.buyCmd = w.cmd or "buy"
            table.insert(merged, item) 
        end
        for _, s in ipairs(CustomShipments or {}) do 
            local item = {}
            for k,v in pairs(s) do item[k] = v end
            
            item.isShipment = true
            item.buyCmd = s.cmd or "buyshipment"
            table.insert(merged, item) 
        end
        return merged
    end

    AddTab("MÉTIERS", "", PopulateJobs)
    AddTab("ENTITÉS", "", PopulateEntities, DarkRPEntities, false)
    AddTab("ARMES", "", PopulateEntities, GetCombinedWeapons(), true)

    local closeBtn = vgui.Create("DButton", f4Panel)
    closeBtn:SetPos(S(20), h - S(100))
    closeBtn:SetSize(S(210), S(60))
    closeBtn:SetText("")
    closeBtn.Paint = function(self, pw, ph)
        local hover = self:IsHovered()
        draw.RoundedBox(S(6), 0, 0, pw, ph, hover and Color(200, 50, 50, 150) or col.row)
        draw.SimpleText("FERMER", "FRF4_Tab", pw/2, ph/2, col.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        if IsValid(f4Panel) then f4Panel:Remove() end
    end
end

hook.Add("ShowSpare2", "FR_F4Menu_Override", function()
    if IsValid(f4Panel) then
        f4Panel:Remove()
    else
        CreateF4Menu()
    end
    return true -- Bloque l'exécution des autres hooks ShowSpare2 (dont celui de base de GMod/DarkRP)
end)

-- On supprime violemment les hooks par défaut de DarkRP une fois qu'ils ont été chargés
timer.Simple(1, function()
    hook.Remove("ShowSpare2", "DarkRP_Mod_F4Menu")
    hook.Remove("ShowSpare2", "F4Menu")
    hook.Remove("PlayerBindPress", "DarkRP_Mod_F4Menu")
    
    -- On remplace aussi la fonction native de DarkRP au cas où il forcerait l'ouverture
    if DarkRP and DarkRP.toggleF4Menu then
        DarkRP.toggleF4Menu = function()
            if IsValid(f4Panel) then
                f4Panel:Remove()
            else
                CreateF4Menu()
            end
        end
    end
end)

-- Au cas où DarkRP essaierait via son hook custom
hook.Add("F4MenuOpen", "FR_F4Menu_Override", function()
    if not IsValid(f4Panel) then
        CreateF4Menu()
    else
        f4Panel:Remove()
    end
    return false -- Bloque l'ouverture de l'original
end)
