local addonName, addon = ...
local Brakk2 = LibStub("AceAddon-3.0"):GetAddon("Brakk2")
local ProfileManager = Brakk2:NewModule("ProfileManager")
local AceGUI = LibStub("AceGUI-3.0")

local defaults = {
    profile = {
        enabled = true,
    }
}

function ProfileManager:OnInitialize()
    self.db = Brakk2.db:RegisterNamespace("ProfileManager", defaults)
end

local function GetEnabledAddons()
    local enabled = {}
    for i = 1, GetNumAddOns() do
        local name, title, notes, enabledState, loadable, reason, security = GetAddOnInfo(i)
        if enabledState and enabledState ~= "DISABLED" then
            table.insert(enabled, name)
        end
    end
    return enabled
end

local function ExportProfile()
    local export = {
        enabledAddons = GetEnabledAddons(),
    }
    local brakk2db = _G["Brakk2DB"] or _G[Brakk2 and Brakk2.db and Brakk2.db.parent or ""]
    if brakk2db then
        export.Brakk2DB = brakk2db
    else
        export.note = "Brakk2 settings not available at runtime. Only enabled addons exported."
    end
    local serialized = ProfileManager:Serialize(export)
    return serialized
end

function ProfileManager:Serialize(tbl)
    local function serializeTable(t, indent)
        indent = indent or ""
        local s = "{\n"
        for k, v in pairs(t) do
            s = s .. indent .. "  [" .. string.format("%q", tostring(k)) .. "] = "
            if type(v) == "table" then
                s = s .. serializeTable(v, indent .. "  ")
            elseif type(v) == "string" then
                s = s .. string.format("%q", v)
            else
                s = s .. tostring(v)
            end
            s = s .. ",\n"
        end
        s = s .. indent .. "}"
        return s
    end
    return serializeTable(tbl)
end

function ProfileManager:ShowExportWindow()
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Export Profile")
    frame:SetWidth(600)
    frame:SetHeight(400)
    frame:SetLayout("Fill")
    local editBox = AceGUI:Create("MultiLineEditBox")
    editBox:SetLabel("Copy this profile data to import elsewhere:")
    editBox:SetNumLines(20)
    editBox:SetFullWidth(true)
    editBox:SetFullHeight(true)
    local exportText = ExportProfile() or "(No export data available)"
    if not exportText or exportText == "" then
        exportText = "(Export failed: No data to export)"
    end
    if print then print("[Brakk2] Export string length:", #exportText) end
    editBox:SetText(exportText)
    frame:AddChild(editBox)
end

function ProfileManager:GetOptionsTable()
    return {
        name = "Profile Manager",
        type = "group",
        order = 50,
        args = {
            export = {
                name = "Export Profile",
                type = "execute",
                desc = "Export enabled addons and Brakk2 settings for import elsewhere.",
                func = function() self:ShowExportWindow() end,
                order = 1,
            },
        },
    }
end
