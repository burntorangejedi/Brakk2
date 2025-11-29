-- Brakk2 Core
local addonName, addon = ...

-- Create addon namespace
Brakk2 = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")

-- Default settings
local defaults = {
    profile = {
        enabled = true,
    }
}


function Brakk2:OnInitialize()
    -- Initialize saved variables
    self.db = LibStub("AceDB-3.0"):New(addonName .. "DB", defaults, true)
    -- Register slash commands
    self:RegisterChatCommand(addonName:lower(), "SlashCommand")
    print("|cFF00FF00" .. addonName .. "|r loaded successfully!")
end

function Brakk2:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    -- Setup options (now that all modules are loaded)
    self:SetupOptions()

    -- Enable DominosTweaks module if present
    if self:GetModule("DominosTweaks", true) then
        self:EnableModule("DominosTweaks")
    end
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
        name = addonName,
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
                    modules = {
                        name = "Modules",
                        type = "group",
                        inline = true,
                        order = 10,
                        args = {
                            wowoptions = {
                                name = "WoW Options",
                                desc = "Enable or disable the WoW Options module",
                                type = "toggle",
                                set = function(info, val)
                                    if val then
                                        self:EnableModule("WoWOptions")
                                    else
                                        self:DisableModule("WoWOptions")
                                    end
                                end,
                                get = function(info)
                                    local mod = self:GetModule("WoWOptions", true)
                                    return mod and mod:IsEnabled() or false
                                end,
                                order = 1,
                            },
                            dominostweaks = {
                                name = "Dominos Tweaks",
                                desc = "Enable or disable the Dominos Tweaks module",
                                type = "toggle",
                                set = function(info, val)
                                    if val then
                                        self:EnableModule("DominosTweaks")
                                    else
                                        self:DisableModule("DominosTweaks")
                                    end
                                end,
                                get = function(info)
                                    local mod = self:GetModule("DominosTweaks", true)
                                    return mod and mod:IsEnabled() or false
                                end,
                                order = 2,
                            },
                           instancewatcher = {
                               name = "Instance Watcher",
                               desc = "Enable or disable the Instance Watcher module",
                               type = "toggle",
                               set = function(info, val)
                                   if val then
                                       self:EnableModule("InstanceWatcher")
                                   else
                                       self:DisableModule("InstanceWatcher")
                                   end
                               end,
                               get = function(info)
                                   local mod = self:GetModule("InstanceWatcher", true)
                                   return mod and mod:IsEnabled() or false
                               end,
                               order = 10,
                           },
                        },
                    },
                },
            },
            -- WoW Options panel is now provided by the module
            wowoptions = Brakk2:GetModule("WoWOptions"):GetOptionsTable(),
            dominostweaks = Brakk2:GetModule("DominosTweaks"):GetOptionsTable(),
            infobar = Brakk2:GetModule("InfoBar"):GetOptionsTable(),
            profilemanager = Brakk2:GetModule("ProfileManager"):GetOptionsTable(),
            instancewatcher = Brakk2:GetModule("InstanceWatcher"):GetOptionsTable(),
        },
    }

    -- Add profiles support
    options.args.profiles = AceDBOptions:GetOptionsTable(self.db)
    options.args.profiles.order = 100

    -- Register options
    AceConfig:RegisterOptionsTable(addonName, options)

    -- Add to Blizzard Interface Options
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(addonName, addonName)
    -- Refresh EditMode profiles every time the options panel is shown
    if self.optionsFrame and self.optionsFrame:HasScript("OnShow") then
        local origOnShow = self.optionsFrame:GetScript("OnShow")
        self.optionsFrame:SetScript("OnShow", function(frame, ...)
            local mod = self:GetModule("WoWOptions")
            if mod and mod.UpdateEditModeProfiles then
                mod:UpdateEditModeProfiles()
            end
            if origOnShow then origOnShow(frame, ...) end
        end)
    end
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
    elseif input == "layouts" then
        local mod = self:GetModule("WoWOptions")
        if C_EditMode and C_EditMode.GetLayouts then
            local layouts = C_EditMode.GetLayouts()
            print("[Brakk2] C_EditMode.GetLayouts() returned:", layouts)
            if type(layouts) == "table" then
                for k, v in pairs(layouts) do
                    print("[Brakk2] Layout key:", k, "value:", v)
                    if k == "layouts" and type(v) == "table" then
                        for i, layout in ipairs(v) do
                            print("[Brakk2]   Layout #", i)
                            if type(layout) == "table" then
                                for k2, v2 in pairs(layout) do
                                    print("[Brakk2]     ", k2, v2)
                                end
                            end
                        end
                    elseif type(v) == "table" then
                        for k2, v2 in pairs(v) do
                            print("[Brakk2]   ", k2, v2)
                        end
                    end
                end
            else
                print("[Brakk2] No layouts found or API returned nil.")
            end
        else
            print("[Brakk2] C_EditMode or GetLayouts not available.")
        end
    elseif input == "apply" then
        local mod = self:GetModule("WoWOptions")
        if mod then
            local wowOptions = Brakk2:GetModule("WoWOptions")
            if wowOptions then
                wowOptions:ForceApply()
            end
        else
            self:Print("WoWOptions module not found")
        end
    elseif input == "findcvars" then
        local mod = self:GetModule("WoWOptions")
        if mod then
            -- Removed call to FindCVars (does not exist)
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
    elseif input == "dominosdebug" then
        if _G.Brakk2_DominosDebug then
            _G.Brakk2_DominosDebug()
        else
            self:Print("DominosTweaks debug function not found.")
        end
    else
        self:Print("Unknown command: " .. input)
    end
end
