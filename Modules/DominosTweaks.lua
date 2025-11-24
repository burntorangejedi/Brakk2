local addonName, addon = ...
local Brakk2 = LibStub("AceAddon-3.0"):GetAddon("Brakk2")
local DominosTweaks = Brakk2:NewModule("DominosTweaks", "AceEvent-3.0")

-- Default settings for this module
local defaults = {
    profile = {
        hotkeyFont = "Fonts\\FRIZQT__.TTF",
        hotkeyFontSize = 24,
        hotkeyOutline = "OUTLINE",
        hotkeyThickOutline = false,
        hotkeyShadow = false,
    }
}

local function GetFontFlags()
    local flags = {}
    if DominosTweaks.db and DominosTweaks.db.profile.hotkeyOutline then
        table.insert(flags, DominosTweaks.db.profile.hotkeyOutline)
    end
    if DominosTweaks.db and DominosTweaks.db.profile.hotkeyThickOutline then
        table.insert(flags, "THICKOUTLINE")
    end
    return #flags > 0 and table.concat(flags, ",") or nil
end

local function UpdateDominosFonts()
    local font = DominosTweaks.db and DominosTweaks.db.profile.hotkeyFont or "Fonts\\FRIZQT__.TTF"
    local size = DominosTweaks.db and DominosTweaks.db.profile.hotkeyFontSize or 24
    local flags = GetFontFlags()
    local shadow = DominosTweaks.db and DominosTweaks.db.profile.hotkeyShadow
    for i = 1, 120 do
        local button = _G["DominosActionButton" .. i]
        if button and button.HotKey then
            local hk = button.HotKey
            hk:SetFont(font, size, flags)
            if shadow then
                hk:SetShadowColor(0, 0, 0, 1)
                hk:SetShadowOffset(1, -1)
            else
                hk:SetShadowColor(0, 0, 0, 0)
                hk:SetShadowOffset(0, 0)
            end
            hk:SetAlpha(1)
        end
    end
end

local function TryHookDominos()
    print("In TryHookDominos of DominosTweaks")
    if Dominos and Dominos.ActionButton and Dominos.ActionButton.UpdateHotkey then
        if not DominosTweaks._hooked then
            hooksecurefunc(Dominos.ActionButton, "UpdateHotkey", UpdateDominosFonts)
            DominosTweaks._hooked = true
            Brakk2:Print("DominosTweaks: Hooked Dominos ActionButton hotkey updater.")
        end
        UpdateDominosFonts()
        return true
    end
    return false
end

function DominosTweaks:OnInitialize()
    self.db = Brakk2.db:RegisterNamespace("DominosTweaks", defaults)
    self:RegisterEvent("ADDON_LOADED")
    TryHookDominos()
end

local function StartDominosFontTicker()
    if DominosTweaks._fontTicker then
        DominosTweaks._fontTicker:Cancel()
    end
    local count = 0
    DominosTweaks._fontTicker = C_Timer.NewTicker(0.1, function()
        UpdateDominosFonts()
        count = count + 1
        if count >= 30 then -- 3 seconds
            DominosTweaks._fontTicker:Cancel()
            DominosTweaks._fontTicker = nil
            Brakk2:Print("DominosTweaks: Font ticker finished.")
        end
    end)
end

-- Call this in OnEnable and after successful hook
local oldOnEnable = DominosTweaks.OnEnable
function DominosTweaks:OnEnable()
    if oldOnEnable then oldOnEnable(self) end
    StartDominosFontTicker()
end

function DominosTweaks:ADDON_LOADED(addonName)
    if addonName == "Dominos" then
        print("In ADDON_LOADED of DominosTweaks")
        if TryHookDominos() then
            self:UnregisterEvent("ADDON_LOADED")
        end
    end
end

-- Use LibSharedMedia for font selection if available
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)

local function GetFontChoices()
    local choices = {}
    if LSM then
        for _, fontKey in ipairs(LSM:List("font")) do
            local fontPath = LSM:Fetch("font", fontKey)
            choices[fontPath] = fontKey
        end
    else
        choices["Fonts\\FRIZQT__.TTF"] = "Friz Quadrata (Default)"
        choices["Fonts\\ARIALN.TTF"] = "Arial Narrow"
        choices["Fonts\\MORPHEUS.TTF"] = "Morpheus"
        choices["Fonts\\SKURRI.TTF"] = "Skurri"
    end
    return choices
end

-- AceConfig options for DominosTweaks
function DominosTweaks:GetOptionsTable()
    return {
        name = "Dominos Tweaks",
        type = "group",
        order = 10,
        args = {
            hotkeyFont = {
                name = "Hotkey Font",
                desc = "Font used for Dominos hotkey text.",
                type = "select",
                values = GetFontChoices,
                set = function(info, val)
                    self.db.profile.hotkeyFont = val
                    StartDominosFontTicker()
                end,
                get = function(info) return self.db.profile.hotkeyFont end,
                order = 1,
            },
            hotkeyFontSize = {
                name = "Hotkey Font Size",
                desc = "Font size for Dominos hotkey text.",
                type = "range",
                min = 8, max = 48, step = 1,
                set = function(info, val)
                    self.db.profile.hotkeyFontSize = val
                    StartDominosFontTicker()
                end,
                get = function(info) return self.db.profile.hotkeyFontSize end,
                order = 2,
            },
            hotkeyOutline = {
                name = "Outline",
                desc = "Outline style for Dominos hotkey text.",
                type = "select",
                values = { NONE = "None", OUTLINE = "Outline" },
                set = function(info, val)
                    self.db.profile.hotkeyOutline = val ~= "NONE" and val or nil
                    StartDominosFontTicker()
                end,
                get = function(info) return self.db.profile.hotkeyOutline or "NONE" end,
                order = 3,
            },
            hotkeyThickOutline = {
                name = "Thick Outline",
                desc = "Add thick outline to Dominos hotkey text.",
                type = "toggle",
                set = function(info, val)
                    self.db.profile.hotkeyThickOutline = val
                    StartDominosFontTicker()
                end,
                get = function(info) return self.db.profile.hotkeyThickOutline end,
                order = 4,
            },
            hotkeyShadow = {
                name = "Shadow",
                desc = "Add shadow to Dominos hotkey text.",
                type = "toggle",
                set = function(info, val)
                    self.db.profile.hotkeyShadow = val
                    StartDominosFontTicker()
                end,
                get = function(info) return self.db.profile.hotkeyShadow end,
                order = 5,
            },
        },
    }
end

-- Expose for slash command
_G.Brakk2_DominosDebug = function()
    Brakk2:Print("[DominosTweaks] Manual region dump:")
    for i = 1, 5 do
        local button = _G["DominosActionButton" .. i]
        if button then
            PrintButtonRegions(button, i)
        else
            Brakk2:Print(string.format("Button %d not found", i))
        end
    end
end
