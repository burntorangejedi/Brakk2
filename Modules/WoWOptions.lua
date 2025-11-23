-- WoWOptions Module
-- Manages WoW game settings

local addonName, addon = ...
local Brakk2 = LibStub("AceAddon-3.0"):GetAddon("Brakk2")
local WoWOptions = Brakk2:NewModule("WoWOptions", "AceEvent-3.0")

-- Default settings for this module
local defaults = {
    profile = {
        enforceSettings = true,
        autoLoot = true,
        assistedHighlight = true,
        cooldownManager = true,
        damageMeter = true,
    }
}

function WoWOptions:OnInitialize()
    -- Merge defaults into main db
    self.db = Brakk2.db:RegisterNamespace("WoWOptions", defaults)
end

function WoWOptions:OnEnable()
    -- Apply settings on login/reload
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "ApplySettings")

    -- Apply settings immediately if already in world
    if IsPlayerInWorld and IsPlayerInWorld() then
        self:ApplySettings()
    end
end

function WoWOptions:ApplySettings()
    if not Brakk2.db.profile.enabled then 
        return 
    end
    if not self.db.profile.enforceSettings then 
        return 
    end
    
    -- Auto Loot
    if self.db.profile.autoLoot then
        if not GetCVarBool("autoLootDefault") then
            SetCVar("autoLootDefault", "1")
            Brakk2:Print("Auto Loot |cFF00FF00enabled|r")
        end
    end
    
    -- Assisted Highlight
    if self.db.profile.assistedHighlight then
        if not GetCVarBool("assistedCombatHighlight") then
            SetCVar("assistedCombatHighlight", "1")
            Brakk2:Print("Assisted Highlight |cFF00FF00enabled|r")
        end
    end
    
    -- Enable Cooldown Manager
    if self.db.profile.cooldownManager then
        if not GetCVarBool("cooldownViewerEnabled") then
            SetCVar("cooldownViewerEnabled", "1")
            Brakk2:Print("Cooldown Manager |cFF00FF00enabled|r")
        end
    end
    
    -- Enable Damage Meter
    if self.db.profile.damageMeter then
        if not GetCVarBool("damageMeterEnabled") then
            SetCVar("damageMeterEnabled", "1")
            Brakk2:Print("Damage Meter |cFF00FF00enabled|r")
        end
    end
end

-- Public method to manually apply settings
function WoWOptions:ForceApply()
    self:ApplySettings()
end

-- Debug method to search for CVars
function WoWOptions:FindCVars()
    Brakk2:Print("Searching for correct CVars...")
    
    -- List of possible CVars for Assisted Highlight
    local assistedCVars = {
        "SoftTargetEnemy", "SoftTargetFriend", "SoftTargetInteract", 
        "SoftTargetIconGameObject", "SoftTargetNameplateEnemy",
        "SoftTargetNameplateFriend", "assistedTargeting"
    }
    
    Brakk2:Print("=== Assisted Highlight CVars ===")
    for _, cvar in ipairs(assistedCVars) do
        local value = GetCVar(cvar)
        if value then
            Brakk2:Print(cvar .. " = " .. tostring(value))
        end
    end
    
    -- List of possible CVars for Cooldown Manager
    local cooldownCVars = {
        "countdownForCooldowns", "alwaysShowActionBars", "spellActivationOverlayOpacity"
    }
    
    Brakk2:Print("=== Cooldown Manager CVars ===")
    for _, cvar in ipairs(cooldownCVars) do
        local value = GetCVar(cvar)
        if value then
            Brakk2:Print(cvar .. " = " .. tostring(value))
        end
    end
    
    -- List of possible CVars for Floating Combat Text / Damage Meter
    local fctCVars = {
        "floatingCombatTextCombatDamage", "floatingCombatTextCombatHealing",
        "enableFloatingCombatText", "CombatDamage", "CombatHealing"
    }
    
    Brakk2:Print("=== Damage Meter / FCT CVars ===")
    for _, cvar in ipairs(fctCVars) do
        local value = GetCVar(cvar)
        if value then
            Brakk2:Print(cvar .. " = " .. tostring(value))
        end
    end
end

