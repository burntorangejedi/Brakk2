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
                        desc = "Enable or disable the addon",
                        type = "toggle",
                        set = function(info, val) self.db.profile.enabled = val end,
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
    elseif input == "config" then
        Settings.OpenToCategory(self.optionsFrame.name)
    elseif input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        self:Print("Addon " .. (self.db.profile.enabled and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"))
    elseif input == "status" then
        self:Print("Status: " .. (self.db.profile.enabled and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"))
    else
        self:Print("Unknown command: " .. input)
    end
end
