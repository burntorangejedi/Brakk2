local addonName, addon = ...
local Brakk2 = LibStub("AceAddon-3.0"):GetAddon("Brakk2")
local InstanceWatcher = Brakk2:NewModule("InstanceWatcher", "AceEvent-3.0")

local defaults = {
    profile = {
        enabled = true,
        lastInstanceType = "none",
    }
}

function InstanceWatcher:OnInitialize()
    self.db = Brakk2.db:RegisterNamespace("InstanceWatcher", defaults)
end

function InstanceWatcher:OnEnable()
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "CheckInstance")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "CheckInstance")
    self:CheckInstance()
end

function InstanceWatcher:OnDisable()
    self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

local function TryCombatLog()
    if type(RunMacroText) == "function" then
        RunMacroText("/combatlog")
        Brakk2:Print("Tried to enable combat logging with /combatlog macro.")
    else
        Brakk2:Print("|cffff0000Unable to enable combat logging automatically. Please type /combatlog manually.|r")
    end
end

function InstanceWatcher:CheckInstance()
    local name, instanceType = GetInstanceInfo()
    if instanceType ~= self.db.profile.lastInstanceType then
        self.db.profile.lastInstanceType = instanceType
        if self.db.profile.enabled then
            if instanceType == "party" then
                Brakk2:Print("You have entered a dungeon: " .. (name or ""))
                TryCombatLog()
            elseif instanceType == "raid" then
                Brakk2:Print("You have entered a raid: " .. (name or ""))
                TryCombatLog()
            elseif instanceType == "none" then
                Brakk2:Print("You have left an instance.")
            end
        end
    end
end

function InstanceWatcher:GetOptionsTable()
    return {
        name = "Instance Watcher",
        type = "group",
        order = 40,
        args = {
            enabled = {
                name = "Enable Instance Watcher",
                type = "toggle",
                set = function(info, val)
                    self.db.profile.enabled = val
                    if val then self:Enable() else self:Disable() end
                end,
                get = function(info) return self.db.profile.enabled end,
                order = 1,
            },
        },
    }
end
