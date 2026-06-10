--[[---------------------------------------------------------------------------
    fr_concess_dealer — serveur
---------------------------------------------------------------------------]]

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local NPC_MODEL = "models/breen.mdl"

local function findIdleSequence(self)
    -- ACT_IDLE renvoie l'idle "recommandée" par le moteur pour ce modèle
    local seq = self:SelectWeightedSequence(ACT_IDLE)
    if seq and seq >= 0 then return seq end
    -- fallback : tente les noms courants
    for _, name in ipairs({ "idle_subtle", "Idle_Subtle", "idle_all_01", "idle_01", "idle", "Idle01" }) do
        local s = self:LookupSequence(name)
        if s and s >= 0 then return s end
    end
    return 0
end

-- force tous les flexes "blink/close" à 0 (les modèles HL2 sans IA ont les yeux fermés par défaut)
local function openEyes(self)
    local n = self:GetFlexNum()
    for i = 0, n - 1 do
        local name = (self:GetFlexName(i) or ""):lower()
        if name:find("blink") or name:find("close") or name:find("lid_lower") then
            self:SetFlexWeight(i, 0)
        end
    end
end

function ENT:Initialize()
    self:SetModel(NPC_MODEL)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionGroup(COLLISION_GROUP_NONE)
    self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 75))
    self:SetUseType(SIMPLE_USE)
    self:DrawShadow(true)
    self:SetAutomaticFrameAdvance(true)  -- CRUCIAL : sans ça, l'anim ne défile pas → T-pose

    local idle = findIdleSequence(self)
    self:ResetSequence(idle)
    self:SetCycle(math.Rand(0, 1))
    self:SetPlaybackRate(1)
    openEyes(self)  -- ouvre les yeux (flexes blink → 0)
    self.NextAnimReset = CurTime() + 10
    self.NextEyeRefresh = CurTime() + 0.5
end

function ENT:Think()
    -- relance la séquence idle si elle a été interrompue
    if CurTime() >= (self.NextAnimReset or 0) then
        self.NextAnimReset = CurTime() + 10
        local idle = findIdleSequence(self)
        if self:GetSequence() ~= idle then
            self:ResetSequence(idle)
            self:SetPlaybackRate(1)
        end
    end
    -- refresh yeux toutes les 0.5s (les anim faciales peuvent les refermer)
    if CurTime() >= (self.NextEyeRefresh or 0) then
        self.NextEyeRefresh = CurTime() + 0.5
        openEyes(self)
    end
    self:NextThink(CurTime() + 0.5)
    return true
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    activator.FRConcessLastUse = activator.FRConcessLastUse or 0
    if CurTime() < activator.FRConcessLastUse then return end
    activator.FRConcessLastUse = CurTime() + 0.5
    if FRConcess_SendList then FRConcess_SendList(activator, true) end  -- true = ouvre le menu
end

function ENT:OnTakeDamage() end
