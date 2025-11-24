local LDB = LibStub("LibDataBroker-1.1")

Brakk2_LDB_Durability = LDB:NewDataObject("Brakk2_Durability", {
    type = "data source",
    text = "Durability: N/A",
    icon = "Interface\\ICONS\\inv_misc_armorkit_17",
    OnTooltipShow = function(tooltip)
        local cur, max = 0, 0
        for i = 1, 18 do
            local c, m = GetInventoryItemDurability(i)
            if c and m then cur = cur + c; max = max + m end
        end
        if max > 0 then
            tooltip:AddLine(string.format("Durability: %d%%", (cur/max)*100))
        else
            tooltip:AddLine("Durability: N/A")
        end
    end,
})

function Brakk2_LDB_Durability:Update()
    local cur, max = 0, 0
    for i = 1, 18 do
        local c, m = GetInventoryItemDurability(i)
        if c and m then cur = cur + c; max = max + m end
    end
    if max > 0 then
        self.text = string.format("Durability: %d%%", (cur/max)*100)
    else
        self.text = "Durability: N/A"
    end
end
