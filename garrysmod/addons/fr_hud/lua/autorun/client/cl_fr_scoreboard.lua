--[[-------------------------------------------------------------------------
    SCOREBOARD (MENU TAB) - STYLE "FR HUD"
---------------------------------------------------------------------------]]

local s = ScrH() / 1080
local function S(val) return math.floor(val * s) end

surface.CreateFont("FRScore_Title", { font = "Sedgwick Ave Display", size = S(60), weight = 500, antialias = true })
surface.CreateFont("FRScore_Count", { font = "Sedgwick Ave Display", size = S(40), weight = 500, antialias = true })
surface.CreateFont("FRScore_Header", { font = "Sedgwick Ave Display", size = S(24), weight = 500, antialias = true })
surface.CreateFont("FRScore_Text", { font = "Roboto", size = S(22), weight = 500, antialias = true })
surface.CreateFont("FRScore_Job", { font = "Sedgwick Ave Display", size = S(60), weight = 500, antialias = true })

local col = {
    bg      = Color(50, 50, 55, 100),
    om      = Color(45, 170, 225),
    gold    = Color(255, 198, 64),
    white   = Color(238, 242, 248),
    dim     = Color(155, 180, 205),
    row     = Color(30, 30, 35, 150),
    rowAlt  = Color(40, 40, 45, 150)
}

local matGrad = Material("vgui/gradient-d")
local logo = Material("fr_hud/logo_marseille_final.png", "smooth mips")
local hasLogo = logo and not logo:IsError()

local scoreboardPanel

local function CreateScoreboard()
    if IsValid(scoreboardPanel) then scoreboardPanel:Remove() end

    local w, h = S(900), S(700)
    
    scoreboardPanel = vgui.Create("EditablePanel")
    scoreboardPanel:SetSize(w, h)
    scoreboardPanel:Center()
    scoreboardPanel:MakePopup()
    scoreboardPanel:SetKeyboardInputEnabled(false)

    -- Animation d'apparition
    scoreboardPanel:SetAlpha(0)
    scoreboardPanel:AlphaTo(255, 0.2, 0)

    scoreboardPanel.Paint = function(self, w, h)
        local r = S(12)
        
        -- Base transparente (contour)
        draw.RoundedBox(r, 0, 0, w, h, Color(col.om.r, col.om.g, col.om.b, 80))
        draw.RoundedBox(r - 1, S(2), S(2), w - S(4), h - S(4), Color(col.om.r, col.om.g, col.om.b, 40))
        
        -- Fond gris transparent
        draw.RoundedBox(r - 2, S(3), S(3), w - S(6), h - S(6), col.bg)
        
        -- Masque stencil pour le dégradé
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
        draw.RoundedBox(r - 2, S(3), S(3), w - S(6), h - S(6), color_white)
        render.OverrideColorWriteEnable(false, false)
        
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation(STENCIL_KEEP)
        
        surface.SetMaterial(matGrad)
        surface.SetDrawColor(100, 200, 255, 25)
        surface.DrawTexturedRect(S(3), S(3), w - S(6), h - S(6))
        
        render.SetStencilEnable(false)
        render.ClearStencil()

        -- Header : Titre et infos serveur
        draw.SimpleText("Marseille RP", "FRScore_Title", S(30), S(10), col.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(player.GetCount() .. " / " .. game.MaxPlayers() .. " Joueurs", "FRScore_Count", S(30), S(75), col.gold, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        -- Ligne de séparation (Jaune/Orange)
        draw.RoundedBox(0, S(20), S(120), w - S(40), S(2), Color(col.gold.r, col.gold.g, col.gold.b, 150))

        -- (Les colonnes "Joueur", "Métier", "Ping" ont été supprimées)

        -- Logo en haut à droite (qui déborde sur le coin, penché à droite)
        if hasLogo then
            local lSize = S(110) -- Plus gros
            local lcx = w - S(15) -- Déborde sur la droite
            local lcy = S(10)     -- Déborde sur le haut
            local angle = -15     -- Penché de l'autre côté

            DisableClipping(true) -- Permet de dessiner en dehors de la fenêtre (pour le débordement)

            surface.SetMaterial(logo)

            -- Ombre
            surface.SetDrawColor(0, 0, 0, 110)
            surface.DrawTexturedRectRotated(lcx + 2, lcy + 2, lSize, lSize, angle)
            
            -- Logo
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRectRotated(lcx, lcy, lSize, lSize, angle)

            DisableClipping(false)
        end
    end

    -- ScrollPanel pour la liste des joueurs
    local scroll = vgui.Create("DScrollPanel", scoreboardPanel)
    scroll:SetPos(S(20), S(135))
    scroll:SetSize(w - S(40), h - S(155))

    local sbar = scroll:GetVBar()
    sbar:SetWide(S(8))
    sbar:SetHideButtons(true)
    sbar.Paint = function(self, w, h) draw.RoundedBox(S(4), 0, 0, w, h, Color(0,0,0,50)) end
    sbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(S(4), 0, 0, w, h, col.om) end

    -- Barre de recherche
    local searchBar = vgui.Create("DTextEntry", scoreboardPanel)
    searchBar:SetPos(w - S(250), S(75))
    searchBar:SetSize(S(200), S(35))
    searchBar:SetPlaceholderText("Rechercher...")
    searchBar:SetFont("FRScore_Text")
    searchBar:SetDrawLanguageID(false) -- Enlever la petite case blanche "FR"
    
    -- Gérer le clic et forcer le focus avec un délai d'une frame (nécessaire car le parent bloque le clavier)
    searchBar.OnMousePressed = function(self, mousecode)
        if IsValid(scoreboardPanel) then
            scoreboardPanel:SetKeyboardInputEnabled(true)
            scoreboardPanel.isLocked = true -- Fige le TAB
        end
        
        timer.Simple(0, function()
            if IsValid(self) then
                self:RequestFocus()
            end
        end)
    end
    
    searchBar.OnLoseFocus = function(self)
        -- Redésactive le clavier quand on clique ailleurs, pour pouvoir marcher avec ZQSD, même si le menu est figé
        if IsValid(scoreboardPanel) then
            scoreboardPanel:SetKeyboardInputEnabled(false)
        end
    end

    searchBar.OnEnter = function(self)
        self:KillFocus()
        if IsValid(scoreboardPanel) then scoreboardPanel.isLocked = false end
        if not input.IsKeyDown(KEY_TAB) then
            hook.Run("ScoreboardHide")
        end
    end
    
    -- Peinture style HUD
    searchBar.Paint = function(self, pw, ph)
        draw.RoundedBox(S(6), 0, 0, pw, ph, Color(30, 30, 35, 200))
        draw.RoundedBox(S(6), S(1), S(1), pw - S(2), ph - S(2), Color(50, 50, 55, 200))
        self:DrawTextEntryText(col.white, col.om, col.white)
        
        -- Placeholder
        if self:GetValue() == "" and not self:HasFocus() then
            draw.SimpleText("Rechercher...", "FRScore_Text", S(10), ph/2, Color(155, 180, 205, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    -- Fonction de chargement des joueurs (avec filtre)
    local function LoadPlayers(filter)
        scroll:Clear()
        filter = filter and string.lower(filter) or ""

        local plys = player.GetAll()
        table.sort(plys, function(a, b)
            local teamA = a:Team() or 0
            local teamB = b:Team() or 0
            if teamA == teamB then return a:Nick() < b:Nick() end
            return teamA < teamB
        end)

        local alt = false
        for _, ply in ipairs(plys) do
            if not IsValid(ply) then continue end
            if filter ~= "" and not string.find(string.lower(ply:Nick()), filter, 1, true) then continue end

            local row = scroll:Add("DPanel")
            row:Dock(TOP)
            row:DockMargin(0, 0, S(10), S(5))
            row:SetTall(S(60))

            local bgColor = alt and col.rowAlt or col.row
            alt = not alt

            row.Paint = function(self, rw, rh)
                draw.RoundedBox(S(6), 0, 0, rw, rh, bgColor)
                draw.RoundedBoxEx(S(6), 0, 0, S(4), rh, col.gold, true, false, true, false)

                if not IsValid(ply) then return end

                draw.SimpleText(ply:Nick(), "FRScore_Text", S(80), rh/2, col.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                local jobName = ply:getDarkRPVar("job") or team.GetName(ply:Team()) or "Inconnu"
                draw.SimpleText(jobName, "FRScore_Job", rw / 2, rh/2 - S(14), col.gold, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                draw.SimpleText(ply:Ping() .. " ms", "FRScore_Text", rw - S(15), rh/2, col.dim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end

            local av = vgui.Create("AvatarImage", row)
            av:SetPos(S(10), S(5))
            av:SetSize(S(50), S(50))
            av:SetPlayer(ply, 64)
        end
    end

    searchBar.OnChange = function(self)
        LoadPlayers(self:GetValue())
    end

    LoadPlayers()
end

-- Remplacement du Tab original
hook.Add("ScoreboardShow", "FR_ScoreboardShow", function()
    if IsValid(scoreboardPanel) then
        -- Si le menu est figé (car on a cherché) et qu'on rappuie sur TAB, on le ferme comme un bouton toggle
        if scoreboardPanel.isLocked then
            scoreboardPanel.isLocked = false
            hook.Run("ScoreboardHide")
            return true
        end
        scoreboardPanel:Remove()
    end
    CreateScoreboard()
    return true -- Bloque l'ancien scoreboard (FAdmin/Sandbox)
end)

hook.Add("ScoreboardHide", "FR_ScoreboardHide", function()
    if IsValid(scoreboardPanel) then
        -- Si le menu a été figé, on REFUSE de le fermer quand la touche TAB est relâchée
        if scoreboardPanel.isLocked then return end

        local pnl = scoreboardPanel
        scoreboardPanel = nil -- Détacher la référence pour la prochaine ouverture
        pnl:AlphaTo(0, 0.1, 0, function()
            if IsValid(pnl) then pnl:Remove() end
        end)
    end
end)
