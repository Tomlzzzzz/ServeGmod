--[[---------------------------------------------------------------------------
    Concession Marseille RP — serveur
    Achat / garage / fourrière.

    Etats vehicule (par joueur, par class) :
      garage    : rangé, sortie gratuite
      active    : runtime, spawné, possédé par joueur connecté
      abandoned : joueur s'est déconnecté avec véhicule sorti (pos sauvée)
                  → reconnect avant PoundDelay : respawn à la pos
                  → reconnect après PoundDelay : passe en pound
      pound     : confisqué, paiement requis pour récupérer (frais fourrière)
---------------------------------------------------------------------------]]

FRConcess = FRConcess or {}

-- Prix override (a remplir plus tard si besoin) : FRConcess.PriceOverride["jeep"] = 12000
FRConcess.PriceOverride = FRConcess.PriceOverride or {}

-- Prix par defaut selon categorie
FRConcess.PriceByCategory = {
    ["Cars"]            = 8000,
    ["Voitures"]        = 8000,
    ["Voiture"]         = 8000,
    ["Sport"]           = 25000,
    ["Sports"]          = 25000,
    ["SUV"]             = 12000,
    ["Truck"]           = 15000,
    ["Camion"]          = 15000,
    ["Bike"]            = 6000,
    ["Moto"]            = 6000,
    ["Boat"]            = 18000,
    ["Bateau"]          = 18000,
    ["Tank"]            = 50000,
    ["Military"]        = 50000,
    ["Plane"]           = 30000,
    ["Avion"]           = 30000,
    ["Helicopter"]      = 35000,
    ["Helico"]          = 35000,
    ["Helicoptere"]     = 35000,
}
FRConcess.DefaultPrice = 10000

-- Fourrière
FRConcess.PoundDelay       = 600    -- joueur OFFLINE : 10 min avant fourrière
FRConcess.InactivityDelay  = 10800  -- joueur ONLINE : véhicule statique 3h → fourrière
FRConcess.MoveThreshold    = 5      -- distance min (units) pour considérer "bouge" (5u évite les jitters physiques Source)
FRConcess.PoundFeeRatio    = 0.10   -- 10% du prix du véhicule
FRConcess.PoundFeeMin      = 500    -- frais minimum
FRConcess.TickInterval     = 30     -- save pos + check inactivité toutes les 30s
FRConcess.SellRatio        = 0.65   -- 65% du prix d'achat récupéré lors d'une vente

util.AddNetworkString("FRConcess_VehiclesList")
util.AddNetworkString("FRConcess_Buy")
util.AddNetworkString("FRConcess_Spawn")
util.AddNetworkString("FRConcess_Store")
util.AddNetworkString("FRConcess_PayPound")
util.AddNetworkString("FRConcess_Sell")
util.AddNetworkString("FRConcess_ActionSuccess")

-- précache du son locked + envoi du fichier aux clients
resource.AddSingleFile("sound/fr_concess/locked2.wav")
util.PrecacheSound("fr_concess/locked2.wav")

local DATA_DIR    = "fr_concess"
local OWNERS_DIR  = "fr_concess/owners"
local DATA_FILE   = DATA_DIR .. "/" .. game.GetMap() .. ".json"

local function isStaff(ply)
    return IsValid(ply) and (ply:IsSuperAdmin() or ply:IsAdmin())
end

local function ensureDirs()
    if not file.IsDir(DATA_DIR, "DATA")   then file.CreateDir(DATA_DIR)   end
    if not file.IsDir(OWNERS_DIR, "DATA") then file.CreateDir(OWNERS_DIR) end
end

--[[ ---------- NPCs (positions persistées) ---------- ]]

local function loadPositions()
    ensureDirs()
    local raw = file.Read(DATA_FILE, "DATA")
    if not raw then return {} end
    local ok, t = pcall(util.JSONToTable, raw)
    return (ok and istable(t)) and t or {}
end

local function savePositions(list)
    ensureDirs()
    file.Write(DATA_FILE, util.TableToJSON(list, true))
end

local function restoreNPCs()
    for _, entry in ipairs(loadPositions()) do
        local npc = ents.Create("fr_concess_dealer")
        if IsValid(npc) then
            npc:SetPos(Vector(entry.pos.x, entry.pos.y, entry.pos.z))
            npc:SetAngles(Angle(0, entry.yaw or 0, 0))
            npc:Spawn()
        end
    end
end

hook.Add("InitPostEntity", "FRConcess_Restore", function() timer.Simple(1, restoreNPCs) end)

--[[ ---------- Owners : achats + states ---------- ]]
--[[
    Format JSON par joueur (data/fr_concess/owners/<sid64>.json):
    {
      "vehicles": {
        "jeep":     { "state": "garage" },
        "jalopy":   { "state": "pound",     "abandoned_at": 1700000000 },
        "airboat":  { "state": "abandoned", "pos": {x,y,z}, "ang": {p,y,r}, "abandoned_at": 1700000000 }
      }
    }
    Migration auto depuis l'ancien format (tableau ["jeep","jalopy"]).
]]

local function ownerFile(sid) return OWNERS_DIR .. "/" .. sid .. ".json" end

local function loadOwner(sid)
    ensureDirs()
    local raw = file.Read(ownerFile(sid), "DATA")
    if not raw then return { vehicles = {} } end
    local ok, t = pcall(util.JSONToTable, raw)
    if not (ok and istable(t)) then return { vehicles = {} } end
    -- migration ancien format (array de strings)
    if t[1] and isstring(t[1]) then
        local migrated = { vehicles = {} }
        for _, class in ipairs(t) do
            migrated.vehicles[class] = { state = "garage" }
        end
        return migrated
    end
    t.vehicles = t.vehicles or {}
    return t
end

local function saveOwner(sid, data)
    ensureDirs()
    file.Write(ownerFile(sid), util.TableToJSON(data))
end

local function ownsVehicle(ply, class)
    return loadOwner(ply:SteamID64()).vehicles[class] ~= nil
end

local function grantVehicle(ply, class)
    local sid = ply:SteamID64()
    local data = loadOwner(sid)
    if not data.vehicles[class] then
        data.vehicles[class] = { state = "garage" }
        saveOwner(sid, data)
    end
end

local function setState(sid, class, newState, extra)
    local data = loadOwner(sid)
    local v = data.vehicles[class]
    if not v then return end
    v.state = newState
    if extra then
        for k, val in pairs(extra) do v[k] = val end
    end
    if newState == "garage" then
        v.pos = nil; v.ang = nil; v.abandoned_at = nil
    end
    saveOwner(sid, data)
end

local function getVehicleEntry(sid, class)
    return loadOwner(sid).vehicles[class]
end

--[[ ---------- Prix / argent ---------- ]]

local function getPrice(class, category)
    return FRConcess.PriceOverride[class] or FRConcess.PriceByCategory[category] or FRConcess.DefaultPrice
end

local function getPoundFee(class, category)
    local price = getPrice(class, category)
    return math.max(FRConcess.PoundFeeMin, math.floor(price * FRConcess.PoundFeeRatio))
end

local function notif(ply, isErr, msg)
    if DarkRP and DarkRP.notify then
        DarkRP.notify(ply, isErr and 1 or 0, 4, msg)
    else
        ply:ChatPrint("[Concession] " .. msg)
    end
end

local function getMoney(ply)
    if ply.getDarkRPVar then return ply:getDarkRPVar("money") or 0 end
    return math.huge
end

local function chargeMoney(ply, amount)
    if ply.addMoney then ply:addMoney(-amount) end
end

local function fmtMoney(n)
    if DarkRP and DarkRP.formatMoney then return DarkRP.formatMoney(n) end
    return tostring(n) .. " €"
end

--[[ ---------- Spawn vehicule ---------- ]]

local function findNearestNPC(pos, maxDist)
    maxDist = maxDist or 600
    local best, bestD = nil, maxDist
    for _, e in ipairs(ents.FindByClass("fr_concess_dealer")) do
        local d = e:GetPos():Distance(pos)
        if d < bestD then best, bestD = e, d end
    end
    return best
end

local function findSpawnPosNearNPC(npc)
    local fwd  = npc:GetForward()
    local base = npc:GetPos() + fwd * 200 + Vector(0, 0, 50)
    local tr = util.TraceLine({
        start  = base,
        endpos = base - Vector(0, 0, 300),
        filter = npc,
    })
    local ang = npc:GetAngles()
    ang.p = 0; ang.r = 0
    return tr.HitPos + Vector(0, 0, 20), ang
end

local function createVehicleEnt(class, pos, ang, ply)
    local vdata = list.Get("Vehicles")[class]
    if not vdata then return nil, "Véhicule introuvable" end
    local ent = ents.Create(vdata.Class)
    if not IsValid(ent) then return nil, "Spawn raté" end
    ent:SetModel(vdata.Model)
    ent:SetPos(pos)
    ent:SetAngles(ang)
    if vdata.KeyValues then
        for k, v in pairs(vdata.KeyValues) do ent:SetKeyValue(k, v) end
    end
    ent.VehicleTable        = vdata
    ent.VehicleName         = class
    ent.FRConcess_Owner     = IsValid(ply) and ply:SteamID64() or nil
    ent.FRConcess_OwnerName = IsValid(ply) and ply:Nick() or nil
    ent:Spawn()
    ent:Activate()

    if IsValid(ply) then
        -- DarkRP moderne : keysOwn() est LA méthode officielle qui fait tout :
        -- SID, CPPI, doorData.owner, updateDoorData (networking client), vehicle count
        if ent.keysOwn then
            ent:keysOwn(ply)
        end
        -- Compat / belt-and-suspenders pour addons qui lisent ces fields
        ent.Owner     = ply
        ent.OwnerName = ply:Nick()
        if ent.CPPISetOwner then ent:CPPISetOwner(ply) end
        -- Flag réseau pour cacher le HUD des clés DarkRP côté client (cf. cl_fr_concess.lua)
        ent:SetNWBool("FRConcess_IsManaged", true)
        -- Notif des autres addons (FAdmin, etc)
        hook.Run("PlayerSpawnedVehicle", ply, ent)
    end
    return ent
end

--[[ ---------- Prop protection manuel (fallback si pas de CPPI) ---------- ]]
-- Bloque les autres joueurs de toucher au véhicule via physgun, toolgun, gravgun, dégâts

local function isFRConcessVehicleOwnedBy(ent, ply)
    if not IsValid(ent) or not IsValid(ply) then return false end
    if not ent.FRConcess_Owner then return false end
    return ent.FRConcess_Owner == ply:SteamID64() or ply:IsSuperAdmin()
end

hook.Add("PhysgunPickup", "FRConcess_PhysgunPickup", function(ply, ent)
    if ent.FRConcess_Owner then
        return isFRConcessVehicleOwnedBy(ent, ply)
    end
end)

hook.Add("CanTool", "FRConcess_CanTool", function(ply, tr, mode)
    local ent = tr.Entity
    if IsValid(ent) and ent.FRConcess_Owner then
        return isFRConcessVehicleOwnedBy(ent, ply)
    end
end)

hook.Add("CanProperty", "FRConcess_CanProperty", function(ply, prop, ent)
    if IsValid(ent) and ent.FRConcess_Owner then
        return isFRConcessVehicleOwnedBy(ent, ply)
    end
end)

hook.Add("GravGunPickupAllowed", "FRConcess_GravGunPickup", function(ply, ent)
    if IsValid(ent) and ent.FRConcess_Owner then
        return isFRConcessVehicleOwnedBy(ent, ply)
    end
end)

-- bloque l'entrée du véhicule + son "locked" si pas owner (cooldown par véhicule)
local nextNonOwnerSound = {}
hook.Add("CanPlayerEnterVehicle", "FRConcess_EnterCheck", function(ply, veh)
    if not IsValid(veh) or not veh.FRConcess_Owner then return end
    if not isFRConcessVehicleOwnedBy(veh, ply) then
        local key = ply:EntIndex() .. "_" .. veh:EntIndex()
        if (nextNonOwnerSound[key] or 0) <= CurTime() then
            nextNonOwnerSound[key] = CurTime() + (SoundDuration("fr_concess/locked2.wav") or 1)
            veh:EmitSound("fr_concess/locked2.wav", 70, 100, 1, CHAN_AUTO)
            if DarkRP and DarkRP.notify then
                DarkRP.notify(ply, 1, 3, "Ce véhicule est verrouillé.")
            end
        end
        return false
    end
end)

-- son "locked" quand le owner tente d'entrer dans son véhicule mais qu'il est lock
-- On utilise notre flag FRConcess_Locked (set par canKeysLock/canKeysUnlock plus haut)
local nextLockedSound  = {}
local LOCKED_SOUND     = "fr_concess/locked2.wav"
local LOCKED_DURATION  = SoundDuration(LOCKED_SOUND)
if not LOCKED_DURATION or LOCKED_DURATION <= 0 then LOCKED_DURATION = 1 end  -- fallback

hook.Add("PlayerUse", "FRConcess_LockedFeedback", function(ply, ent)
    if not IsValid(ent) or not ent.FRConcess_Owner then return end
    if not ent:IsVehicle() then return end
    if not ent.FRConcess_Locked then return end

    -- cooldown = durée réelle du son (pas d'empilage)
    local key = ply:EntIndex() .. "_" .. ent:EntIndex()
    if (nextLockedSound[key] or 0) > CurTime() then return false end
    nextLockedSound[key] = CurTime() + LOCKED_DURATION

    ent:EmitSound(LOCKED_SOUND, 70, 100, 1, CHAN_AUTO)
    return false
end)

hook.Add("PlayerUse", "FRConcess_PlayerUse", function(ply, ent)
    -- bloque l'interaction E (toolgun pickup) sur le véhicule si autre joueur
    if IsValid(ent) and ent:IsVehicle() and ent.FRConcess_Owner then
        if not isFRConcessVehicleOwnedBy(ent, ply) then
            return false
        end
    end
end)

-- DarkRP : indique au système keys (F2/keys SWEP) que le véhicule est ownable par le owner
-- + track notre propre lock state (engine GetInternalVariable pas fiable selon vehicle script)
hook.Add("canKeysLock", "FRConcess_CanKeysLock", function(ply, ent)
    if IsValid(ent) and ent.FRConcess_Owner then
        local ok = isFRConcessVehicleOwnedBy(ent, ply)
        if ok then ent.FRConcess_Locked = true end
        return ok
    end
end)

hook.Add("canKeysUnlock", "FRConcess_CanKeysUnlock", function(ply, ent)
    if IsValid(ent) and ent.FRConcess_Owner then
        local ok = isFRConcessVehicleOwnedBy(ent, ply)
        if ok then ent.FRConcess_Locked = false end
        return ok
    end
end)

-- Empêche les dégâts au véhicule par d'autres joueurs (anti-griefing)
hook.Add("EntityTakeDamage", "FRConcess_NoDamageFromOthers", function(ent, dmg)
    if not IsValid(ent) or not ent.FRConcess_Owner then return end
    local atk = dmg:GetAttacker()
    if IsValid(atk) and atk:IsPlayer() and not isFRConcessVehicleOwnedBy(ent, atk) then
        return true  -- annule les dégâts
    end
end)

-- enregistre l'état "active" + pos + timestamp pour un véhicule (appelé au spawn initial)
local function persistActive(sid, class, ent)
    if not IsValid(ent) then return end
    local data = loadOwner(sid)
    if not data.vehicles[class] then return end
    local pos, ang = ent:GetPos(), ent:GetAngles()
    local v = data.vehicles[class]
    v.state         = "active"
    v.pos           = { x = pos.x, y = pos.y, z = pos.z }
    v.ang           = { p = ang.p, y = ang.y, r = ang.r }
    v.last_save     = os.time()
    v.last_move_at  = os.time()  -- reset compteur inactivité au spawn
    v.abandoned_at  = nil
    saveOwner(sid, data)
end

-- spawn devant le NPC le plus proche du joueur (utilisé pour SORTIR / ACHETER / récupération fourrière)
local function spawnAtNPC(ply, class)
    local npc = findNearestNPC(ply:GetPos())
    if not npc then return false, "Approche-toi du concessionnaire" end
    local pos, ang = findSpawnPosNearNPC(npc)
    local ent, err = createVehicleEnt(class, pos, ang, ply)
    if not ent then return false, err end
    ply.FRConcess_ActiveVehicle = ent
    persistActive(ply:SteamID64(), class, ent)  -- save initial
    return true
end

--[[ ---------- Save continu / reconnect / tick fourrière ---------- ]]
--[[
    Strategie : tant qu'un joueur a un véhicule actif, on save (pos + last_save) en
    continu toutes les TickInterval secondes. Ainsi, peu importe comment le joueur
    se déconnecte (ShutDown, crash, kick, fermeture brutale), la JSON contient
    toujours la dernière pos connue ET un timestamp. A la reconnexion on calcule
    delta = now - last_save :
      - delta < PoundDelay : respawn à la pos
      - delta > PoundDelay : passe en pound
]]

-- tick global : pour chaque joueur online avec véhicule actif :
--   1) save pos/timestamp (déco safe)
--   2) detect mouvement → reset last_move_at si le véhicule a bougé
--   3) check inactivité → si statique trop longtemps, fourrière auto
local function tickActiveVehicle(ply, ent)
    if not IsValid(ent) or not ent.VehicleName then return end
    local sid = ply:SteamID64()
    if not sid then return end

    local class = ent.VehicleName
    local data  = loadOwner(sid)
    local v     = data.vehicles[class]
    if not v then return end

    local curPos = ent:GetPos()
    local curAng = ent:GetAngles()

    -- detect mouvement
    local prevPos = v.pos and Vector(v.pos.x, v.pos.y, v.pos.z) or curPos
    if curPos:Distance(prevPos) > FRConcess.MoveThreshold then
        v.last_move_at = os.time()
    end
    v.last_move_at = v.last_move_at or os.time()

    -- check inactivité in-game
    if (os.time() - v.last_move_at) > FRConcess.InactivityDelay then
        v.state = "pound"
        v.pos = nil; v.ang = nil; v.last_save = nil; v.last_move_at = nil
        saveOwner(sid, data)
        ent:Remove()
        ply.FRConcess_ActiveVehicle = nil
        local hrs = FRConcess.InactivityDelay / 3600
        local label = (hrs >= 1) and (math.floor(hrs) .. "h") or (FRConcess.InactivityDelay .. "s")
        notif(ply, true, "Ton véhicule est parti à la fourrière (inactif depuis " .. label .. ").")
        print(string.format("[FR_Concess] inactivité fourrière : %s -> %s", ply:Nick(), class))
        return
    end

    -- save normal pos/ang/last_save
    v.state         = "active"
    v.pos           = { x = curPos.x, y = curPos.y, z = curPos.z }
    v.ang           = { p = curAng.p, y = curAng.y, r = curAng.r }
    v.last_save     = os.time()
    v.abandoned_at  = nil
    saveOwner(sid, data)
end

timer.Create("FRConcess_ActiveSaveTick", FRConcess.TickInterval, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        local ent = ply.FRConcess_ActiveVehicle
        if IsValid(ent) then
            tickActiveVehicle(ply, ent)
        end
    end
end)

-- monter dans le véhicule = reset compteur inactivité (RP scenes ok)
hook.Add("PlayerEnteredVehicle", "FRConcess_ResetInactivityOnEnter", function(ply, veh)
    if not IsValid(ply) or not IsValid(veh) then return end
    if veh ~= ply.FRConcess_ActiveVehicle then return end
    local sid = ply:SteamID64()
    if not sid or not veh.VehicleName then return end
    local data = loadOwner(sid)
    local v = data.vehicles[veh.VehicleName]
    if not v then return end
    v.last_move_at = os.time()
    saveOwner(sid, data)
end)

-- au reconnect : pour chaque véhicule state="active" en JSON (= laissé pendant
-- une session précédente), check delta et respawn ou pound
hook.Add("PlayerInitialSpawn", "FRConcess_RestoreOnConnect", function(ply)
    timer.Simple(3, function()
        if not IsValid(ply) then return end
        local sid = ply:SteamID64()
        local data = loadOwner(sid)
        local changed = false
        for class, v in pairs(data.vehicles) do
            if v.state == "active" and v.last_save and v.pos and v.ang then
                local delta = os.time() - v.last_save
                print(string.format("[FR_Concess] reconnect %s : restore '%s', delta=%ds, PoundDelay=%ds",
                    ply:Nick(), class, delta, FRConcess.PoundDelay))
                if delta > FRConcess.PoundDelay then
                    v.state = "pound"
                    v.pos = nil; v.ang = nil; v.last_save = nil
                    changed = true
                    notif(ply, true, "Ton véhicule '" .. class .. "' est parti à la fourrière.")
                elseif not IsValid(ply.FRConcess_ActiveVehicle) then
                    local pos = Vector(v.pos.x, v.pos.y, v.pos.z + 24)
                    local ang = Angle(v.ang.p, v.ang.y, v.ang.r)
                    local ent, err = createVehicleEnt(class, pos, ang, ply)
                    if IsValid(ent) then
                        ply.FRConcess_ActiveVehicle = ent
                        v.last_move_at = os.time()  -- reset compteur inactivité (joueur revient)
                        changed = true
                        notif(ply, false, "Ton véhicule a été retrouvé.")
                        print("[FR_Concess] respawn OK : " .. class)
                    else
                        notif(ply, true, "Echec du respawn (" .. (err or "?") .. ").")
                        print("[FR_Concess] respawn ECHEC : " .. tostring(err))
                    end
                end
            end
        end
        if changed then saveOwner(sid, data) end
    end)
end)

-- restore des NPCs au cas où le 1er joueur arrive avant InitPostEntity
hook.Add("PlayerInitialSpawn", "FRConcess_RestoreFirstNPC", function()
    if #ents.FindByClass("fr_concess_dealer") > 0 then return end
    timer.Simple(2, restoreNPCs)
end)

-- tick toutes les 30s : pour les véhicules state="active" dont le owner est offline
-- ET delta > PoundDelay → fourrière (sécurité si joueur ne se reconnecte jamais)
timer.Create("FRConcess_PoundTick", 30, 0, function()
    local files = file.Find(OWNERS_DIR .. "/*.json", "DATA")
    local onlineSids = {}
    for _, ply in ipairs(player.GetAll()) do
        local s = ply:SteamID64()
        if s then onlineSids[s] = true end
    end
    for _, fname in ipairs(files) do
        local sid = fname:gsub("%.json$", "")
        if not onlineSids[sid] then  -- skip joueurs online (le tick auto save les met à jour)
            local data = loadOwner(sid)
            local changed = false
            for class, v in pairs(data.vehicles) do
                if v.state == "active" and v.last_save then
                    if (os.time() - v.last_save) > FRConcess.PoundDelay then
                        v.state = "pound"
                        v.pos = nil; v.ang = nil; v.last_save = nil
                        changed = true
                    end
                end
            end
            if changed then saveOwner(sid, data) end
        end
    end
end)

--[[ ---------- Liste envoyée au client ---------- ]]

-- helper VIP check
local function isVIP(ply)
    if not IsValid(ply) then return false end
    local g = ply:GetUserGroup()
    return (FRConcess.VipGroups or {})[g] == true
end

-- helper : trouve l'entrée config d'une class (nil si pas dans la config)
local function findConfigEntry(class)
    for _, e in ipairs(FRConcess.VehiclesList or {}) do
        if e.class == class then return e end
    end
    return nil
end

local function getVehiclesList()
    local registered = list.Get("Vehicles") or {}
    local out = {}

    if FRConcess.VehiclesList and #FRConcess.VehiclesList > 0 then
        -- mode CONFIG : ordre + overrides définis par l'admin
        for _, entry in ipairs(FRConcess.VehiclesList) do
            local vdata = registered[entry.class]
            if vdata then
                local cat = entry.category or vdata.Category or "Divers"
                table.insert(out, {
                    class    = entry.class,
                    name     = entry.name  or vdata.Name or entry.class,
                    category = cat,
                    price    = entry.price or getPrice(entry.class, cat),
                    vip      = entry.vip == true,
                })
            end
        end
    else
        -- mode FALLBACK : tout, tri alphabétique
        for class, v in pairs(registered) do
            if isstring(class) and isstring(v.Name) then
                local cat = v.Category or "Divers"
                table.insert(out, {
                    class    = class,
                    name     = v.Name,
                    category = cat,
                    price    = getPrice(class, cat),
                    vip      = false,
                })
            end
        end
        table.sort(out, function(a, b)
            if a.category == b.category then return a.name < b.name end
            return a.category < b.category
        end)
    end

    return out
end

function FRConcess_SendList(ply, shouldOpen)
    if not IsValid(ply) then return end
    local activeClass = nil
    if IsValid(ply.FRConcess_ActiveVehicle) and ply.FRConcess_ActiveVehicle.VehicleName then
        activeClass = ply.FRConcess_ActiveVehicle.VehicleName
    end
    local ownerData = loadOwner(ply:SteamID64())
    local owned, states = {}, {}
    for class, v in pairs(ownerData.vehicles or {}) do
        table.insert(owned, class)
        states[class] = {
            state        = v.state or "garage",
            abandoned_at = v.abandoned_at,
        }
    end
    local data = {
        vehicles    = getVehiclesList(),
        owned       = owned,
        states      = states,
        money       = getMoney(ply),
        active      = activeClass,
        pound_ratio = FRConcess.PoundFeeRatio,
        pound_min   = FRConcess.PoundFeeMin,
        pound_delay = FRConcess.PoundDelay,
        sell_ratio  = FRConcess.SellRatio,
        server_time = os.time(),
        is_vip      = isVIP(ply),
        should_open = shouldOpen or false,  -- true = E sur NPC (ouvre), false = refresh seulement
    }
    local json = util.TableToJSON(data)
    net.Start("FRConcess_VehiclesList")
        net.WriteUInt(#json, 32)
        net.WriteData(json, #json)
    net.Send(ply)
end

--[[ ---------- Cooldown ---------- ]]

local function cooldownOK(ply, key, delay)
    local now = CurTime()
    ply[key] = ply[key] or 0
    if now < ply[key] then return false end
    ply[key] = now + delay
    return true
end

--[[ ---------- Achat / Sortir / Ranger / Fourrière ---------- ]]

net.Receive("FRConcess_Buy", function(_, ply)
    if not IsValid(ply) then return end
    if not cooldownOK(ply, "FRConcess_NextBuy", 1) then return end

    local class = net.ReadString()
    local vdata = list.Get("Vehicles")[class]
    if not vdata then return end

    if not findNearestNPC(ply:GetPos()) then
        notif(ply, true, "Tu n'es pas près d'un concessionnaire.")
        return
    end
    if ownsVehicle(ply, class) then
        notif(ply, true, "Tu possèdes déjà ce véhicule (voir MES VÉHICULES).")
        return
    end
    if IsValid(ply.FRConcess_ActiveVehicle) then
        notif(ply, true, "Range ton véhicule actuel avant d'en acheter un autre.")
        return
    end

    -- check VIP
    local cfgEntry = findConfigEntry(class)
    if cfgEntry and cfgEntry.vip and not isVIP(ply) then
        notif(ply, true, "Ce véhicule est réservé aux VIP.")
        return
    end

    -- prix : config override si défini, sinon catégorie
    local price = (cfgEntry and cfgEntry.price) or getPrice(class, vdata.Category or "Divers")
    if getMoney(ply) < price then
        notif(ply, true, "Pas assez d'argent. Prix : " .. fmtMoney(price))
        return
    end

    chargeMoney(ply, price)
    grantVehicle(ply, class)
    local ok, err = spawnAtNPC(ply, class)
    if ok then
        notif(ply, false, "Véhicule acheté et livré ! (-" .. fmtMoney(price) .. ")")
    else
        notif(ply, true, "Achat OK, mais spawn raté : " .. (err or "?") .. ". Va dans MES VÉHICULES.")
    end
    -- Notif animation client
    net.Start("FRConcess_ActionSuccess")
        net.WriteString("buy")
        net.WriteString(class)
        net.WriteUInt(price, 32)
    net.Send(ply)
    FRConcess_SendList(ply)
end)

net.Receive("FRConcess_Spawn", function(_, ply)
    if not IsValid(ply) then return end
    if not cooldownOK(ply, "FRConcess_NextSpawn", 1) then return end

    local class = net.ReadString()
    local entry = getVehicleEntry(ply:SteamID64(), class)
    if not entry then
        notif(ply, true, "Tu ne possèdes pas ce véhicule.")
        return
    end
    if entry.state == "pound" then
        notif(ply, true, "Ce véhicule est en fourrière. Paye les frais pour le récupérer.")
        return
    end
    if IsValid(ply.FRConcess_ActiveVehicle) then
        notif(ply, true, "Range ton véhicule actuel d'abord.")
        return
    end
    if not findNearestNPC(ply:GetPos()) then
        notif(ply, true, "Approche-toi du concessionnaire.")
        return
    end
    local ok, err = spawnAtNPC(ply, class)
    if ok then
        notif(ply, false, "Véhicule sorti du garage.")
    else
        notif(ply, true, err or "Erreur spawn")
    end
    FRConcess_SendList(ply)
end)

net.Receive("FRConcess_Store", function(_, ply)
    if not IsValid(ply) then return end
    if not cooldownOK(ply, "FRConcess_NextStore", 1) then return end

    local ent = ply.FRConcess_ActiveVehicle
    if not IsValid(ent) then
        notif(ply, true, "Tu n'as aucun véhicule sorti.")
        return
    end
    if not findNearestNPC(ent:GetPos()) then
        notif(ply, true, "Véhicule trop loin du concessionnaire. Ramène-le.")
        return
    end

    if ent.GetDriver then
        local drv = ent:GetDriver()
        if IsValid(drv) then drv:ExitVehicle() end
    end

    local vname = ent.VehicleName
    ent:Remove()
    ply.FRConcess_ActiveVehicle = nil
    if vname then setState(ply:SteamID64(), vname, "garage") end  -- clean JSON: vire pos/last_save
    notif(ply, false, "Véhicule rangé au garage.")
    FRConcess_SendList(ply)
end)

net.Receive("FRConcess_PayPound", function(_, ply)
    if not IsValid(ply) then return end
    if not cooldownOK(ply, "FRConcess_NextPound", 1) then return end

    local class = net.ReadString()
    local entry = getVehicleEntry(ply:SteamID64(), class)
    if not entry or entry.state ~= "pound" then
        notif(ply, true, "Ce véhicule n'est pas en fourrière.")
        return
    end
    if IsValid(ply.FRConcess_ActiveVehicle) then
        notif(ply, true, "Range ton véhicule actuel d'abord.")
        return
    end
    if not findNearestNPC(ply:GetPos()) then
        notif(ply, true, "Approche-toi du concessionnaire.")
        return
    end

    local vdata = list.Get("Vehicles")[class]
    if not vdata then notif(ply, true, "Véhicule introuvable."); return end
    local fee = getPoundFee(class, vdata.Category or "Divers")

    if getMoney(ply) < fee then
        notif(ply, true, "Pas assez d'argent pour la fourrière. Frais : " .. fmtMoney(fee))
        return
    end

    chargeMoney(ply, fee)
    setState(ply:SteamID64(), class, "garage")
    local ok, err = spawnAtNPC(ply, class)
    if ok then
        notif(ply, false, "Véhicule récupéré de la fourrière (-" .. fmtMoney(fee) .. ").")
    else
        notif(ply, true, "Paiement OK mais spawn raté : " .. (err or "?"))
    end
    FRConcess_SendList(ply)
end)

-- VENDRE un véhicule (récupère 50% du prix d'achat par défaut)
net.Receive("FRConcess_Sell", function(_, ply)
    if not IsValid(ply) then return end
    if not cooldownOK(ply, "FRConcess_NextSell", 1) then return end

    local class = net.ReadString()
    local sid   = ply:SteamID64()
    local entry = getVehicleEntry(sid, class)
    if not entry then
        notif(ply, true, "Tu ne possèdes pas ce véhicule.")
        return
    end
    if entry.state == "pound" then
        notif(ply, true, "Ce véhicule est en fourrière. Récupère-le d'abord pour le vendre.")
        return
    end

    local vdata = list.Get("Vehicles")[class]
    if not vdata then notif(ply, true, "Véhicule introuvable."); return end
    local cfgEntry  = findConfigEntry(class)
    local price     = (cfgEntry and cfgEntry.price) or getPrice(class, vdata.Category or "Divers")
    local sellPrice = math.floor(price * FRConcess.SellRatio)

    -- Si le véhicule est actif (sorti), on le despawn d'abord
    if IsValid(ply.FRConcess_ActiveVehicle) and ply.FRConcess_ActiveVehicle.VehicleName == class then
        local ent = ply.FRConcess_ActiveVehicle
        if ent.GetDriver then
            local drv = ent:GetDriver()
            if IsValid(drv) then drv:ExitVehicle() end
        end
        ent:Remove()
        ply.FRConcess_ActiveVehicle = nil
    end

    -- Retire de la liste possédée
    local data = loadOwner(sid)
    data.vehicles[class] = nil
    saveOwner(sid, data)

    -- Crédite le joueur
    if ply.addMoney then ply:addMoney(sellPrice) end
    notif(ply, false, "Véhicule vendu pour " .. fmtMoney(sellPrice) .. " (" .. math.floor(FRConcess.SellRatio * 100) .. "% du prix d'achat).")
    -- Notif animation client
    net.Start("FRConcess_ActionSuccess")
        net.WriteString("sell")
        net.WriteString(class)
        net.WriteUInt(sellPrice, 32)
    net.Send(ply)
    FRConcess_SendList(ply)
end)

--[[ ---------- Commandes admin ---------- ]]

hook.Add("PlayerSay", "FRConcess_AdminCmds", function(ply, text)
    if not isStaff(ply) then return end
    local cmd = string.lower(string.Trim(text or ""))

    -- liste tous les véhicules enregistrés et écrit un fichier config Lua prêt à utiliser
    if cmd == "!listvehicles" or cmd == "/listvehicles" then
        local registered = list.Get("Vehicles") or {}
        local entries = {}
        for class, v in pairs(registered) do
            if isstring(class) and isstring(v.Name) then
                table.insert(entries, { class = class, name = v.Name, category = v.Category or "Divers" })
            end
        end
        table.sort(entries, function(a, b)
            if a.category == b.category then return a.name < b.name end
            return a.category < b.category
        end)

        -- écrit un fichier Lua complet drop-in à la place de fr_concess_config.lua
        local lines = {}
        local function add(s) table.insert(lines, s) end

        add("--[[---------------------------------------------------------------------------")
        add("    Concession Marseille RP — CONFIG VÉHICULES (généré automatiquement)")
        add("    Généré le " .. os.date("%Y-%m-%d %H:%M:%S") .. " (" .. #entries .. " véhicules)")
        add("    ")
        add("    Edite les champs name / price / vip / category selon tes envies.")
        add("    L'ordre des entrées = ordre d'affichage dans le menu concess.")
        add("---------------------------------------------------------------------------]]")
        add("")
        add("FRConcess = FRConcess or {}")
        add("")
        add("FRConcess.VehiclesList = {")

        local lastCat = nil
        for _, e in ipairs(entries) do
            if e.category ~= lastCat then
                lastCat = e.category
                add("")
                add("    -- ============ " .. e.category .. " ============")
            end
            -- escape les guillemets dans le nom si présents
            local safeName = e.name:gsub('"', '\\"')
            add(string.format(
                '    { class = "%s", name = "%s", price = 10000, vip = false, category = "%s" },',
                e.class, safeName, e.category))
        end

        add("")
        add("}")
        add("")
        add("-- Groupes ULX/ULib considérés comme VIP")
        add("FRConcess.VipGroups = {")
        add('    ["vip"]         = true,')
        add('    ["premium"]     = true,')
        add('    ["donator"]     = true,')
        add('    ["donateur"]    = true,')
        add('    ["superadmin"]  = true,')
        add('    ["admin"]       = true,')
        add("}")

        local full = table.concat(lines, "\n")

        if not file.IsDir(DATA_DIR, "DATA") then file.CreateDir(DATA_DIR) end
        file.Write(DATA_DIR .. "/fr_concess_config_filled.lua", full)

        ply:ChatPrint("[Concession] " .. #entries .. " véhicules dumped. Fichier : garrysmod/data/fr_concess/fr_concess_config_filled.lua")
        return ""
    end

    if cmd == "!setconcess" or cmd == "/setconcess" then
        local tr  = ply:GetEyeTrace()
        local pos = tr.HitPos + tr.HitNormal * 5
        local yaw = ply:EyeAngles().y + 180
        local npc = ents.Create("fr_concess_dealer")
        if not IsValid(npc) then
            ply:ChatPrint("[Concession] ERREUR : entity fr_concess_dealer non enregistrée.")
            return ""
        end
        npc:SetPos(pos)
        npc:SetAngles(Angle(0, yaw, 0))
        npc:Spawn()
        local positions = loadPositions()
        table.insert(positions, { pos = { x = pos.x, y = pos.y, z = pos.z }, yaw = yaw })
        savePositions(positions)
        ply:ChatPrint("[Concession] NPC placé et sauvegardé (map " .. game.GetMap() .. ").")
        return ""
    end

    if cmd == "!removeconcess" or cmd == "/removeconcess" then
        local tr = ply:GetEyeTrace()
        local ent = tr.Entity
        if not IsValid(ent) or ent:GetClass() ~= "fr_concess_dealer" then
            ply:ChatPrint("[Concession] Regarde un NPC concessionnaire d'abord.")
            return ""
        end
        local target = ent:GetPos()
        ent:Remove()
        local positions = loadPositions()
        local bestIdx, bestDist = nil, 100
        for i, e in ipairs(positions) do
            local d = Vector(e.pos.x, e.pos.y, e.pos.z):Distance(target)
            if d < bestDist then bestDist = d; bestIdx = i end
        end
        if bestIdx then table.remove(positions, bestIdx) end
        savePositions(positions)
        ply:ChatPrint("[Concession] NPC supprimé.")
        return ""
    end
end)

print("[FR_Concess] serveur chargé (achat + garage + fourrière)")
