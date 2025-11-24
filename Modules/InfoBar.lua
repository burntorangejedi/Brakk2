local addonName, addon = ...
local Brakk2 = LibStub("AceAddon-3.0"):GetAddon("Brakk2")
local InfoBar = Brakk2:NewModule("InfoBar", "AceEvent-3.0")

local LSM = LibStub("LibSharedMedia-3.0")
local LDB = LibStub("LibDataBroker-1.1")

-- Load Durability LDB plugin
-- Durability LDB plugin (global from LDB/Durability.lua)
local durabilityLDB = _G.Brakk2_LDB_Durability
local AceGUI = LibStub("AceGUI-3.0")

-- Default settings
local defaults = {
    profile = {
        enabled = true,
        font = "Fonts\\FRIZQT__.TTF",
        fontSize = 14,
        barWidth = 300,
        barHeight = 24,
        barPoint = { "CENTER", nil, "CENTER", 0, -200 },
        plugins = {
            Durability = true,
        },
    }
}

local frame

function InfoBar:OnInitialize()
    self.db = Brakk2.db:RegisterNamespace("InfoBar", defaults)
end

function InfoBar:OnEnable()
    self:CreateBar()
    self:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "UpdatePlugins")
    self:UpdatePlugins()
end

function InfoBar:CreateBar()
    if frame then return end
    frame = CreateFrame("Frame", "Brakk2_InfoBar", UIParent, "BackdropTemplate")
    frame:SetSize(self.db.profile.barWidth, self.db.profile.barHeight)
    frame:SetPoint(unpack(self.db.profile.barPoint))
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(f) f:StartMoving() end)
    frame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        local a, _, r, x, y = f:GetPoint()
        self.db.profile.barPoint = { a, nil, r, x, y }
    end)
    frame.text = frame:CreateFontString(nil, "OVERLAY")
    frame.text:SetFont(self.db.profile.font, self.db.profile.fontSize, "OUTLINE")
    frame.text:SetAllPoints()
    frame.text:SetJustifyH("LEFT")
    frame.text:SetJustifyV("MIDDLE")
    frame:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = nil, tile = true, tileSize = 16, edgeSize = 0 })
    frame:SetBackdropColor(0,0,0,0.5)
    frame:Show()
end

function InfoBar:UpdateBar(text)
    if not frame then return end
    frame.text:SetFont(self.db.profile.font, self.db.profile.fontSize, "OUTLINE")
    frame.text:SetText(text)
end

function InfoBar:UpdatePlugins()
    local out = {}
    if self.db.profile.plugins.Durability then
        local cur, max = 0, 0
        for i = 1, 18 do
            local c, m = GetInventoryItemDurability(i)
            if c and m then cur = cur + c; max = max + m end
        end
        if max > 0 then
            table.insert(out, string.format("Durability: %d%%", (cur/max)*100))
        else
            table.insert(out, "Durability: N/A")
        end
    end
    self:UpdateBar(table.concat(out, "  |  "))
end


function InfoBar:UpdateLDB()
    if durabilityLDB and durabilityLDB.Update then
        durabilityLDB:Update()
    end
end

InfoBar:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "UpdateLDB")

-- AceConfig options for InfoBar
function InfoBar:GetOptionsTable()
    return {
        name = "Info Bar",
        type = "group",
        order = 20,
        args = {
            enabled = {
                name = "Enable Info Bar",
                type = "toggle",
                set = function(info, val)
                    self.db.profile.enabled = val
                    if val then self:Enable() else self:Disable() end
                end,
                get = function(info) return self.db.profile.enabled end,
                order = 1,
            },
            font = {
                name = "Font",
                type = "select",
                values = function()
                    local LSM = LibStub("LibSharedMedia-3.0")
                    local t = {}
                    for _, fontKey in ipairs(LSM:List("font")) do
                        local fontPath = LSM:Fetch("font", fontKey)
                        t[fontPath] = fontKey
                    end
                    return t
                end,
                set = function(info, val)
                    self.db.profile.font = val
                    self:UpdatePlugins()
                end,
                get = function(info) return self.db.profile.font end,
                order = 2,
            },
            fontSize = {
                name = "Font Size",
                type = "range",
                min = 8, max = 48, step = 1,
                set = function(info, val)
                    self.db.profile.fontSize = val
                    self:UpdatePlugins()
                end,
                get = function(info) return self.db.profile.fontSize end,
                order = 3,
            },
            barWidth = {
                name = "Bar Width",
                type = "range",
                min = 100, max = 1000, step = 10,
                set = function(info, val)
                    self.db.profile.barWidth = val
                    if frame then frame:SetWidth(val) end
                end,
                get = function(info) return self.db.profile.barWidth end,
                order = 4,
            },
            barHeight = {
                name = "Bar Height",
                type = "range",
                min = 10, max = 100, step = 1,
                set = function(info, val)
                    self.db.profile.barHeight = val
                    if frame then frame:SetHeight(val) end
                end,
                get = function(info) return self.db.profile.barHeight end,
                order = 5,
            },
        },
    }
end
