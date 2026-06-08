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
end)
