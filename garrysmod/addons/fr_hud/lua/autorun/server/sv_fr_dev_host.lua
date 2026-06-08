--[[---------------------------------------------------------------------------
    DEV ONLY — auto-set le host d'un listen server en superadmin.
    Aucun effet sur un serveur dedicated (vrai serv prod) : IsListenServerHost()
    retourne false en dedicated. Safe a deployer.
---------------------------------------------------------------------------]]

hook.Add("PlayerInitialSpawn", "FRDev_AutoSuperAdmin", function(ply)
    if not ply:IsListenServerHost() then return end
    if ply:GetUserGroup() == "superadmin" then return end
    ply:SetUserGroup("superadmin")
end)
