--[[---------------------------------------------------------------------------
    Client : reception /annonce et /ano -> chat.AddText (EasyChat rendu)
---------------------------------------------------------------------------]]

local COL_ANNONCE = Color(255, 222, 70)    -- jaune
local COL_ANO     = Color(235, 130, 130)   -- rouge clair lisible
local COL_TEXT    = Color(238, 242, 248)

net.Receive("FRChat_Annonce", function()
    local sender = net.ReadEntity()
    local msg    = net.ReadString()
    -- "<flash>ANNONCE<stop>" -> dans le ChatHUD le mot ANNONCE pulse pour
    -- attirer l'oeil (effet "BAM"). Le ChatBox affiche en couleur fixe.
    if IsValid(sender) then
        chat.AddText(
            sender,
            COL_TEXT,    " : ",
            COL_ANNONCE, "<flash>ANNONCE — " .. msg .. "<stop>"
        )
    else
        chat.AddText(COL_ANNONCE, "<flash>ANNONCE — " .. msg .. "<stop>")
    end
end)

net.Receive("FRChat_Anonyme", function()
    local msg = net.ReadString()
    chat.AddText(COL_ANO, "Anonyme : " .. msg)
    surface.PlaySound("common/talk.wav")
end)
