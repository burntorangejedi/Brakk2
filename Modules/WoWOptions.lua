-- WoWOptions Module
-- Manages WoW game settings

local addonName, addon = ...
local Brakk2 = LibStub("AceAddon-3.0"):GetAddon("Brakk2")
local WoWOptions = Brakk2:NewModule("WoWOptions", "AceEvent-3.0")
WoWOptions.editModeProfiles = {}

-- Default settings for this module
local defaults = {
    profile = {
        enforceSettings = true,
        autoLoot = true,
        assistedHighlight = true,
        cooldownManager = true,
        damageMeter = true,
        defaultEditModeProfile = nil, -- stores the selected EditMode profile ID
    }
}

function WoWOptions:OnInitialize()
    -- Merge defaults into main db
    self.db = Brakk2.db:RegisterNamespace("WoWOptions", defaults)
end

function WoWOptions:OnEnable()
    -- Register for PLAYER_ENTERING_WORLD to update settings
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        self:ApplySettings()
    end)

    -- Register for EDIT_MODE_LAYOUTS_UPDATED to update EditMode profiles
    self:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED", function()
        self:UpdateEditModeProfiles()
    end)

    -- Apply settings immediately if already in world
    if IsPlayerInWorld and IsPlayerInWorld() then
        self:ApplySettings()
    end
    -- Auto-apply EditMode profile if set
    self:ApplyEditModeProfile()
end

-- Update the cached list of EditMode profiles
function WoWOptions:UpdateEditModeProfiles()
    self.editModeProfiles = {}
    if C_EditMode and C_EditMode.GetLayouts then
        local layouts = C_EditMode.GetLayouts()
        if type(layouts) == "table" and type(layouts.layouts) == "table" then
            self.editModeProfiles = {}
            for i, layout in ipairs(layouts.layouts) do
                self.editModeProfiles[#self.editModeProfiles+1] = { id = i, name = layout.layoutName or ("Layout "..i) }
            end
        else
            print("[Brakk2] No layouts found or API returned nil.")
        end
    else
        print("[Brakk2] C_EditMode or GetLayouts not available.")
    end
    local reg = LibStub and LibStub("AceConfigRegistry-3.0", true)
    if reg then reg:NotifyChange("Brakk2") end
end

function WoWOptions:ApplySettings()
    if not Brakk2.db.profile.enabled then
        return
    end
    if not self.db.profile.enforceSettings then
        return
    end
    -- Auto-apply EditMode profile if set
    self:ApplyEditModeProfile()

    -- Auto Loot
    if self.db.profile.autoLoot then
        if not GetCVarBool("autoLootDefault") then
            SetCVar("autoLootDefault", "1")
            if Brakk2.Print then Brakk2:Print("Auto Loot |cFF00FF00enabled|r") else print(
                "Auto Loot |cFF00FF00enabled|r") end
        end
    end

    -- Assisted Highlight
    if self.db.profile.assistedHighlight then
        if not GetCVarBool("assistedCombatHighlight") then
            SetCVar("assistedCombatHighlight", "1")
            if Brakk2.Print then Brakk2:Print("Assisted Highlight |cFF00FF00enabled|r") else print(
                "Assisted Highlight |cFF00FF00enabled|r") end
        end
    end

    -- Enable Cooldown Manager
    if self.db.profile.cooldownManager then
        if not GetCVarBool("cooldownViewerEnabled") then
            SetCVar("cooldownViewerEnabled", "1")
            if Brakk2.Print then Brakk2:Print("Cooldown Manager |cFF00FF00enabled|r") else print(
                "Cooldown Manager |cFF00FF00enabled|r") end
        end
    end

    -- Enable Damage Meter
    if self.db.profile.damageMeter then
        if not GetCVarBool("damageMeterEnabled") then
            SetCVar("damageMeterEnabled", "1")
            if Brakk2.Print then Brakk2:Print("Damage Meter |cFF00FF00enabled|r") else print(
                "Damage Meter |cFF00FF00enabled|r") end
        end
    end
end

function WoWOptions:GetEditModeProfiles()
    -- Always return the cached list
    return self.editModeProfiles or {}
end

function WoWOptions:ApplyEditModeProfile()
    local profileID = self.db.profile.defaultEditModeProfile
    if type(profileID) ~= "number" then
        profileID = tonumber(profileID)
    end
    if not profileID or type(profileID) ~= "number" or profileID < 0 or profileID > 4294967295 then
        print("Brakk2: Invalid EditMode profile ID. Please select a valid profile from the dropdown after opening Edit Mode.")
        return
    end
    if C_EditMode and C_EditMode.SetActiveLayout and C_EditMode.GetLayouts then
        local layouts = C_EditMode.GetLayouts()
        local apiIndex = profileID + 2
        print("[Brakk2] Attempting to set active layout to:", apiIndex)
        if type(layouts) == "table" then
            print("[Brakk2] Current layouts:")
            for i, layout in ipairs(layouts.layouts or {}) do
                print(string.format("  %d: %s", i, layout.layoutName or "(no name)"))
            end
            print("[Brakk2] activeLayout:", layouts.activeLayout)
        end
        C_EditMode.SetActiveLayout(apiIndex)
    end
end

-- Public method to manually apply settings
function WoWOptions:ForceApply()
    self:ApplySettings()
end
