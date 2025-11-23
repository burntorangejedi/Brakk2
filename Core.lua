-- Brakk2 Core
local addonName, addon = ...

-- Create addon namespace
Brakk2 = LibStub("AceAddon-3.0"):NewAddon("Brakk2", "AceConsole-3.0", "AceEvent-3.0")

-- Default settings
local defaults = {
    profile = {
        enabled = true,
    }
}

function Brakk2:OnInitialize()
    -- Initialize saved variables
    self.db = LibStub("AceDB-3.0"):New("Brakk2DB", defaults, true)
    
    -- Setup options
    self:SetupOptions()
    
    -- Register slash commands
    self:RegisterChatCommand("brakk2", "SlashCommand")
    
    print("|cFF00FF00Brakk2|r loaded successfully!")
end

function Brakk2:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Brakk2:OnDisable()
    -- Cleanup when disabled
end

-- Options Setup
function Brakk2:SetupOptions()
    local AceConfig = LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local AceDBOptions = LibStub("AceDBOptions-3.0")
    
    local options = {
        name = "Brakk2",
        type = "group",
        args = {
            general = {
                name = "General Settings",
                type = "group",
                order = 1,
                args = {
                    enabled = {
                        name = "Enable Addon",
                        desc = "Enable or disable the addon functionality",
                        type = "toggle",
                        set = function(info, val)
                            self.db.profile.enabled = val
                            if val then
                                self:Print("|cFF00FF00Enabled|r - Addon functionality is now active")
                            else
                                self:Print("|cFFFF0000Disabled|r - Addon functionality is now inactive")
                            end
                        end,
                        get = function(info) return self.db.profile.enabled end,
                        order = 1,
                    },
                    header = {
                        name = "About",
                        type = "header",
                        order = 2,
                    },
                    version = {
                        name = "Version 1.0.0",
                        type = "description",
                        order = 3,
                    },
                },
            },
            wowoptions = {
                name = "WoW Options",
                type = "group",
                order = 2,
                args = {
                    desc = {
                        name = "Automatically enforce specific WoW game settings when you log in.",
                        type = "description",
                        order = 0,
                    },
                    enforceSettings = {
                        name = "Enforce Settings",
                        desc = "Enable automatic enforcement of WoW settings",
                        type = "toggle",
                        set = function(info, val)
                            local mod = self:GetModule("WoWOptions")
                            mod.db.profile.enforceSettings = val
                        end,
                        get = function(info)
                            local mod = self:GetModule("WoWOptions")
                            return mod.db.profile.enforceSettings
                        end,
                        width = "full",
                        order = 1,
                    },
                    autoLoot = {
                        name = "Auto Loot",
                        desc = "Automatically enable Auto Loot in game settings",
                        type = "toggle",
                        set = function(info, val)
                            local mod = self:GetModule("WoWOptions")
                            mod.db.profile.autoLoot = val
                            if val then
                                mod:ForceApply()
                            end
                        end,
                        get = function(info)
                            local mod = self:GetModule("WoWOptions")
                            return mod.db.profile.autoLoot
                        end,
                        disabled = function()
                            local mod = self:GetModule("WoWOptions")
                            return not mod.db.profile.enforceSettings
                        end,
                        order = 2,
                    },
                    assistedHighlight = {
                        name = "Assisted Highlight",
                        desc = "Automatically enable Assisted Targeting (highlights assist targets)",
                        type = "toggle",
                        set = function(info, val)
                            local mod = self:GetModule("WoWOptions")
                            mod.db.profile.assistedHighlight = val
                            if val then
                                mod:ForceApply()
                            end
                        end,
                        get = function(info)
                            local mod = self:GetModule("WoWOptions")
                            return mod.db.profile.assistedHighlight
                        end,
                        disabled = function()
                            local mod = self:GetModule("WoWOptions")
                            return not mod.db.profile.enforceSettings
                        end,
                        order = 3,
                    },
                    cooldownManager = {
                        name = "Enable Cooldown Manager",
                        desc = "Automatically enable countdown numbers on cooldowns",
                        type = "toggle",
                        set = function(info, val)
                            local mod = self:GetModule("WoWOptions")
                            mod.db.profile.cooldownManager = val
                            if val then
                                mod:ForceApply()
                            end
                        end,
                        get = function(info)
                            local mod = self:GetModule("WoWOptions")
                            return mod.db.profile.cooldownManager
                        end,
                        disabled = function()
                            local mod = self:GetModule("WoWOptions")
                            return not mod.db.profile.enforceSettings
                        end,
                        order = 4,
                    },
                    damageMeter = {
                        name = "Enable Damage Meter",
                        desc = "Automatically enable floating combat text",
                        type = "toggle",
                        set = function(info, val)
                            local mod = self:GetModule("WoWOptions")
                            mod.db.profile.damageMeter = val
                            if val then
                                mod:ForceApply()
                            end
                        end,
                        get = function(info)
                            local mod = self:GetModule("WoWOptions")
                            return mod.db.profile.damageMeter
                        end,
                        disabled = function()
                            local mod = self:GetModule("WoWOptions")
                            return not mod.db.profile.enforceSettings
                        end,
                        order = 5,
                    },
                },
            },
        },
    }
    
    -- Add profiles support
    options.args.profiles = AceDBOptions:GetOptionsTable(self.db)
    options.args.profiles.order = 100
    
    -- Register options
    AceConfig:RegisterOptionsTable("Brakk2", options)
    
    -- Add to Blizzard Interface Options
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("Brakk2", "Brakk2")
end

-- Event Handlers
function Brakk2:PLAYER_ENTERING_WORLD(event, isInitialLogin, isReloadingUi)
    if not self.db.profile.enabled then return end
    
    if isInitialLogin or isReloadingUi then
        self:Print("Welcome to Brakk2!")
    end
end

-- Slash Command Handler
function Brakk2:SlashCommand(input)
    if not input or input:trim() == "" then
        self:Print("Brakk2 v1.0.0")
        self:Print("Usage: /brakk2 <command>")
        self:Print("Commands:")
        self:Print("  config - Open configuration panel")
        self:Print("  toggle - Toggle addon on/off")
        self:Print("  status - Show current status")
        self:Print("  apply - Force apply WoW settings")
    elseif input == "config" then
        Settings.OpenToCategory(self.optionsFrame.name)
    elseif input == "apply" then
        local mod = self:GetModule("WoWOptions")
        if mod then
            mod:ForceApply()
        else
            self:Print("WoWOptions module not found")
        end
    elseif input == "findcvars" then
        local mod = self:GetModule("WoWOptions")
        if mod then
            mod:FindCVars()
        else
            self:Print("WoWOptions module not found")
        end
    elseif input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        if self.db.profile.enabled then
            self:Print("|cFF00FF00Enabled|r - Addon functionality is now active")
        else
            self:Print("|cFFFF0000Disabled|r - Addon functionality is now inactive")
        end
    elseif input == "status" then
        self:Print("Status: " .. (self.db.profile.enabled and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"))
    else
        self:Print("Unknown command: " .. input)
    end
end
